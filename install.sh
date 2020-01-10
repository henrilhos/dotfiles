#!/bin/bash

# Export the path to this directory
export DOTFILES_PATH=$PWD

# Install fonts
yay -S ttf-joypixels ttf-croscore noto-fonts-cjk noto-fonts \
    ttf-fantasque-sans-mono ttf-linux-libertine ttf-fira-code

# Link font config files for better font display
sudo ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/75-joypixels.conf /etc/fonts/conf.d/

# Install Dash, then link dash to /bin/sh for a performance boost
yay -S dash
sudo ln -sfT dash /usr/bin/sh

# Install programs
yay -S rofi maim alacritty alacritty-terminfo picom neofetch neovim \
    feh sxhkd dunst diff-so-fancy exa fzf xclip openssh dbeaver bat \
    zsh-autosuggestions zsh-syntax-highlighting fd ripgrep navi sxiv \
    httpie docker docker-compose visual-studio-code-bin zsh arandr \
    pipes.sh slack-desktop spotify oh-my-zsh-git polybar-git ranger \
    nvm-git chromium gotop-bin qbittorrent dust eva mdcat onefetch \
    openresty postman pfetch-git studio-3t insomnia pyenv

# Remove programs
yay -R variety atom firefox geany sublime-text-dev termite vim

# Miscellaneous, but important
sudo install -Dm 644 miscellaneous/freetype2.sh /etc/profile.d/
sudo install -Dm 644 miscellaneous/local.conf /etc/fonts/
sudo install -Dm 644 miscellaneous/dashbinsh.hook /usr/share/libalpm/hooks/

# Make some folders. Screenshots will go in the captures folder.
mkdir -p $HOME/.config $HOME/Pictures/Captures $HOME/Pictures/Wallpapers \
    $HOME/Workspace/MLabs $HOME/Workspace/University $HOME/Workspace/Personal

# Link provided wallpapers to the wallpapers folder
cd $HOME/Pictures/Wallpapers
ln -sf $DOTFILES_PATH/wallpapers/* .

# Link all dotfiles into their appropriate locations
# cd $HOME
# ln -sf $DOTFILES_PATH/home/.* .

# cd $HOME/.config
# ln -sf $DOTFILES_PATH/config/* .

echo "Installation complete! Restart the computer."
