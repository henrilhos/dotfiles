eval (/opt/homebrew/bin/brew shellenv)

starship init fish | source # https://starship.rs/
zoxide init fish | source # 'ajeetdsouza/zoxide'
fzf --fish | source
# fnm --log-level quiet env --use-on-cd | source # 'Schniz/fnm'
direnv hook fish | source # https://direnv.net/
fx --comp fish | source # https://fx.wtf/
set -g direnv_fish_mode eval_on_arrow # trigger direnv at prompt, and on every arrow-based directory change (default)

set -U fish_greeting # disable fish greeting

set -U fish_key_binding fish_vi_key_bindings

set -Ux EDITOR nvim # 'neovim/neovim' text editor
set -Ux FZF_DEFAULT_COMMAND "fd -H -E '.git'"

fish_add_path $HOME/.config/bin # my custom scripts
