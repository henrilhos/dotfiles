#!/usr/bin/env bash
# homebrew.sh - Install Homebrew and packages

set -euo pipefail

# Load required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/scripts/lib/colors.sh"
source "$SCRIPT_DIR/scripts/lib/logging.sh"
source "$SCRIPT_DIR/scripts/lib/sudo.sh"

install_homebrew_and_packages() {
  local Q=""
  [ "${STRAP_DEBUG:-0}" -eq 0 ] && Q="-q"
  
  # Initialize sudo if needed
  if [ "${STRAP_SUDO:-0}" -eq 0 ]; then
    sudo_init || { logskip "Skipping Homebrew (requires sudo)."; return 0; }
  fi
  
  if [ "${STRAP_SUDO:-0}" -gt 0 ]; then
    # Update permissions
    log "Updating permissions on Homebrew directories"
    sudo_askpass mkdir -p "$HOMEBREW_PREFIX/"{Caskroom,Cellar,Frameworks}
    sudo_askpass chmod -R 775 "$HOMEBREW_PREFIX/"{Caskroom,Cellar,Frameworks}
    sudo_askpass chown -R "$USER" "$HOMEBREW_PREFIX" 2>/dev/null || true
    logk
    
    # Install Homebrew if not present
    if ! command -v brew >/dev/null 2>&1; then
      log "Installing Homebrew"
      script_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
      NONINTERACTIVE=${STRAP_CI:-0} \
        /usr/bin/env bash -c "$(curl -fsSL $script_url)"
      logk
    else
      log_no_sudo "Homebrew already installed."
      logk
    fi
    
    # Load Homebrew environment
    if ! type brew &>/dev/null; then
      eval "$("$HOMEBREW_PREFIX"/bin/brew shellenv)"
    fi
    
    # Disable analytics
    brew analytics off
    log_to_file "INFO: Homebrew analytics disabled"
    
    # Install packages from Brewfile
    log "Running Homebrew installs"
    if [ -f "$HOME/.Brewfile" ]; then
      log "Installing from $HOME/.Brewfile"
      brew bundle check --global || brew bundle --global
    elif [ -f "$SCRIPT_DIR/dotfiles/.Brewfile" ]; then
      log "Installing from $SCRIPT_DIR/dotfiles/.Brewfile"
      brew bundle check --file="$SCRIPT_DIR/dotfiles/.Brewfile" || \
        brew bundle --file="$SCRIPT_DIR/dotfiles/.Brewfile"
    else
      logwarn "No Brewfile found, skipping package installation"
    fi
    logk
    
    # Cleanup
    log_no_sudo "Cleaning up Homebrew..."
    brew cleanup
    logk
    log_to_file "INFO: Homebrew cleanup completed"
  fi
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_homebrew_and_packages
fi