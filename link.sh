#!/bin/bash

export DOTFILES_PATH=$PWD

# Linking config folder
cd $HOME/.config
ln -sf $DOTFILES_PATH/config/* .
