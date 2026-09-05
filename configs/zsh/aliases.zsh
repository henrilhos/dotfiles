# ~/dotfiles/configs/zsh/aliases.zsh
#
# One block per tool. Guard each with `command -v` so this file is safe
# to source even before `darwin-rebuild switch` has installed everything
# it references — same idea as dotbins' per-tool `shell_code`, just plain
# shell instead of a generated script.

alias ll='ls -lah'
alias gs='git status'

command -v nvim >/dev/null 2>&1 && alias vim='nvim'
