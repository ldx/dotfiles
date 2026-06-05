#!/usr/bin/env bash
# Show content diffs between this repo's dotfiles/ directory and $HOME.
# Usage: ./diff-home-dotfiles.sh [source] [destination]

set -euo pipefail

SRC="${1:-dotfiles}"
DST="${2:-$HOME}"

rsync -avni --checksum "$SRC/" "$DST/" \
  | awk '$1 ~ /^>fc/ {print $2}' \
  | while read -r f; do
      echo "===== $f ====="
      diff -u "$SRC/$f" "$DST/$f" || true
    done
