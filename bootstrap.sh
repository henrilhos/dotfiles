#!/usr/bin/env bash
# Takes a fresh Mac from nothing to a built nix-darwin system.
# Run this once. Every change after that goes through ./rebuild.sh.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HOST="tardis"
NIX_FLAGS=(--extra-experimental-features 'nix-command flakes')

echo "==> Step 1: Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm --determinate=false
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: hand /etc/nix/nix.conf to nix-darwin"
# nix-darwin refuses to start if it finds a nix.conf it did not write. Moving
# the installer's copy aside is exactly what its error message asks for.
if [ -e /etc/nix/nix.conf ] && [ ! -L /etc/nix/nix.conf ]; then
  echo "    moving /etc/nix/nix.conf -> /etc/nix/nix.conf.before-nix-darwin"
  sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
else
  echo "    nothing in the way"
fi

echo "==> Step 3: symlink this repo to ~/.dotfiles"
# modules/home/neovim.nix and vscode.nix resolve their out-of-store symlinks
# through ~/.dotfiles, so it has to exist before the first switch.
if [ "$DIR" != "$HOME/.dotfiles" ]; then
  ln -sfn "$DIR" "$HOME/.dotfiles"
fi

echo "==> Step 4: preserve machine-local state that lives beside generated config"
# gh writes its OAuth token to ~/.config/gh/hosts.yml, right next to the
# config.yml home-manager generates. Step 5 unlinks ~/.config/gh, so stash the
# token first and put it back afterwards, otherwise the switch silently logs
# you out of gh.
GH_HOSTS_BACKUP=""
if [ -f "$HOME/.config/gh/hosts.yml" ]; then
  GH_HOSTS_BACKUP="$(mktemp -t gh-hosts)"
  cp "$HOME/.config/gh/hosts.yml" "$GH_HOSTS_BACKUP"
  echo "    stashed gh auth token"
fi

echo "==> Step 5: move pre-existing dotfiles out of the way"
# home-manager writes symlinks and will not clobber anything already sitting at
# those paths. This clears out what the old bash setup linked there: symlinks
# are removed, real files get a .before-nix suffix rather than aborting the run.
for path in \
  "$HOME/.gitconfig" \
  "$HOME/.Brewfile" \
  "$HOME/.config/bin" \
  "$HOME/.config/fish" \
  "$HOME/.config/gh" \
  "$HOME/.config/ghostty" \
  "$HOME/.config/karabiner" \
  "$HOME/.config/mise" \
  "$HOME/.config/nvim" \
  "$HOME/.config/tmux" \
  "$HOME/.config/tmuxinator" \
  "$HOME/.ssh/config" \
  "$HOME/.ssh/allowed_signers" \
  "$HOME/.gnupg/gpg.conf" \
  "$HOME/.gnupg/gpg-agent.conf" \
  "$HOME/Library/Application Support/Code/User/settings.json" \
  "$HOME/Library/Application Support/Code/User/cspell.json"; do
  if [ -L "$path" ]; then
    rm "$path"
    echo "    unlinked $path"
  elif [ -e "$path" ]; then
    mv "$path" "$path.before-nix"
    echo "    moved $path -> $path.before-nix"
  fi
done

echo "==> Step 6: first darwin-rebuild switch"
# darwin-rebuild does not exist yet, so run it straight from the flake this
# once. The tool comes from the nix-darwin-26.05 branch; the system it builds
# is still pinned by this repo's flake.lock.
#
# sudo resets PATH to a secure default that excludes /nix/.../bin, so resolve
# nix's absolute path first.
NIX_BIN="$(command -v nix)"
sudo "$NIX_BIN" "${NIX_FLAGS[@]}" \
  run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake "$HOME/.dotfiles#$HOST"

if [ -n "$GH_HOSTS_BACKUP" ]; then
  mkdir -p "$HOME/.config/gh"
  cp "$GH_HOSTS_BACKUP" "$HOME/.config/gh/hosts.yml"
  chmod 600 "$HOME/.config/gh/hosts.yml"
  rm -f "$GH_HOSTS_BACKUP"
  echo "==> Restored gh auth token"
fi

echo
echo "==> Done."
echo "    Open a new terminal, then use ./rebuild.sh for every later change."
echo
echo "    Two things Nix cannot do for you:"
echo "      - grant Karabiner-Elements its input-monitoring permission"
echo "      - sign in to 1Password and enable its SSH agent (git signing needs it)"
