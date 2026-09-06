# misc.sh - meant to be sourced in .bash_profile/.zshrc

# -- Homebrew
if [ -f "/opt/homebrew/bin/brew" ]; then
   eval "$(/opt/homebrew/bin/brew shellenv)"
fi
