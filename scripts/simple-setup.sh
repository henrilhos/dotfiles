#!/usr/bin/env bash
#
# One-file macOS setup for people new to the Mac: no Nix, no dotbot, no
# repo clone. Installs Homebrew, a short list of tools and the React Native
# / Docker stack (Android emulator included), writes a small zsh config,
# and applies a few macOS defaults. Safe to re-run: packages
# already installed are skipped, and any config file it would replace is
# backed up next to the original as `<file>.bak` first.
#
# Usage:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/henrilhos/dotfiles/public/scripts/simple-setup.sh)"
#
# Options (env vars):
#   GIT_NAME, GIT_EMAIL  Git identity. Prompted for when unset and git has none.
#   AVD_NAME             Android emulator name (default: px)
#
set -euo pipefail

log() {
  echo "[setup] $*"
}

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script only supports macOS." >&2
  exit 1
fi

# Writes stdin to $1, backing up an existing file that differs.
write_config() {
  local target="$1" tmp
  tmp="$(mktemp)"
  cat >"$tmp"
  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" ]] && ! cmp -s "$tmp" "$target"; then
    log "Backing up $target to $target.bak"
    mv "$target" "$target.bak"
  fi
  mv "$tmp" "$target"
}

# --- 1. Xcode Command Line Tools (git, make, compilers) ---
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools..."
  xcode-select --install || true
  log "Finish the install in the popup, then re-run this script."
  exit 1
fi

# Homebrew refuses to run as root, so the script runs as the user and
# asks for sudo only where a step needs it.
if [[ "$EUID" -eq 0 ]]; then
  echo "Run this script without sudo; it asks for your password itself." >&2
  exit 1
fi

# --- 2. Homebrew ---
if ! command -v brew >/dev/null 2>&1 && [[ ! -x /opt/homebrew/bin/brew ]]; then
  # NONINTERACTIVE makes the installer use `sudo -n`, which only works
  # with a password already cached. Every `brew` command clears that cache
  # again, so later steps (Teams' .pkg, Touch ID) prompt on their own.
  log "Installing Homebrew. Enter your Mac password:"
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- 3. Packages ---
log "Installing packages..."
brew bundle --file=- <<'EOF'
# Shell
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# Nicer everyday commands
brew "bat"
brew "eza"
brew "fd"
brew "fzf"
brew "ripgrep"
brew "zoxide"

# Git
brew "gh"
brew "git-delta"

# Language runtimes (Node, Python, Java, ...), one tool for all of them
brew "mise"

# Mobile: iOS pods and the Android SDK, without Android Studio
brew "cocoapods"
cask "android-commandlinetools"

# Docker without Docker Desktop: colima runs the VM, docker is the CLI
brew "colima"
brew "docker"
brew "docker-compose"

# Apps
cask "claude-code@latest"
cask "dbeaver-community"
cask "ghostty"
cask "microsoft-teams"
cask "visual-studio-code"
EOF

# Teleport Connect is pinned to the version our cluster runs. The cask only
# tracks the latest release, so install the versioned .dmg directly.
TELEPORT_VERSION="18.5.1"
TELEPORT_APP="/Applications/Teleport Connect.app"
if [[ "$(defaults read "$TELEPORT_APP/Contents/Info" CFBundleShortVersionString 2>/dev/null || true)" != "$TELEPORT_VERSION" ]]; then
  log "Installing Teleport Connect $TELEPORT_VERSION..."
  dmg="$(mktemp -t teleport).dmg"
  mnt="$(mktemp -d)"
  curl -fsSL -o "$dmg" "https://cdn.teleport.dev/Teleport%20Connect-${TELEPORT_VERSION}.dmg"
  hdiutil attach -quiet -nobrowse -mountpoint "$mnt" "$dmg"
  rm -rf "$TELEPORT_APP"
  ditto "$mnt/Teleport Connect.app" "$TELEPORT_APP"
  hdiutil detach -quiet "$mnt"
  rm -f "$dmg"
fi

# --- 4. Shell ---
log "Writing ~/.zshrc..."
write_config "$HOME/.zshrc" <<'EOF'
# ~/.zshrc, written by dotfiles/scripts/simple-setup.sh

eval "$(/opt/homebrew/bin/brew shellenv)"
export EDITOR="code --wait"

# Android SDK from the android-commandlinetools cask. ANDROID_USER_HOME keeps
# sdkmanager and the emulator looking for AVDs in the same place.
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export ANDROID_USER_HOME="$HOME/.android"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
# React Native: build only for this Mac's arch, not x86 and 32-bit too.
export ORG_GRADLE_PROJECT_reactNativeArchitectures=arm64-v8a

# History: big, shared across tabs, no duplicates. A leading space keeps a
# command out of history.
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE

# Tab completion, case-insensitive, with an arrow-key menu.
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

alias ls='eza'
alias ll='eza -lah'
alias lt='eza --tree'
alias cat='bat'
alias gs='git status'
alias reload='source ~/.zshrc'

eval "$(zoxide init zsh)"    # `z <part of a path>` jumps to recent directories
eval "$(fzf --zsh)"          # Ctrl-R fuzzy history, Ctrl-T fuzzy file picker
eval "$(mise activate zsh)"  # per-project Node/Java/... versions, sets JAVA_HOME

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# Must stay last: it wraps every widget defined before it.
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF

