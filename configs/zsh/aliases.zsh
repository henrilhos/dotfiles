# ~/dotfiles/configs/zsh/aliases.zsh
#
# One block per tool. Guard each with `command -v` so this file is safe
# to source even before `darwin-rebuild switch` has installed everything
# it references — same idea as dotbins' per-tool `shell_code`, just plain
# shell instead of a generated script.

alias ll='ls -lah'
alias gs='git status'
alias gc='git commit'
alias ga='git add'
alias gp='git push'
alias gco='git checkout'
alias c='clear'
alias ..='cd ..'
alias reload='source ~/.zshrc'

command -v nvim >/dev/null 2>&1 && alias vim='nvim'
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -lah'
  alias lt='eza --tree'
fi

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd cd)"
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"
