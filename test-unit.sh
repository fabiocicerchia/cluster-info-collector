#!/usr/bin/env bash
# Unit tests for lib.sh helpers — no kubectl/docker required.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=lib.sh
. ./lib.sh

fail() { echo "FAIL: $*" >&2; exit 1; }

# redact_stream: inline "KEY: value" form
out=$(printf 'DB_PASSWORD:  hunter2\nUSERNAME:  admin\n' | redact_stream)
[[ "$out" == $'DB_PASSWORD: REDACTED\nUSERNAME:  admin' ]] || fail "inline redaction: $out"

# redact_stream: YAML "- name: KEY" / "value: VAL" form
out=$(printf -- '- name: API_TOKEN\n  value: abc123\n- name: PORT\n  value: "8080"\n' | redact_stream)
printf '%s\n' "$out" | grep -q 'value: REDACTED' || fail "yaml redaction missed: $out"
printf '%s\n' "$out" | grep -q 'value: "8080"' || fail "yaml redaction over-matched: $out"

# dir_size_bytes / enforce_size_budget
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/namespaces/ns/logs"
big="$tmpdir/namespaces/ns/logs/big_c.log"
small="$tmpdir/namespaces/ns/logs/small_c.log"
yes "line of log output padding this file out nicely" | head -n 200000 >"$big" || true  # a few MB
seq 1 10 >"$small"                                                             # a few bytes

[[ "$(dir_size_bytes "$tmpdir")" -gt 0 ]] || fail "dir_size_bytes returned 0 for a non-empty dir"

enforce_size_budget "$tmpdir" 0   # max_mb<=0 is a no-op
[[ "$(wc -l <"$big")" -eq 200000 ]] || fail "max_mb=0 should be a no-op"

enforce_size_budget "$tmpdir" 100   # budget already satisfied is a no-op
[[ "$(wc -l <"$big")" -eq 200000 ]] || fail "budget already satisfied should be a no-op"

enforce_size_budget "$tmpdir" 1 3   # force truncation: big file over a 1MB budget
grep -q "truncated to fit" "$big" || fail "expected the big log to be truncated under a 1MB budget"
[[ "$(wc -l <"$big")" -eq 4 ]] || fail "expected big log truncated to marker + keep_lines, got $(wc -l <"$big") lines"
[[ "$(wc -l <"$small")" -eq 10 ]] || fail "small log should be untouched: $(wc -l <"$small") lines"

# docker-collect.sh --dry-run, with fake kubectl/docker stubs (no real
# cluster or docker daemon required).
fakebin=$(mktemp -d)
trap 'rm -rf "$fakebin"' EXIT

cat >"$fakebin/kubectl" <<'EOF'
#!/usr/bin/env bash
printf '%s\n%s\n%s\n%s\n' "$FAKE_CA" "$FAKE_CLIENT_CERT" "$FAKE_CLIENT_KEY" "$FAKE_SERVER"
EOF
cat >"$fakebin/docker" <<'EOF'
#!/usr/bin/env bash
if [[ "$1 $2" == "network ls" ]]; then
  echo net123
elif [[ "$1 $2" == "network inspect" && "$4" == "-f" ]]; then
  case "$5" in
    *IPv4Address*) echo "${FAKE_NET_IP:-10.99.0.2/24} " ;;
    *.Name*)       echo "fakenet" ;;
  esac
fi
EOF
chmod +x "$fakebin/kubectl" "$fakebin/docker"

fakekube=$(mktemp)
export FAKE_CA=/tmp/fake-certs/ca.crt
export FAKE_CLIENT_CERT=/tmp/fake-certs/client.crt
export FAKE_CLIENT_KEY=/tmp/fake-certs/client.key
export FAKE_NET_IP=10.99.0.2/24

# server host matches the fake network's container IP: --network expected.
export FAKE_SERVER=https://10.99.0.2:6443
out=$(PATH="$fakebin:$PATH" ./docker-collect.sh --dry-run --kubeconfig "$fakekube" 2>&1)
echo "$out" | grep -q -- "--network fakenet" || fail "expected --network fakenet, got: $out"
echo "$out" | grep -q -- "--user $(id -u):$(id -g)" || fail "expected --user $(id -u):$(id -g), got: $out"
echo "$out" | grep -q "KUBECONFIG=/home/collector/.kube/config" || fail "expected KUBECONFIG env, got: $out"
echo "$out" | grep -q -- "-v /tmp/fake-certs:/tmp/fake-certs:ro" || fail "expected deduped cert-dir mount, got: $out"

# server host does not match any network container IP: no --network.
export FAKE_SERVER=https://203.0.113.5:6443
out=$(PATH="$fakebin:$PATH" ./docker-collect.sh --dry-run --kubeconfig "$fakekube" 2>&1)
echo "$out" | grep -q -- "--network" && fail "expected no --network for a non-matching server, got: $out"

# docker-collect.sh exit codes: each refusal has its own sysexits code, so a
# caller can tell a typo from a kubeconfig that isn't there.
rc=0; PATH="$fakebin:$PATH" ./docker-collect.sh --bogus-flag >/dev/null 2>&1 || rc=$?
[[ "$rc" -eq 64 ]] || fail "expected EX_USAGE 64 for an unknown option, got $rc"

rc=0; PATH="$fakebin:$PATH" ./docker-collect.sh --dry-run --kubeconfig /nonexistent >/dev/null 2>&1 || rc=$?
[[ "$rc" -eq 66 ]] || fail "expected EX_NOINPUT 66 for a missing kubeconfig, got $rc"

# bash stays on PATH here on purpose: an empty PATH makes `env bash` itself
# exit 127, which would pass this assertion without running a line of the script.
nodocker=$(mktemp -d)
ln -s "$(command -v bash)" "$nodocker/bash"
rc=0; PATH="$nodocker" ./docker-collect.sh --dry-run >/dev/null 2>&1 || rc=$?
rm -rf "$nodocker"
[[ "$rc" -eq 127 ]] || fail "expected 127 when docker is not on PATH, got $rc"

rm -f "$fakekube"
unset FAKE_CA FAKE_CLIENT_CERT FAKE_CLIENT_KEY FAKE_NET_IP FAKE_SERVER

echo PASS
