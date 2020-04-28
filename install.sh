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
make -j8
sudo make install

# Install Polybar
sudo apt install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
	libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev \
	libxcb-xkb-dev pkg-config python3-xcbgen xcb-proto libxcb-xrm-dev libasound2-dev \
	libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev \
	libxcb-composite0-dev xcb libxcb-ewmh2 libjsoncpp-dev

cd /tmp
git clone https://github.com/polybar/polybar.git
cd polybar
sudo ./build.sh

# Install DE programs
sudo apt install -y i3xrocks i3ipc-python i3status rofi dmenu feh compton

# Install interface programs
# Visual Studio Code
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt install -y apt-transport-https

# Vivaldi
sudo sh -c 'echo "deb http://repo.vivaldi.com/stable/deb/ stable main" >> /etc/apt/sources.list'
wget -q -O - http://repo.vivaldi.com/stable/linux_signing_key.pub | sudo apt-key add -

# Brave
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# Telegram
sudo add-apt-repository ppa:atareao/telegram

# Spotify
sudo sh -c "echo 'deb http://repository.spotify.com stable non-free' >> /etc/apt/sources.list.d/spotify.list"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90

sudo apt update
sudo apt install -y kitty code vivaldi-stable firefox brave-browser slack-desktop \
	snapd telegram spotify-client

sudo snap install rocketchat-desktop

# Runs autoremove
sudo apt autoremove -y

# Oh My Zsh
sudo apt install -y Zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
