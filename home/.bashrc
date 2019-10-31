# ~/.bashrc

alias startx="startx ~/.xinitrc"

alias vi=nvim
alias vim=nvim

alias ls='exa -F'
alias l='exa -FGhl --git'
alias ltree='exa -FThl --git'
alias tree='exa -FT'
alias rls='exa -FR'

alias cp="cp -i" # Confirm before overwriting something
alias df='df -h' # Human-readable sizes
alias free='free -m' # Show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less

PS1='\u@\h \W \$ '

source /usr/share/nvm/init-nvm.sh

