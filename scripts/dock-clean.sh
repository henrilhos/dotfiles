#!/usr/bin/env bash
#
# Unpins every app from the Dock. Running apps still show up while open,
# and the Downloads stack / folders on the right side are left alone.
# Safe to re-run.
#
# One-shot on purpose: nix-darwin's `system.defaults.dock.persistent-apps`
# could enforce this, but it would also wipe anything pinned by hand on
# every `darwin-rebuild switch`.
#
# Usage:
#   ~/dotfiles/scripts/dock-clean.sh
#
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script only supports macOS." >&2
  exit 1
fi

defaults write com.apple.dock persistent-apps -array
killall Dock
