# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export HISTCONTROL=ignoreboth:erasedups

PS1='[\u@\h \W]\$ '

if [ -d "$HOME/.bin" ]; then
    PATH="$HOME/.bin:$PATH"
fi

# List
alias ls='exa -F'
alias l='exa -FGhl --git'
alias la='exa -FGa'
alias lla='exa -FGhla'
alias ll='l'
alias l.="lla | grep '^\.'"
alias ltree='exa -FThl --git'
alias tree='exa -FT'
alias rls='exa -FR'

# Fix obvious typo's
alias cd..='cd ..'
alias pdw='pwd'
alias udpate='sudo pacman -Syyu'
alias upate='sudo pacman -Syyu'

# Colorize the grep command output for ease of use (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Readable output
alias df='df -h'

# Pacman unlock
alias unlock="sudo rm /var/lib/pacman/db.lck"

# Free
alias free="free -mt"

# Use all cores
alias uac="sh ~/.bin/main/000*"

# Continue download
alias wget="wget -c"

# Userlist
alias userlist="cut -d: -f1 /etc/passwd"

# Merge new settings
alias merge="xrdb -merge ~/.Xresources"

# Aliases for software managment
# pacman or pm
alias pacman='sudo pacman --color auto'
alias update='sudo pacman -Syyu'

# yay as aur helper - updates everything
alias yay="yay -S --mflags --skipinteg"
alias pksyua="yay -Syu --noconfirm --mflags --skipinteg"
alias upall="yay -Syu --noconfirm --mflags --skipinteg"

# ps
alias ps="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"

# Grub update
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"

# Improve png
alias fixpng="find . -type f -name "*.png" -exec convert {} -strip {} \;"

# Add new fonts
alias fc='sudo fc-cache -fv'

# Copy/paste all content of /etc/skel over to home folder - Beware
alias skel='cp -rf /etc/skel/* ~'
# Backup contents of /etc/skel to hidden backup folder in home/user
alias bupskel='cp -Rf /etc/skel ~/.skel-backup-$(date +%Y.%m.%d-%H.%M.%S)'

# Copy bashrc-latest over on bashrc - cb= copy bashrc
alias cb="cp ~/.bashrc-latest ~/.bashrc && source ~/.bashrc && sudo cp /etc/skel/.bashrc-latest /etc/skel/.bashrc"

# Hardware info --short
alias hw="hwinfo --short"

# Check vulnerabilities microcode
alias microcode='grep . /sys/devices/system/cpu/vulnerabilities/*'

# Get fastest mirrors in your neighborhood
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Mounting the folder Public for exchange between host and guest on virtualbox
alias vbm="sudo mount -t vboxsf -o rw,uid=1000,gid=1000 Public /home/$USER/Public"

# shopt
shopt -s autocd         # change to named directory
shopt -s cdspell        # autocorrects cd misspellings
shopt -s cmdhist        # save multi-line commands in history as single line
shopt -s histappend     # do not overwrite history
shopt -s expand_aliases # expand aliases
shopt -s dotglob

# youtube-dl
alias yta-aac="youtube-dl --extract-audio --audio-format aac "
alias yta-best="youtube-dl --extract-audio --audio-format best "
alias yta-flac="youtube-dl --extract-audio --audio-format flac "
alias yta-m4a="youtube-dl --extract-audio --audio-format m4a "
alias yta-mp3="youtube-dl --extract-audio --audio-format mp3 "
alias yta-opus="youtube-dl --extract-audio --audio-format opus "
alias yta-vorbis="youtube-dl --extract-audio --audio-format vorbis "
alias yta-wav="youtube-dl --extract-audio --audio-format wav "

alias ytv-best="youtube-dl -f bestvideo+bestaudio "

# Recent Installed Packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -100"

# Cleanup orphaned packages
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'

# get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# nano
alias nlightdm="sudo nano /etc/lightdm/lightdm.conf"
alias npacman="sudo nano /etc/pacman.conf"
alias ngrub="sudo nano /etc/default/grub"
alias nmkinitcpio="sudo nano /etc/mkinitcpio.conf"
alias nslim="sudo nano /etc/slim.conf"
alias noblogout="sudo nano /etc/oblogout.conf"

# shutdown or reboot
alias ssn="sudo shutdown now"
alias sr="sudo reboot"

[[ -f ~/.profile ]] && . ~/.profile
