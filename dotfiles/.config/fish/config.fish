eval (/opt/homebrew/bin/brew shellenv)

zoxide init fish | source
fzf --fish | source

set -U fish_greeting
set -U fish_key_binding fish_vi_key_bindings
set -U pisces_only_insert_at_eol 1

set -Ux EDITOR nvim
set -Ux FZF_DEFAULT_COMMAND "fd -H -E '.git'"
set -Ux MISE_OVERRIDE_TOOL_VERSIONS_FILENAMES none
set -Ux ANDROID_HOME $HOME/Library/Android/sdk

fish_add_path $HOME/.config/bin
fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/platform-tools

fish_config theme choose "Catppuccin Mocha"

if test -f $HOME/.config/fish/secrets.fish
    source $HOME/.config/fish/secrets.fish
end

# Mole shell completion
set -l output (mole completion fish 2>/dev/null); and echo "$output" | source

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Auto-activate Python virtualenv when entering a directory with .venv
function auto_venv --on-variable PWD
    if test -f .venv/bin/activate.fish
        source .venv/bin/activate.fish
    else if set -q VIRTUAL_ENV
        deactivate 2>/dev/null
    end
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
export PATH="$HOME/.local/bin:$PATH"
