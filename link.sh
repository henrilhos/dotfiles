#!/bin/bash

# link font config files for better font display
sudo ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
sudo ln -sf /etc/fonts/conf.avail/75-joypixels.conf /etc/fonts/conf.d/
sudo fc-cache -f -v

export DOTFILES_PATH=$PWD

# Linking config folder
cd $HOME/.config
ln -sf $DOTFILES_PATH/config/* .
