#!/usr/bin/env bash
# strap-after-setup.sh - Post-installation tasks

set -euo pipefail

# Load required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/scripts/lib/colors.sh"
source "$SCRIPT_DIR/scripts/lib/logging.sh"

post_install_tasks() {
  log_no_sudo "Running post-installation tasks..."

  # Set fish as default shell
  set_default_shell

  # Additional customizations
  apply_macos_preferences

  logk
  log_to_file "INFO: Post-installation tasks completed"
}

set_default_shell() {
  local current_shell fish_path
  current_shell=$(dscl . -read ~/ UserShell | awk '{print $2}')
  fish_path=$(command -v fish)

  if [ "$current_shell" = "$fish_path" ]; then
    log_no_sudo "Default shell is already fish."
    return 0
  fi

  log_no_sudo "Setting fish as default shell..."

  # Add fish to /etc/shells if not present
  if ! grep -q "$fish_path" /etc/shells 2>/dev/null; then
    echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
  fi

  # Change default shell
  if chsh -s "$fish_path" 2>/dev/null; then
    log_no_sudo "Default shell changed to fish."
    log_to_file "INFO: Default shell changed to fish"
  else
    logwarn "Could not change default shell. You may need to run: chsh -s $fish_path"
    log_to_file "WARNING: Could not change default shell automatically"
  fi
}

apply_macos_preferences() {
  log_no_sudo "Applying macOS preferences..."

  # Enable dark mode
  defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
  defaults write NSGlobalDomain AppleAccentColor -string "-1"
  defaults write NSGlobalDomain AppleHighlightColor -string \
    "0.847059 0.847059 0.862745 Graphite"

  # Use metric units
  defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
  defaults write NSGlobalDomain AppleMetricUnits -bool true
  defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"

  # Set menu bar clock format
  defaults write com.apple.menuextra.clock IsAnalog -bool false
  defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM HH:mm"

  # Set the timezone; see `sudo systemsetup -listtimezones` for other values
  sudo systemsetup -settimezone "America/Sao_Paulo" >/dev/null

  # Disable automatic text substitution and autocorrect
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  # Disable press-and-hold for keys in favor of key repeat
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  # Increase key repeat rate
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15

  # Disable “natural” scrolling
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

  # Use keyboard navigation to move focus between controls (tab navigation)
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  # Finder: show hidden files by default
  defaults write com.apple.finder AppleShowAllFiles -bool true

  # Finder: show all filename extensions
  # defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Finder: show status bar
  defaults write com.apple.finder ShowStatusBar -bool true

  # Finder: show path bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  # Auto-hide menu bar
  # defaults write NSGlobalDomain _HIHideMenuBar -bool true

  # Change minimize/maximize window effect
  # defaults write com.apple.dock mineffect -string "genie"

  # Minimize windows into their application’s icon
  defaults write com.apple.dock minimize-to-application -bool true

  # Show indicator lights for open applications in the Dock
  defaults write com.apple.dock show-process-indicators -bool true

  # Wipe default macOS app icons from the Dock
  # Useful for setting up new Macs. Optionally relaunch dock with `killall Dock`.
  defaults write com.apple.dock persistent-apps -array

  # Group windows by application in Mission Control
  defaults write com.apple.dock expose-group-by-app -bool true

  # Disable Dashboard
  defaults write com.apple.dashboard mcx-disabled -bool true

  # Don’t show Dashboard as a Space
  defaults write com.apple.dock dashboard-in-overlay -bool true

  # Remove the auto-hiding Dock delay
  defaults write com.apple.dock autohide-delay -float 0

  # Remove the animation when hiding/showing the Dock
  defaults write com.apple.dock autohide-time-modifier -float 0

  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true

  # Make Dock icons of hidden applications translucent
  defaults write com.apple.dock showhidden -bool true

  # Don’t show recent applications in Dock
  defaults write com.apple.dock show-recents -bool false

  # Configure network services
  if networksetup -listallnetworkservices | grep -q "Ethernet"; then
    networksetup -setdhcp "Ethernet"
  fi

  # Use plain text mode for new TextEdit documents
  defaults write com.apple.TextEdit RichText -int 0

  # Open and save files as UTF-8 in TextEdit
  defaults write com.apple.TextEdit PlainTextEncoding -int 4
  defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

  log_to_file "INFO: macOS preferences applied"

  # Restart affected applications
  log_no_sudo "Restarting affected applications..."

  for app in "Dock" "Finder"; do
    killall "$app" &>/dev/null || true
  done

  log_to_file "INFO: Applications restarted"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  post_install_tasks
fi
