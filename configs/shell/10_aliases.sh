# aliases.sh - meant to be sourced in .bash_profile/.zshrc

if [[ $- == *i* ]]; then
  alias cdw="cd ~/Work/ "
  alias cdc="cd ~/Code/ "
  alias py="python"
  alias nv="nvim"
  alias ccat="command cat"
  alias gs="git status"
  alias gdom='git diff origin/main'
  alias grhom='git reset --hard origin/main'
  alias grsom='git reset --soft origin/main'
  alias c='clear'
  alias e='exit'
  alias ..='cd ..'
  alias cl='claude --dangerously-skip-permissions '
  alias y='yazi '
  alias ss='open -b com.apple.ScreenSaver.Engine'
  alias reload='source ~/.zshrc'
  alias ll='eza -lah'
  alias ls='eza'
  alias lt='eza --tree'
  alias vim='nvim'
  alias lg='lazygit'
  alias cat='bat'
  alias nixswitch="sudo darwin-rebuild switch --flake ~/dotfiles/configs/nix-darwin"
  alias nixupdate="cd ~/dotfiles/configs/nix-darwin && nix flake update --extra-experimental-features nix-command --extra-experimental-features flakes && nixswitch && cd -"

  nosleep() {
    sudo pmset -a disablesleep 1
  }
  sleepok() {
    sudo pmset -a disablesleep 0
  }
fi
