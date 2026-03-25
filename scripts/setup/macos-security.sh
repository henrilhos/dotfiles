#!/usr/bin/env bash
# macos-security.sh - Configure macOS security settings

set -euo pipefail

# Load required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/scripts/lib/colors.sh"
source "$SCRIPT_DIR/scripts/lib/logging.sh"
source "$SCRIPT_DIR/scripts/lib/sudo.sh"

configure_security_settings() {
  if [ "${STRAP_ADMIN:-0}" -eq 0 ] || [ "${STRAP_CI:-0}" -gt 0 ]; then
    logskip "Skipping security settings configuration (not admin or CI mode)."
    return 0
  fi
  
  logn "Configuring security settings:"
  
  # Disable Java in Safari
  SAFARI="com.apple.Safari"
  sudo_askpass defaults write $SAFARI \
    $SAFARI.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false 2>/dev/null || true
  sudo_askpass defaults write $SAFARI \
    $SAFARI.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles \
    -bool false 2>/dev/null || true
  
  # Require password immediately after screensaver
  local screensaver_password
  screensaver_password=$(defaults read com.apple.screensaver askForPassword 2>/dev/null || echo "0")
  if [ "$screensaver_password" != "1" ]; then
    sudo_askpass defaults write com.apple.screensaver askForPassword -int 1
    sudo_askpass defaults write com.apple.screensaver askForPasswordDelay -int 0
  fi
  
  # Enable firewall
  sudo_askpass defaults write \
    /Library/Preferences/com.apple.alf globalstate -int 1 2>/dev/null || true
  sudo_askpass launchctl load \
    /System/Library/LaunchDaemons/com.apple.alf.agent.plist 2>/dev/null || true
  
  # Set login window message
  if [ -n "${GIT_NAME:-}" ] && [ -n "${GIT_EMAIL:-}" ]; then
    FOUND="Found this computer? Please contact"
    LOGIN_TEXT="$FOUND ${GIT_NAME} at ${GIT_EMAIL}."
    sudo_askpass defaults write \
      /Library/Preferences/com.apple.loginwindow LoginwindowText "$LOGIN_TEXT" 2>/dev/null || true
  fi
  
  logk
  log_to_file "INFO: Security settings configured"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  configure_security_settings
fi