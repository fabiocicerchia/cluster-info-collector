# shellcheck shell=bash
# Pure helpers used by `collect`, kept separate so test-unit.sh can source
# them without running the kubectl-heavy main script.

# Redact secret-like env var values ("KEY: value" inline, or YAML "- name: KEY" /
# "value: VAL" pairs). Keys are matched case-insensitively against common
# secret-ish substrings; scoped to what kubectl describe/get -o yaml emit.
redact_stream() {
  awk '
    function is_secret(k) {
      return toupper(k) ~ /SECRET|PASSWORD|TOKEN|APIKEY|API_KEY|CREDENTIAL|PRIVATE_KEY/
    }
    {
      line = $0
      if (match(line, /^[[:space:]]*-[[:space:]]*name:[[:space:]]*/)) {
        pending = substr(line, RLENGTH + 1)
        print line
        next
      }
      if (pending != "" && match(line, /^[[:space:]]*value:[[:space:]]*/)) {
        print is_secret(pending) ? substr(line, 1, RLENGTH) "REDACTED" : line
        pending = ""
        next
      }
      pending = ""
      key = line
      sub(/:.*/, "", key)
      if (key != line && is_secret(key)) sub(/:.*/, ": REDACTED", line)
      print line
    }
  '
}
