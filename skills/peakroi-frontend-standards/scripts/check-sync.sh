#!/usr/bin/env bash
# Verify the skill's copies of the PeakROI standards match the canonical files.
# Usage: check-sync.sh [canonical-dir]   (default: <repo>/openai)
set -euo pipefail

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
canonical_dir="${1:-$skill_dir/../../openai}"
status=0

for file in AGENTS.md SECURITY-STANDARD.md; do
  canonical="$canonical_dir/$file"
  copy="$skill_dir/references/$file"

  if [[ ! -f "$canonical" ]]; then
    echo "missing canonical file: $canonical" >&2
    status=1
    continue
  fi

  if diff -u "$canonical" "$copy"; then
    echo "in sync: $file"
  else
    echo "out of sync: $file (copy $canonical to $copy)" >&2
    status=1
  fi
done

exit "$status"
