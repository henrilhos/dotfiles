#!/usr/bin/env bash
# git.sh - Configure Git

set -euo pipefail

# Load required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/scripts/lib/colors.sh"
source "$SCRIPT_DIR/scripts/lib/logging.sh"

configure_git() {
  logn_no_sudo "Configuring Git:"
  
  # CI-specific configuration
  if [ "${STRAP_CI:-0}" -gt 0 ]; then
    export XDG_CONFIG_HOME="$HOME/.config"
    mkdir -p "$XDG_CONFIG_HOME" && chmod -R 775 "$XDG_CONFIG_HOME"
    git config --global commit.gpgsign false
    git config --global gpg.format openpgp
    
    if ! git config --global core.attributesfile >/dev/null; then
      touch "$HOME/.gitattributes"
      git config --global core.attributesfile "$HOME/.gitattributes"
    fi
    
    if ! git config --global core.excludesfile >/dev/null; then
      touch "$HOME/.gitignore_global"
      git config --global core.excludesfile "$HOME/.gitignore_global"
    fi
  fi
  
  # User configuration
  if [ -n "${GIT_NAME:-}" ] && ! git config --global user.name >/dev/null 2>&1; then
    git config --global user.name "$GIT_NAME"
  fi
  
  if [ -n "${GIT_EMAIL:-}" ] && ! git config --global user.email >/dev/null 2>&1; then
    git config --global user.email "$GIT_EMAIL"
  fi
  
  if [ -n "${GIT_USERNAME:-}" ] && \
     [ "$(git config --global github.user 2>/dev/null || true)" != "$GIT_USERNAME" ]; then
    git config --global github.user "$GIT_USERNAME"
  fi
  
  # Set up GitHub HTTPS credentials
  if [ -n "${GIT_USERNAME:-}" ] && [ -n "${STRAP_GITHUB_TOKEN:-}" ]; then
    PROTOCOL="protocol=https\\nhost=github.com"
    printf "%s\\n" "$PROTOCOL" | git credential reject 2>/dev/null || true
    printf "%s\\nusername=%s\\npassword=%s\\n" \
      "$PROTOCOL" "$GIT_USERNAME" "$STRAP_GITHUB_TOKEN" |
      git credential approve 2>/dev/null || true
    log_to_file "INFO: GitHub credentials configured"
  else
    logskip "Skipping Git credential setup (no STRAP_GITHUB_TOKEN)."
  fi
  
  logk
  log_to_file "INFO: Git configured"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  configure_git
fi