#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "This script must be run as a regular user." 1>&2
  exit 1
fi

CURDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

BINDIR="$HOME/.local/bin"

# Directory for user-installed binaries.
mkdir -p "$BINDIR"

# Copy local files.
mkdir -p "$HOME/.local"
rsync -av "$CURDIR/local/" "$HOME/.local/"

mkdir -p "$HOME/.terminfo"
cp "$CURDIR/terminfo/"*.terminfo "$HOME/.terminfo/"
for ti in "$HOME/.terminfo/"*.terminfo; do
  tic "$ti"
done

rsync -av "$CURDIR/dotfiles/" "$HOME/"

# Firefox.
curl -L "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" | tar -C "$HOME/.local/share" -xJf -
ln -snf "$HOME/.local/share/firefox/firefox" "$BINDIR/firefox"

# Dropbox.
curl -L "https://www.dropbox.com/download?plat=lnx.x86_64" | tar -C "$HOME" -xzf -

# Fonts.
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/LiberationMono.zip >/tmp/LiberationMono.zip
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CommitMono.zip >/tmp/CommitMono.zip
mkdir -p "$HOME/.local/share/fonts"
unzip -o -d "$HOME/.local/share/fonts" /tmp/LiberationMono.zip
unzip -o -d "$HOME/.local/share/fonts" /tmp/CommitMono.zip
sleep 3
fc-cache -f -v || fc-cache -f -v

# LazyVim.
rm -rf "$HOME/.config/nvim"
rm -rf "$HOME/.local/share/nvim"
rm -rf "$HOME/.local/state/nvim"
rm -rf "$HOME/.cache/nvim"
git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
rm -rf "$HOME/.config/nvim/.git"
cp -rf "$CURDIR/dotfiles/.config/nvim"/* "$HOME/.config/nvim/"

# Default browser.
xdg-settings set default-web-browser firefox.desktop || true


# Mise.
curl https://mise.run | sh
PATH=$PATH:$BINDIR mise install

# Symlink vim to neovim installed by mise.
ln -snf "$(PATH=$PATH:$BINDIR "$BINDIR/mise" which nvim)" "$BINDIR/vim"

chmod 0755 "$BINDIR/"*
