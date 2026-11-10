#!/usr/bin/env bash
# Quick size report for known AI paths (expand HOME). Compare totals with: dua -A .
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CATALOG="$ROOT/catalog"

expand() {
  local p="$1"
  p="${p/#\~/$HOME}"
  echo "$p"
}

total=0
echo "{"
echo '  "paths": ['
first=1
for f in "$CATALOG"/*.toml; do
  [[ "$(basename "$f")" == "schema.toml" ]] && continue
  while IFS= read -r line; do
    if [[ "$line" =~ linux_paths\ =\ \[\"([^\"]+)\" ]]; then
      path="$(expand "${BASH_REMATCH[1]}")"
      if [[ -d "$path" ]]; then
        bytes=$(du -sb "$path" 2>/dev/null | awk '{print $1}')
        [[ -n "$bytes" ]] || bytes=0
        total=$((total + bytes))
        comma=","
        [[ $first -eq 1 ]] && comma="" && first=0
        printf '%s    {"path": "%s", "bytes": %s}\n' "$comma" "$path" "$bytes"
      fi
    fi
  done < "$f"
done
echo "  ],"
echo "  \"total_bytes\": $total"
echo "}"
