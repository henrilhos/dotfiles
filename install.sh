#!/bin/bash

# Export the path to this directory
export DOTFILES_PATH=$PWD

# Install fonts and programs
sudo pacman -S ttf-joypixels ttf-croscore noto-fonts-cjk noto-fonts \
    ttf-fantasque-sans-mono ttf-linux-libertine rofi mpv maim \
    alacritty alacritty-terminfo compton neofetch dash neovim \
    feh sxhkd bspwm i3-gaps dunst zathura-pdf-mupdf libnotify \
    diff-so-fancy zsh-autosuggestions zsh-syntax-highlighting \
    xorg-server xorg-xinit xorg-xprop pulseaudio-alsa exa fzf \
    xclip openssh

# read -p "-- For music, use mpd + ncmpcpp instead of cmus? [y/N] " yna
# case $yna in
# [Yy]*)
#     sudo pacman -S mpd ncmpcpp
#     patch home/.xinitrc <other/add-mpd.patch
#     ;;
# *) sudo pacman -S cmus ;;
# esac

# Optionally install some more programs. Including a file manager,
# find, cat, grep, and curl replacements. And a powerful image viewer.
# read -p "-- Install extras? (nnn fd bat ripgrep httpie sxiv fzf) [Y/n] " ynb
# case $ynb in
# '' | [Yy]*)
#     sudo pacman -S nnn fd bat ripgrep httpie sxiv fzf
#     patch home/.zshrc <other/add-fzf.patch
#     ;;
# *) echo "-- Extras Skipped" ;;
# esac

# Install AUR packages
yay -S oh-my-zsh-git polybar-git brave-bin slack-desktop \
    visual-studio-code-bin nvm

# Link dash to /bin/sh for performance boost.
# Then link several font config files for better font display.
sudo ln -sfT dash /usr/bin/sh
sudo ln -sf /etc/fonts/conf.avail/75-joypixels.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/

# Misc but important. The last disables mouse acceleration and can be removed.
sudo install -Dm 644 other/freetype2.sh /etc/profile.d/
sudo install -Dm 644 other/local.conf /etc/fonts/
sudo install -Dm 644 other/dashbinsh.hook /usr/share/libalpm/hooks/

# Make some folders. Screenshots will go in the captures folder.
mkdir -p $HOME/.config $HOME/Images/Captures $HOME/Images/Wallpapers \
    $HOME/Workspace/MLabs $HOME/Workspace/University $HOME/Workspace/Personal \
    $DOTFILES_PATH/config/mpd/playlists $HOME/Music

# Link provided wallpapers to the wallpapers folder
cd $HOME/Images/Wallpapers
ln -sf $DOTFILES_PATH/wallpapers/* .

# Link all dotfiles into their appropriate locations
cd $HOME
ln -sf $DOTFILES_PATH/home/.* .

cd $HOME/.config
ln -sf $DOTFILES_PATH/config/* .

echo "Installation complete! Restart the computer."
