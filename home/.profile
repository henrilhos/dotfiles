export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR="/usr/bin/nvim"
export VISUAL="/usr/bin/nvim"
export BROWSER="/usr/bin/chromium"

export CORP="$HOME/Workspace/MLabs/CORP"

alias vi=nvim
alias vim=nvim
alias copy="xclip -se c"

alias cp="cp -i" # Confirm before overwriting something
alias np='nano -w PKGBUILD'
alias more=less

source /usr/share/nvm/init-nvm.sh
source ~/.config/broot/launcher/bash/br

alias mlabs="cd $HOME/Workspace/MLabs"
alias university="cd $HOME/Workspace/University"
alias personal="cd $HOME/Workspace/Personal"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
