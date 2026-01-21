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

if test -f ~/.config/fish/secrets.fish
    source ~/.config/fish/secrets.fish
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

set -Ux JAVA_HOME /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
set -Ux ANDROID_HOME $HOME/Library/Android/sdk

fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/platform-tools

# Created by `pipx` on 2025-09-04 22:43:16
set PATH $PATH ~/.local/bin

# opencode
fish_add_path /Users/henrilhos/.opencode/bin

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
