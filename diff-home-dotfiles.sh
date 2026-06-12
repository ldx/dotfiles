#!/usr/bin/env bash
# Show content diffs between this repo's dotfiles/ directory and $HOME.
# Usage: ./diff-home-dotfiles.sh [source] [destination]

set -euo pipefail

SRC="${1:-dotfiles}"
DST="${2:-$HOME}"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

normalize_json() {
  local input="$1"
  local output="$2"

  python3 - "$input" "$output" <<'PY'
import json
import sys


def strip_changelog(value):
    if isinstance(value, dict):
        return {
            key: strip_changelog(item)
            for key, item in value.items()
            if key != "lastChangelogVersion"
        }
    if isinstance(value, list):
        return [strip_changelog(item) for item in value]
    return value


with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

with open(sys.argv[2], "w", encoding="utf-8") as f:
    json.dump(strip_changelog(data), f, indent=2)
    f.write("\n")
PY
}

rsync -avni --checksum "$SRC/" "$DST/" \
  | awk '$1 ~ /^>f/ {print $2}' \
  | while read -r f; do
      if [[ ! -e "$DST/$f" ]]; then
        echo "===== $f ====="
        echo "Missing from destination: $DST/$f"
        continue
      fi

      if [[ "$f" == *.json ]]; then
        src_normalized="$TMPDIR/src-${f//\//_}"
        dst_normalized="$TMPDIR/dst-${f//\//_}"
        if normalize_json "$SRC/$f" "$src_normalized" && normalize_json "$DST/$f" "$dst_normalized"; then
          if cmp -s "$src_normalized" "$dst_normalized"; then
            continue
          fi
          echo "===== $f ====="
          diff -u --label "$SRC/$f" --label "$DST/$f" "$src_normalized" "$dst_normalized" || true
          continue
        fi
      fi

      echo "===== $f ====="
      diff -u "$SRC/$f" "$DST/$f" || true
    done
