#!/usr/bin/env bash
# Sync CLI dotfiles from this repo to another dotfiles repo.
# Usage: sync-cli-dotfiles.sh <destination>

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dotfiles"
DST="${1:?Usage: $0 <destination>}"
DST="$(realpath "$DST")"

if [[ ! -d "$DST" ]]; then
  echo "Destination not found: $DST" >&2
  exit 1
fi

# Shell configs
for f in .bashrc .bash_profile .common.sh .complete_alias .inputrc .profile; do
  cp -v "$SRC/$f" "$DST/$f"
done

# CLI tool configs
mkdir -p "$DST/.config/mise"
cp -v "$SRC/.config/mise/config.toml" "$DST/.config/mise/config.toml"

cp -v "$SRC/.config/starship.toml" "$DST/.config/starship.toml"

# Neovim config
mkdir -p "$DST/.config/nvim"
cp -rv "$SRC/.config/nvim/." "$DST/.config/nvim/"

echo "Done. Review changes in $DST and commit."
