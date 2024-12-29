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
curl -L "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" | tar -C "$HOME/share" -xjf -
ln -snf "$HOME/share/firefox/firefox" "$BINDIR/firefox"

# Dropbox.
curl -L "https://www.dropbox.com/download?plat=lnx.x86_64" | tar -C "$HOME" -xzf -

# Node & nvm.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Rust.
curl -L https://sh.rustup.rs >/tmp/rustup.sh
chmod +x /tmp/rustup.sh
/tmp/rustup.sh -y

# Fonts
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/LiberationMono.zip >/tmp/LiberationMono.zip
mkdir -p "$HOME/.local/share/fonts"
unzip -o -d "$HOME/.local/share/fonts" /tmp/LiberationMono.zip
fc-cache -f -v

# Minikube.
curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 >"$BINDIR/minikube" &&
  chmod +x "$BINDIR/minikube"

# Closest-airport.
curl -L https://github.com/ldx/closest-airport/releases/download/v1.0.0/closest-airport.tar.gz | tar xzf - -C "$BINDIR"

# Bazelisk.
curl -L "https://github.com/bazelbuild/bazelisk/releases/download/v1.10.1/bazelisk-linux-amd64" >"$BINDIR/bazel"

# Neovim.
curl -L https://github.com/neovim/neovim/releases/latest/download/nvim.appimage >"$BINDIR/vim"
chmod u+x "$BINDIR/vim"
#pip3 install --break-system-packages --user pynvim

# LazyVim.
rm -rf "$HOME/.config/nvim"
rm -rf "$HOME/.local/share/nvim"
rm -rf "$HOME/.local/state/nvim"
rm -rf "$HOME/.cache/nvim"
git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
rm -rf "$HOME/.config/nvim/.git"
cp -rf "$CURDIR/dotfiles/.config/nvim"/* "$HOME/.config/nvim/"

# Powerline.
pip3 install --break-system-packages --user powerline-status powerline_gitstatus

# TFenv and Tofuenv
rm -rf "$HOME/.tfenv"
git clone https://github.com/tfutils/tfenv.git "$HOME/.tfenv"
for x in "$HOME/.tfenv/bin/"*; do
  ln -snf "$x" "$BINDIR/"
done
rm -rf "$HOME/.tofuenv"
git clone https://github.com/tofuutils/tofuenv.git "$HOME/.tofuenv"
for x in "$HOME/.tofuenv/bin/"*; do
  ln -snf "$x" "$BINDIR/"
done

# Default browser.
xdg-settings set default-web-browser firefox_firefox.desktop

# Docker plugins.
curl -L https://github.com/docker/buildx/releases/download/v0.11.0/buildx-v0.11.0.linux-amd64 >"$HOME"/.docker/cli-plugins/docker-buildx
chmod +x "$HOME"/.docker/cli-plugins/docker-buildx

chmod 0755 "$BINDIR/"*
