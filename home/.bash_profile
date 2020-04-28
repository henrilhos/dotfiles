# ~/.bash_profile

[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -f "$HOME/.config/broot/launcher/bash/br" ]] &&
    source $HOME/.config/broot/launcher/bash/br

[[ -s "$HOME/.rvm/scripts/rvm" ]] &&
    source "$HOME/.rvm/scripts/rvm"
