#!/bin/bash

export DOTFILES_PATH=$PWD

# Update system
sudo apt update
sudo apt upgrade -y

# Adds Regolith and Speed Ricer PPA
sudo add-apt-repository -y ppa:regolith-linux/release
# Speed ricer is not available for 20.04 yet
#sudo add-apt-repository -y ppa:kgilmer/speed-ricer
sudo apt update

# Install i3 gaps
sudo apt install -y libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev \
	libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev \
	libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev \
	libxbcommon-x11-dev autoconf xutils-dev libtool automake libxcb-xrm-dev libxcb-shape0-dev

cd /tmp
git clone https://github.com/Airblader/i3 i3-gaps
cd i3-gaps
git checkout gaps && git pull
autoreconf --force --install
rm -rf build
mkdir build && cd build
../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
make
sudo make install

# Runs autoremove
sudo apt autoremove -y
