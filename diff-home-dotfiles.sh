#!/usr/bin/env bash
# Show content diffs between this repo's dotfiles/ directory and $HOME.
# Usage: ./diff-home-dotfiles.sh [source] [destination]

set -euo pipefail

SRC="${1:-dotfiles}"
DST="${2:-$HOME}"

rsync -avni --checksum "$SRC/" "$DST/" \
  | awk '$1 ~ /^>f/ {print $2}' \
  | while read -r f; do
      echo "===== $f ====="
      if [[ ! -e "$DST/$f" ]]; then
        echo "Missing from destination: $DST/$f"
      else
        diff -u "$SRC/$f" "$DST/$f" || true
      fi
    done
