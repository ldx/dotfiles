#!/usr/bin/env bash

set -euo pipefail

CURDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

BINDIR="$HOME/.local/bin"

# Directory for user-installed binaries.
mkdir -p "$BINDIR"

# Vim/NeoVim.
rm -rf "$HOME/.vim"
rm -rf "$HOME/.config/nvim"; mkdir -p "$HOME/.config/nvim"
curl 'https://vim-bootstrap.com/generate.vim' --data 'editor=vim&langs=c&langs=erlang&langs=html&langs=go&langs=haskell&langs=html&langs=javascript&langs=python&langs=ruby&langs=rust' > "$HOME/.vimrc"
curl 'https://vim-bootstrap.com/generate.vim' --data 'editor=vim&langs=c&langs=erlang&langs=html&langs=go&langs=haskell&langs=html&langs=javascript&langs=python&langs=ruby&langs=rust' > "$HOME/.config/nvim/init.vim"

mkdir -p "$HOME/.local"
rsync -av "$CURDIR/local/" "$HOME/"

mkdir -p "$HOME/.terminfo"
cp "$CURDIR/terminfo/"*.terminfo "$HOME/.terminfo/"
for ti in "$HOME/.terminfo/"*.terminfo; do
    tic "$ti"
done

rsync -av "$CURDIR/dotfiles/" "$HOME/"

# Node & nvm.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Minikube.
curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 > "$BINDIR/minikube" \
    && chmod +x "$BINDIR/minikube"

# Closest-airport.
curl -L https://github.com/ldx/closest-airport/releases/download/v1.0.0/closest-airport.tar.gz | tar xzf - -C "$BINDIR"

# Bazelisk.
curl -L "https://github.com/bazelbuild/bazelisk/releases/download/v1.10.1/bazelisk-linux-amd64" > "$BINDIR/bazel"

# Powerline.
pip3 install --user powerline-status powerline_gitstatus

# TFenv.
rm -rf "$HOME/.tfenv"
git clone https://github.com/tfutils/tfenv.git "$HOME/.tfenv"
for x in "$HOME/.tfenv/bin/"*; do
   ln -snf "$x" "$BINDIR/"
done

chmod 0755 "$BINDIR/"*