# Silences the "Last login" banner in new terminals.
touch "$HOME/.hushlogin"

# --- 5. Terminal ---
write_config "$HOME/.config/ghostty/config" <<'EOF'
# Written by dotfiles/scripts/simple-setup.sh
# Options: https://ghostty.org/docs/config/reference
theme = Ayu
font-size = 14
cursor-style = block
shell-integration-features = no-cursor
confirm-close-surface = false
# Option works as Alt, so Option+Left/Right jump by word.
macos-option-as-alt = true
EOF

# --- 6. Git ---
log "Configuring git..."
if [[ -z "$(git config --global user.name || true)" ]]; then
  [[ -n "${GIT_NAME:-}" ]] || read -r -p "Your name for git commits: " GIT_NAME
  git config --global user.name "$GIT_NAME"
fi
if [[ -z "$(git config --global user.email || true)" ]]; then
  [[ -n "${GIT_EMAIL:-}" ]] || read -r -p "Your email for git commits: " GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
fi
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor "code --wait"
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true

write_config "$HOME/.config/git/ignore" <<'EOF'
.DS_Store
**/.claude/settings.local.json
EOF

# --- 7. Runtimes ---
# Java 17 is what React Native's Android build expects.
log "Installing Node LTS and Java 17..."
mise use --global node@lts java@temurin-17

# --- 8. Docker ---
# Lets `docker compose` find the Homebrew plugin.
if [[ ! -e "$HOME/.docker/config.json" ]]; then
  write_config "$HOME/.docker/config.json" <<'EOF'
{
  "auths": {},
  "currentContext": "colima",
  "cliPluginsExtraDirs": ["/opt/homebrew/lib/docker/cli-plugins"]
}
EOF
fi
# Create the VM once with room for real workloads (the default is 2 GB),
# then hand it to brew services so it starts at every login.
if [[ ! -e "$HOME/.colima/default/colima.yaml" ]]; then
  log "Creating the colima VM..."
  colima start --memory 6
  colima stop
fi
brew services start colima >/dev/null

# --- 9. Android emulator ---
# The React Native / Expo recipe from android-avd.sh: SDK packages plus
# one emulator. No NDK, RN 0.81+ ships prebuilt Android artifacts.
export JAVA_HOME="$(mise where java@temurin-17)"
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export ANDROID_USER_HOME="$HOME/.android"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
AVD_NAME="${AVD_NAME:-px}"
ANDROID_API="36.1"
SYSTEM_IMAGE="system-images;android-${ANDROID_API};google_apis;arm64-v8a"

log "Installing Android SDK packages (a few GB the first time)..."
yes | sdkmanager --licenses >/dev/null 2>&1 || true
# The stderr filter only drops sdkmanager's deprecation banner.
sdkmanager "platform-tools" "emulator" "build-tools;36.0.0" \
  "platforms;android-${ANDROID_API}" "$SYSTEM_IMAGE" \
  2> >(grep --line-buffered -Ev "sdkmanager\) is deprecated|'android' binary can also|Android CLI and how to use" >&2)

if ! avdmanager list avd 2>/dev/null | grep -q "Name: ${AVD_NAME}$"; then
  log "Creating the '$AVD_NAME' emulator..."
  # "no" skips the custom hardware profile prompt; the devices.xml error it
  # prints is noise.
  echo "no" | avdmanager create avd -n "$AVD_NAME" -d pixel_8 -k "$SYSTEM_IMAGE" \
    2>&1 | grep -v "devices.xml" || true
  # Host keyboard, GPU rendering and enough memory; the defaults are slow.
  cat >>"$ANDROID_USER_HOME/avd/${AVD_NAME}.avd/config.ini" <<'EOF'
hw.keyboard=yes
hw.gpu.enabled=yes
hw.gpu.mode=host
hw.ramSize=3G
vm.heapSize=256M
EOF
fi

# The RN template's 2 GB Gradle heap makes D8 run out of memory while
# dexing, which shows up as a misleading "Error while dexing".
write_config "$HOME/.gradle/gradle.properties" <<'EOF'
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g
EOF

# --- 10. macOS defaults ---
log "Applying macOS defaults..."
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark
# Autocorrect and smart quotes/dashes mangle code and commands.
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# Fast key repeat instead of the accent picker on press-and-hold.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Finder: show file extensions and hidden files.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
# Tap to click.
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# Dock: auto-hide, smaller icons, no recent apps.
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock show-recents -bool false
killall Dock Finder SystemUIServer 2>/dev/null || true

# --- 11. Touch ID for sudo ---
# sudo_local is the file macOS leaves alone on system updates.
if ! grep -qs pam_tid.so /etc/pam.d/sudo_local; then
  log "Enabling Touch ID for sudo (asks for your password)..."
  echo "auth       sufficient     pam_tid.so" | sudo tee /etc/pam.d/sudo_local >/dev/null
fi

log ""
log "Done! Quit Terminal and open Ghostty. Then, to finish:"
log "  gh auth login     # sign in to GitHub"
log "  gh auth setup-git # let git push and pull with that login"
log "Some settings (key repeat, trackpad) apply after you log out and back in."
log "Start the Android emulator with: emulator -avd $AVD_NAME"
