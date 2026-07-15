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

echo PASS
