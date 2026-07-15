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

# Total size in bytes of every file under dir (recursive).
dir_size_bytes() {
  local dir="$1" total=0 sz f
  for f in $(find "$dir" -type f 2>/dev/null); do
    sz=$(wc -c <"$f" 2>/dev/null) || sz=0
    total=$((total + sz))
  done
  echo "$total"
}

# Enforce a size budget (MB) on a bundle dir by truncating the biggest *.log
# files first (keeping their tail), re-checking after each, until under
# budget or every log has been truncated once. No-op if max_mb <= 0 or
# already under budget. describe/resource/event dumps are never touched.
enforce_size_budget() {
  local dir="$1" max_mb="$2" keep_lines="${3:-200}" max_bytes size f
  [[ "$max_mb" -gt 0 ]] || return 0
  max_bytes=$((max_mb * 1024 * 1024))
  size=$(dir_size_bytes "$dir")
  ((size <= max_bytes)) && return 0
  for f in $(
    for lf in $(find "$dir" -type f -path '*/logs/*.log' 2>/dev/null); do
      printf '%s %s\n' "$(wc -c <"$lf")" "$lf"
    done | sort -rn | awk '{print $2}'
  ); do
    size=$(dir_size_bytes "$dir")
    ((size <= max_bytes)) && break
    [[ -s "$f" ]] || continue
    {
      echo "... [collect: truncated to fit ${max_mb}MB size budget]"
      tail -n "$keep_lines" "$f"
    } >"${f}.trunc" && mv "${f}.trunc" "$f"
  done
}
