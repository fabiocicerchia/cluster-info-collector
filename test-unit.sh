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

echo PASS
