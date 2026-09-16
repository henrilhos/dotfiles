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
  # Put nix on PATH for the rest of this script. The installer writes its
  # hook into /etc/zshrc, but sourcing that from bash dies on the zsh-only
  # `setopt` (exit 127, fatal under set -e) — so source the profile script
  # /etc/zshrc itself points at.
  NIX_PROFILE=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  if [[ -e "$NIX_PROFILE" ]]; then
    . "$NIX_PROFILE"
  fi
else
  log "Nix already installed."
fi

# --- 4. Trust GitHub's SSH host key (needed before any git@github.com
# clone — a fresh machine has no ~/.ssh/known_hosts yet, which makes SSH
# refuse non-interactively instead of prompting) ---
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
# Two endpoints, because the repo's ~/.ssh/config routes github.com over
# ssh.github.com:443 but isn't linked until ./install runs further down —
# so the clone in the next step still goes out over port 22, while every
# later connection uses the 443 route.
trust_host() {
  local pattern="$1" host="$2" port="$3"
  # -f is not optional: ssh-keygen resolves ~ from passwd, not $HOME.
  if ! ssh-keygen -F "$pattern" -f "$HOME/.ssh/known_hosts" >/dev/null 2>&1; then
    log "Adding $pattern to known_hosts..."
    ssh-keyscan -t ed25519 -p "$port" "$host" >>"$HOME/.ssh/known_hosts" 2>/dev/null
  fi
}
trust_host github.com github.com 22
trust_host "[ssh.github.com]:443" ssh.github.com 443
[[ -f "$HOME/.ssh/known_hosts" ]] && chmod 600 "$HOME/.ssh/known_hosts"

# --- 5. Get the dotfiles repo on disk ---
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  log "Dotfiles repo already present at $DOTFILES_DIR."
else
  if [[ -z "${DOTFILES_REPO:-}" ]]; then
    echo "$DOTFILES_DIR doesn't exist and DOTFILES_REPO is not set. Set it to your repo URL and re-run." >&2
    exit 1
  fi
  log "Cloning $DOTFILES_REPO into $DOTFILES_DIR..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# --- 6. Submodules ---
# Runs for a fresh clone and for a repo that was already on disk: a
# hand-made clone, or one made before a submodule was added, has none of
# these checked out. dotbot vendors PyYAML as a nested submodule of its
# own, so ./install can't even start without --recursive here.
#
# The Dracula PRO theme is a private repo, and the SSH agent that can
# reach it is only configured by ./install below (~/.ssh/config), so on a
# brand new machine this step is expected to partially fail. That's not
# fatal to everything else, so warn and carry on.
log "Checking out submodules..."
git -C "$DOTFILES_DIR" submodule sync --recursive

# --init --recursive aborts the whole run at the first submodule it can't
# clone, which would leave dotbot's nested PyYAML unchecked out. So take
# the ones ./install depends on explicitly first, and let a failure here
# be fatal — there is no installing anything without them.
git -C "$DOTFILES_DIR" submodule update --init --recursive \
  submodules/dotbot submodules/oh-my-zsh

# Then everything else, best effort. The Dracula PRO theme is private and
# the 1Password SSH agent that can reach it is itself set up by ./install
# below, so on a brand new machine this pass is expected to fail; dotbot
# retries it at the end of install.conf.yaml, once ~/.ssh/config exists.
if ! git -C "$DOTFILES_DIR" submodule update --init --recursive; then
  log "WARNING: some optional submodules failed to check out (expected for"
  log "the private Dracula PRO theme on a machine without SSH access yet)."
fi

if [[ ! -f "$DOTFILES_DIR/submodules/dotbot/lib/pyyaml/lib/yaml/__init__.py" ]]; then
  echo "dotbot's vendored PyYAML is missing — ./install cannot run." >&2
  exit 1
fi

# --- 7. Run the dotbot installer (symlinks) ---
log "Running ./install..."
(cd "$DOTFILES_DIR" && ./install)

# --- 8. Apply nix-darwin config, if present ---
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
