#!/usr/bin/env bash
# xcode.sh - Install and configure Xcode Command Line Tools

set -euo pipefail

# Load required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/scripts/lib/colors.sh"
source "$SCRIPT_DIR/scripts/lib/logging.sh"
source "$SCRIPT_DIR/scripts/lib/sudo.sh"

install_xcode_clt() {
  if [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then
    log_no_sudo "Xcode Command Line Tools already installed."
    logk
    log_to_file "INFO: Xcode CLT already installed"
    return 0
  fi
  
  log "Installing the Xcode Command Line Tools:"
  
  local CLT_STRING CLT_PLACEHOLDER CLT_PACKAGE
  CLT_STRING=".com.apple.dt.CommandLineTools.installondemand.in-progress"
  CLT_PLACEHOLDER="/tmp/$CLT_STRING"
  
  sudo_askpass touch "$CLT_PLACEHOLDER"
  
  CLT_PACKAGE=$(softwareupdate -l 2>/dev/null |
    grep -B 1 "Command Line Tools" |
    awk -F"*" '/^ *\*/ {print $2}' |
    sed -e 's/^ *Label: //' -e 's/^ *//' |
    sort -V |
    tail -n1)
  
  if [ -n "$CLT_PACKAGE" ]; then
    sudo_askpass softwareupdate -i "$CLT_PACKAGE"
  fi
  
  sudo_askpass rm -f "$CLT_PLACEHOLDER"
  
  if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then
    if [ "${STRAP_INTERACTIVE:-0}" -gt 0 ]; then
      echo
      logn "Requesting user install of Xcode Command Line Tools:"
      xcode-select --install
      echo
      echo -e "${YELLOW}Please wait for Xcode Command Line Tools installation to complete.${NC}"
      echo -e "${YELLOW}Press Enter when finished...${NC}"
      read -r
    else
      echo
      abort "Install Xcode Command Line Tools with 'xcode-select --install'."
    fi
  fi
  
  logk
  log_to_file "INFO: Xcode CLT installed"
}

check_xcode_license() {
  local Q=""
  [ "${STRAP_DEBUG:-0}" -eq 0 ] && Q="-q"
  
  # shellcheck disable=SC2086
  if /usr/bin/xcrun clang 2>&1 | grep $Q license; then
    if [ "${STRAP_INTERACTIVE:-0}" -gt 0 ]; then
      logn "Asking for Xcode license confirmation:"
      sudo_askpass xcodebuild -license
      logk
      log_to_file "INFO: Xcode license accepted"
    else
      abort "Run 'sudo xcodebuild -license' to agree to the Xcode license."
    fi
  else
    log_to_file "INFO: Xcode license already accepted"
  fi
}

check_software_updates() {
  logn "Checking for software updates:"
  
  local Q=""
  [ "${STRAP_DEBUG:-0}" -eq 0 ] && Q="-q"
  
  # shellcheck disable=SC2086
  if softwareupdate -l 2>&1 | grep $Q "No new software available."; then
    logk
    log_to_file "INFO: No software updates available"
  else
    if [ "${STRAP_CI:-0}" -eq 0 ]; then
      echo
      log "Installing software updates:"
      sudo_askpass softwareupdate --install --all
      check_xcode_license
      log_to_file "INFO: Software updates installed"
    else
      logskip "Skipping software updates (CI mode)."
    fi
    logk
  fi
}

install_xcode_tools() {
  if [ "${STRAP_ADMIN:-0}" -eq 0 ]; then
    logskip "Xcode Command-Line Tools install skipped (not admin)."
    return 0
  fi
  
  install_xcode_clt
  check_xcode_license
  check_software_updates
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_xcode_tools
fi