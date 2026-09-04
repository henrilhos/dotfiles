#!/usr/bin/env bash
# Applies whatever this repo currently says. Run after editing any .nix file.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HOST="tardis"

if [ "$DIR" != "$HOME/.dotfiles" ]; then
  ln -sfn "$DIR" "$HOME/.dotfiles"
fi

exec sudo darwin-rebuild switch --flake "$HOME/.dotfiles#$HOST"
