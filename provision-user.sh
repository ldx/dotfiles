#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
    echo "This script must be run as a regular user." 1>&2
    exit 1
fi

CURDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

BINDIR="$HOME/bin"

# Directory for user-installed binaries.
mkdir -p "$BINDIR"

mkdir -p "$HOME"
rsync -av "$CURDIR/local/" "$HOME/"

mkdir -p "$HOME/.terminfo"
cp "$CURDIR/terminfo/"*.terminfo "$HOME/.terminfo/"
for ti in "$HOME/.terminfo/"*.terminfo; do
    tic "$ti"
done

rsync -av "$CURDIR/dotfiles/" "$HOME/"

# Firefox.
curl -L "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" | tar -C "$HOME/share" -xjf -
ln -s "$HOME/share/firefox/firefox" "$BINDIR/firefox"

# Dropbox.
curl -L "https://www.dropbox.com/download?plat=lnx.x86_64" | tar -C "$HOME" -xzf -

# Node & nvm.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Minikube.
curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 > "$BINDIR/minikube" \
    && chmod +x "$BINDIR/minikube"

# Closest-airport.
curl -L https://github.com/ldx/closest-airport/releases/download/v1.0.0/closest-airport.tar.gz | tar xzf - -C "$BINDIR"

# Bazelisk.
curl -L "https://github.com/bazelbuild/bazelisk/releases/download/v1.10.1/bazelisk-linux-amd64" > "$BINDIR/bazel"

# Neovim.
curl -L https://github.com/neovim/neovim/releases/latest/download/nvim.appimage > "$BINDIR/nvim.appimage"
chmod u+x "$BINDIR/nvim.appimage"
pip3 install --break-system-packages --user pynvim

# LazyVim.
[[ -d ~/.config/nvim ]] && mv ~/.config/nvim{,.bak} || true
[[ -d ~/.local/share/nvim ]] && mv ~/.local/share/nvim{,.bak} || true
[[ -d ~/.local/state/nvim ]] && mv ~/.local/state/nvim{,.bak} || true
[[ -d ~/.cache/nvim ]] && mv ~/.cache/nvim{,.bak} || true
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

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
curl -L https://github.com/docker/buildx/releases/download/v0.11.0/buildx-v0.11.0.linux-amd64 > "$HOME"/.docker/cli-plugins/docker-buildx; chmod +x "$HOME"/.docker/cli-plugins/docker-buildx

chmod 0755 "$BINDIR/"*
