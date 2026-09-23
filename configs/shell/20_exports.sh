# exports.sh - meant to be sourced in .bash_profile/.zshrc

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
export LESS="-R"  # Enable colors in less (avoid --mouse, breaks text selection)
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1  # Disable Claude Code auto-updater and telemetry
export PATH="$HOME/.local/bin:$PATH"

# -- Homebrew (needed below for brew --prefix)
if [ -f "/opt/homebrew/bin/brew" ]; then
   eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# -- Android / React Native
export ANDROID_HOME="$(brew --prefix)/share/android-commandlinetools"
# Without this the newer cmdline-tools honour XDG_CONFIG_HOME and look for
# AVDs under ~/.config/.android, while the emulator binary uses ~/.android —
# each tool then sees a different set of AVDs.
export ANDROID_USER_HOME="$HOME/.android"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
# Build only for the arch this Mac runs on — skips x86_64/armeabi NDK builds
export ORG_GRADLE_PROJECT_reactNativeArchitectures=arm64-v8a
