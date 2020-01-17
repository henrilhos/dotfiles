#!/bin/bash

# Export the path to this directory
export DOTFILES_PATH=$PWD

# Install fonts
yay -Sy ttf-joypixels ttf-croscore noto-fonts-cjk noto-fonts \
    ttf-fantasque-sans-mono ttf-linux-libertine ttf-fira-code \
    ttf-typicons

# Link font config files for better font display
sudo ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/75-joypixels.conf /etc/fonts/conf.d/

# Install programs
yay -Sy arandr bat chromium dbeaver diff-so-fancy docker docker-compose dunst dust \
    eva exa fd feh fzf gotop-bin httpie i3lock insomnia kitty kitty-terminfo maim \
    navi neofetch neovim nvm-git oh-my-zsh-git onefetch openfortivpn openresty \
    openssh pfetch-git picom pipes.sh polybar-git postman pyenv qbittorrent ranger \
    ripgrep rocketchat-desktop slack-desktop spotify studio-3t sxhkd sxiv \
    visual-studio-code-bin whatsapp-nativefier-dark xclip zsh zsh-autosuggestions \
    zsh-syntax-highlighting

# Remove programs
yay -R arcolinux-conky-collection-git atom conky-lua-archers firefox geany \
    gmrun pragha sublime-text-dev termite termite-terminfo variety vi vim \
    vivaldi vivaldi-codecs-ffmpeg-extra-bin

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
