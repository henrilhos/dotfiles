# main.sh - can be sourced in .bash_profile/.bashrc or .zshrc

[ -n "$BASH_VERSION" ] && source ~/dotfiles/configs/shell/00_prefer_zsh.sh  # no-op in zsh
[ -n "$ZSH_VERSION" ] && source ~/dotfiles/configs/shell/05_zsh_completions.sh
source ~/dotfiles/configs/shell/10_aliases.sh
source ~/dotfiles/configs/shell/20_exports.sh
source ~/dotfiles/configs/shell/30_misc.sh
[ -n "$ZSH_VERSION" ] && source ~/dotfiles/configs/shell/40_zsh_plugins.sh
