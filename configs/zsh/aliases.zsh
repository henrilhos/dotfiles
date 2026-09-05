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
alias e='exit'
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
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
  # Dracula theme: https://github.com/dracula/fzf
  export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
fi
command -v bat >/dev/null 2>&1 && alias cat='bat'
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
# --shims instead of the full activate hook: a one-time PATH prepend
# instead of a precmd hook that re-runs `mise hook-env` on every prompt
# (measured ~12ms/prompt) — worth it since config.toml only pins plain
# runtime versions, no dynamic env vars to track.
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh --shims)"

# Open sesh's fzf picker straight from zsh (outside tmux, it just attaches
# to/creates the session — no need to already be in one).
command -v sesh >/dev/null 2>&1 && alias sc='sesh connect "$(sesh list --icons | fzf --ansi --height 40% --reverse --border-label " sesh " --border --prompt "⚡  ")"'
