#!/usr/bin/env bash

set -euo pipefail

# Script metadata
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPTS_DIR="$SCRIPT_DIR/scripts"
readonly LIB_DIR="$SCRIPTS_DIR/lib"
readonly SETUP_DIR="$SCRIPTS_DIR/setup"

# Load core libraries
source "$LIB_DIR/colors.sh"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"
source "$LIB_DIR/validation.sh"
source "$LIB_DIR/sudo.sh"

# Configuration
readonly HOMEBREW_PREFIX="/opt/homebrew"
readonly LOG_FILE="${LOG_FILE:-/tmp/bootstrap_$(date +%Y%m%d_%H%M%S).log}"

# Variables
STRAP_ADMIN=${STRAP_ADMIN:-0}
if groups | grep -qE "\b(admin)\b"; then STRAP_ADMIN=1; else STRAP_ADMIN=0; fi
export STRAP_ADMIN

STRAP_CI=${STRAP_CI:=0}
STRAP_DEBUG=${STRAP_DEBUG:-0}
[[ ${1:-} = "--debug" || -o xtrace ]] && STRAP_DEBUG=1

STRAP_INTERACTIVE=${STRAP_INTERACTIVE:-0}
STDIN_FILE_DESCRIPTOR=0
[ -t "$STDIN_FILE_DESCRIPTOR" ] && STRAP_INTERACTIVE=1

GIT_USERNAME=${GIT_USERNAME:="henrilhos"}
DEFAULT_DOTFILES_URL="https://github.com/$GIT_USERNAME/dotfiles"
DOTFILES_URL=${DOTFILES_URL:="$DEFAULT_DOTFILES_URL"}
DOTFILES_BRANCH=${DOTFILES_BRANCH:="main"}

STRAP_SUCCESS=""
STRAP_SUDO=0

# Export variables for child scripts
export STRAP_CI STRAP_DEBUG STRAP_INTERACTIVE STRAP_SUDO
export GIT_USERNAME DOTFILES_URL DOTFILES_BRANCH
export HOMEBREW_PREFIX LOG_FILE SCRIPT_DIR

# Setup error handling
trap 'error_handler ${LINENO}' ERR
trap 'cleanup' EXIT

if [ "$STRAP_DEBUG" -gt 0 ]; then
  set -x
  log_to_file "DEBUG: Debug mode enabled"
fi

# Main execution
main() {
  # Verify environment
  check_os_and_arch
  [ "$USER" = "root" ] && abort "Run bootstrap.sh as yourself, not root."

  log_no_sudo "Starting bootstrap process..."
  log_no_sudo "Log file: $LOG_FILE"
  log_to_file "========================================="
  log_to_file "Bootstrap started"
  log_to_file "OS: $(uname -s) $(uname -r)"
  log_to_file "Architecture: $(uname -m)"
  log_to_file "User: $USER"
  log_to_file "========================================="

  # Validate environment
  validate_required_vars
  check_prerequisites

  # Keep system awake during installation (admin only)
  if [ "$STRAP_ADMIN" -gt 0 ] && [ "$STRAP_CI" -eq 0 ]; then
    # shellcheck disable=SC2086
    caffeinate -s -w $$ &
    log_to_file "INFO: Caffeinate started to prevent sleep"
  fi

  # Check admin permissions
  if [ "$STRAP_ADMIN" -gt 0 ]; then
    groups | grep -qE "\b(admin)\b" || abort "Add $USER to admin group."
  fi

  # System configuration (admin only)
  if [ "$STRAP_ADMIN" -gt 0 ]; then
    log_section "System Configuration"

    run_script "$SETUP_DIR/macos-security.sh" || abort "Security setup failed"
    run_script "$SETUP_DIR/macos-filevault.sh" || abort "FileVault setup failed"
    run_script "$SETUP_DIR/xcode.sh" || abort "Xcode setup failed"
  else
    log_no_sudo "Skipping admin-only tasks (not in admin group)."
  fi

  # Development setup
  log_section "Development Setup"

  run_script "$SETUP_DIR/git.sh" || abort "Git setup failed"
  run_script "$SETUP_DIR/dotfiles.sh" || abort "Dotfiles setup failed"
  run_script "$SETUP_DIR/homebrew.sh" || abort "Homebrew setup failed"

  # Post-installation
  log_section "Post-Installation"

  if [ -f "$SCRIPTS_DIR/strap-after-setup.sh" ]; then
    run_script "$SCRIPTS_DIR/strap-after-setup.sh"
  fi

  # Success!
  STRAP_SUCCESS=1
  echo
  echo -e "${GREEN}=========================================${NC}"
  echo -e "${GREEN}✅ Your system is now bootstrapped!${NC}"
  echo -e "${GREEN}=========================================${NC}"
  echo -e "${BLUE}📝 Log file: $LOG_FILE${NC}"
  log_to_file "========================================="
  log_to_file "Bootstrap completed successfully"
  log_to_file "========================================="
}

# Execute main
main "$@"

