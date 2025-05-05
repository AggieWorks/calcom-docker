#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <FROM> <TO>" >&2
  exit 1
fi

FROM="$1"
TO="$2"

if [[ "$FROM" == "$TO" ]]; then
  echo "Nothing to replace—value already set to '$TO'."
  exit 0
fi

echo "Replacing all instances of '$FROM' → '$TO'…"

# collect files (you can adjust --include patterns as needed)
mapfile -t files < <(
  grep -RIl --exclude-dir=.git \
    --include="*.js" --include="*.html" \
    --include="*.json" --include="*.css" \
    "$FROM" \
    apps/web/.next/ apps/web/public/ \
  || true
)

if (( ${#files[@]} == 0 )); then
  echo "No files found containing '$FROM'." >&2
  exit 0
fi

for file in "${files[@]}"; do
  sed -i "s|$FROM|$TO|g" "$file"
done

echo "✔️  Replaced in ${#files[@]} files."
