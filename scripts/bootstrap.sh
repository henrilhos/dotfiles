#!/usr/bin/env bash
#
# Bootstrap for a fresh macOS machine: installs Homebrew, installs Nix
# (via the Determinate installer), clones this repo if it isn't already
# on disk, and runs the dotbot installer. Safe to re-run — every step
# checks whether it's already done first.
#
# Usage (on a brand new machine, no clone yet):
#   DOTFILES_REPO=git@github.com:<you>/dotfiles.git \
#     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/<you>/dotfiles/main/scripts/bootstrap.sh)"
#
# Usage (repo already cloned locally, e.g. right now):
#   ~/dotfiles/scripts/bootstrap.sh
#
# Options (env vars):
#   DOTFILES_DIR   Target directory (default: ~/dotfiles)
#   DOTFILES_REPO  Repo URL, only needed if DOTFILES_DIR doesn't exist yet
#
set -euo pipefail

log() {
  echo "[bootstrap] $*"
}

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This bootstrap only supports macOS for now." >&2
  exit 1
fi

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# --- 1. Xcode Command Line Tools (git, make, etc. depend on this) ---
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools..."
  xcode-select --install || true
  log "Finish the Xcode CLT install in the popup, then re-run this script."
  exit 1
else
  log "Xcode Command Line Tools already installed."
fi

# --- 2. Homebrew ---
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  log "Homebrew already installed."
fi

BREW_PATH="/opt/homebrew/bin/brew"
[[ -x "$BREW_PATH" ]] || BREW_PATH="/usr/local/bin/brew"
eval "$("$BREW_PATH" shellenv)"

# --- 3. Nix (Determinate's native macOS pkg installer) ---
# The curl|sh installer's encrypted-APFS-volume step can fail with
# "Read-only file system" when FileVault is already on. The .pkg installer
# handles that correctly and is what Determinate now recommends for macOS.
# It also wires up /etc/zshrc and /etc/bashrc itself, so no manual sourcing
# is needed here.
if ! command -v nix >/dev/null 2>&1; then
  log "Installing Nix (Determinate .pkg installer)..."
  NIX_PKG="$(mktemp -t determinate-nix).pkg"
  curl -fsSL -o "$NIX_PKG" "https://install.determinate.systems/determinate-pkg/stable/Universal"
  sudo installer -pkg "$NIX_PKG" -target /
  rm -f "$NIX_PKG"
  . /etc/zshrc
else
  log "Nix already installed."
fi

# --- 4. Trust GitHub's SSH host key (needed before any git@github.com
# clone — a fresh machine has no ~/.ssh/known_hosts yet, which makes SSH
# refuse non-interactively instead of prompting) ---
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if ! ssh-keygen -F github.com >/dev/null 2>&1; then
  log "Adding GitHub's SSH host key to known_hosts..."
  ssh-keyscan -t ed25519 github.com >>"$HOME/.ssh/known_hosts" 2>/dev/null
  chmod 600 "$HOME/.ssh/known_hosts"
fi

# --- 5. Get the dotfiles repo on disk ---
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  log "Dotfiles repo already present at $DOTFILES_DIR."
else
  if [[ -z "${DOTFILES_REPO:-}" ]]; then
    echo "$DOTFILES_DIR doesn't exist and DOTFILES_REPO is not set. Set it to your repo URL and re-run." >&2
    exit 1
  fi
  log "Cloning $DOTFILES_REPO into $DOTFILES_DIR..."
  git clone --recurse-submodules "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# --- 6. Run the dotbot installer (symlinks) ---
log "Running ./install..."
(cd "$DOTFILES_DIR" && ./install)

# --- 7. Apply nix-darwin config, if present ---
if [[ -f "$DOTFILES_DIR/configs/nix-darwin/flake.nix" ]]; then
  # /etc/nix-darwin/flake.nix, if present, is what darwin-rebuild uses by
  # default when called with no --flake — set it up once so every future
  # `darwin-rebuild switch` needs no arguments.
  if [[ ! -e /etc/nix-darwin ]]; then
    log "Linking /etc/nix-darwin -> $DOTFILES_DIR/configs/nix-darwin ..."
    sudo ln -s "$DOTFILES_DIR/configs/nix-darwin" /etc/nix-darwin
  fi

  if command -v darwin-rebuild >/dev/null 2>&1; then
    log "Applying nix-darwin config (darwin-rebuild switch)..."
    darwin-rebuild switch
  else
    log "Applying nix-darwin config for the first time (nix run nix-darwin -- switch)..."
    nix run nix-darwin -- switch --flake "$DOTFILES_DIR/configs/nix-darwin"
  fi
else
  log "No configs/nix-darwin/flake.nix yet — skipping nix-darwin switch."
fi

log ""
log "Done! Restart your terminal (or run: exec zsh) to pick up everything."
