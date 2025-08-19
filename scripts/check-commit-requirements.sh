#!/usr/bin/env bash
set -euo pipefail

base_sha="${1:-origin/main}"

if [ ! -f requirements.json ]; then
  echo "requirements.json not found" >&2
  exit 1
fi

pattern=$(jq -r '.requirements[].id' requirements.json | paste -sd'|' -)

missing=0
while read -r subject; do
  if ! grep -Eq "($pattern)" <<<"$subject"; then
    echo "Commit message missing requirement ID: $subject"
    missing=1
  fi
done < <(git log --format=%s "$base_sha"..HEAD)

if [ "$missing" -ne 0 ]; then
  echo "One or more commits are missing requirement IDs." >&2
  exit 1
fi
