#!/usr/bin/env bash
# dotfiles.sh - Setup dotfiles repository

set -euo pipefail

# Load required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/scripts/lib/colors.sh"
source "$SCRIPT_DIR/scripts/lib/logging.sh"
source "$SCRIPT_DIR/scripts/lib/utils.sh"
source "$SCRIPT_DIR/scripts/lib/validation.sh"

setup_dotfiles() {
  validate_dotfiles_url
  
  local Q=""
  [ "${STRAP_DEBUG:-0}" -eq 0 ] && Q="-q"
  
  # Clone dotfiles if not present
  if [ ! -d "$HOME/.dotfiles" ]; then
    if [ -z "${DOTFILES_URL:-}" ] || [ -z "${DOTFILES_BRANCH:-}" ]; then
      abort "Please set DOTFILES_URL and DOTFILES_BRANCH."
    fi
    log_no_sudo "Cloning $DOTFILES_URL to $HOME/.dotfiles."
    # shellcheck disable=SC2086
    git clone $Q "$DOTFILES_URL" "$HOME/.dotfiles"
    log_to_file "INFO: Dotfiles cloned from $DOTFILES_URL"
  else
    log_no_sudo "Dotfiles directory already exists."
  fi
  
  # Checkout and update dotfiles
  local strap_dotfiles_branch_name
  strap_dotfiles_branch_name="${DOTFILES_BRANCH##*/}"
  log_no_sudo "Checking out $strap_dotfiles_branch_name in $HOME/.dotfiles."
  
  # (
  #   cd "$HOME/.dotfiles"
  #   # shellcheck disable=SC2086
  #   git stash $Q 2>/dev/null || true
  #   # shellcheck disable=SC2086
  #   git fetch $Q
  #   git checkout "$strap_dotfiles_branch_name"
  #   # shellcheck disable=SC2086
  #   git pull $Q --rebase --autostash
  # )
  
  # Run symlink script
  run_dotfile_scripts scripts/symlink.sh
  
  logk
  log_to_file "INFO: Dotfiles configured"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_dotfiles
fi