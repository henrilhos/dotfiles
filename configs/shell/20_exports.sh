# exports.sh - meant to be sourced in .bash_profile/.zshrc

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
export LESS="-R"  # Enable colors in less (avoid --mouse, breaks text selection)
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1  # Disable Claude Code auto-updater and telemetry
export PATH="$HOME/.local/bin:$PATH"
