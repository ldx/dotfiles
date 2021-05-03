#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi
codename="$(lsb_release -c | awk '{print $2}')"
if [[ -z "$codename" ]]; then
    echo "Failed to detect distro codename"
    exit 1
fi
provisioning_user="$SUDO_USER"
if [[ -z "$provisioning_user" ]]; then
    echo "Failed to detect user"
    exit 1
fi

homedir="/home/$provisioning_user"
curdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p /usr/local

# Required packages.
apt-get update -y
apt-get install -y apt-transport-https gpg

apt-key adv --keyserver pool.sks-keyservers.net \
    --recv-keys 78BD65473CB3BD13 1C61A2656FB57B7E4DE0F4C1FC918B335044912E A2F683C52980AECF

rm -rf /etc/apt/sources.list.d/*
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
echo "deb http://httpredir.debian.org/debian/ $codename main contrib non-free" > /etc/apt/sources.list.d/nonfree.list

apt-get update -y
apt-get install -y \
    acpi \
    acpica-tools \
    acpi-support \
    acpitool \
    ansible \
    autoconf \
    autocutsel \
    automake \
    autossh \
    autotools-dev \
    bash-completion \
    bc \
    bison \
    blueman \
    bluetooth \
    bluez \
    bridge-utils \
    build-essential \
    busybox \
    bzip2 \
    ca-certificates \
    clang \
    clusterssh \
    cmake \
    cpp \
    cpufrequtils \
    cscope \
    cups \
    curl \
    daemontools \
    debootstrap \
    desktop-base \
    devscripts \
    direnv \
    dnsutils \
    dput \
    ebtables \
    ed \
    encfs \
    evince \
    exuberant-ctags \
    fakeroot \
    file \
    firmware-iwlwifi \
    flex \
    fontconfig \
    fontconfig-config \
    fonts-crosextra-caladea \
    fonts-crosextra-carlito \
    fonts-dejavu \
    fonts-dejavu \
    fonts-dejavu-core \
    fonts-dejavu-extra \
    fonts-freefont-ttf \
    fonts-inconsolata \
    fonts-lato \
    fonts-liberation2 \
    fonts-linuxlibertine \
    fonts-lmodern \
    fonts-lyx \
    fonts-opensymbol \
    fonts-sil-gentium \
    fonts-sil-gentium-basic \
    fonts-texgyre \
    fonts-vlgothic \
    ftp \
    fuse \
    g++ \
    gawk \
    gcc \
    gccgo \
    gcc-multilib \
    gdb \
    ghc \
    ghc-doc \
    ghostscript \
    gimp \
    git \
    git-man \
    git-svn \
    g++-multilib \
    gnupg \
    gocryptfs \
    google-chrome-stable \
    grep \
    groff-base \
    gthumb \
    gzip \
    htop \
    hxtools \
    iftop \
    imagemagick \
    info \
    iotop \
    iproute2 \
    ipset \
    iptables \
    iw \
    jq \
    laptop-detect \
    less \
    libnotify-bin \
    libnss-resolve \
    libpam-mount \
    libpango1.0-0 \
    libreoffice \
    libssl-dev \
    lightdm \
    light-locker \
    lshw \
    lsof \
    m4 \
    make \
    makedev \
    man-db \
    manpages \
    manpages-dev \
    mawk \
    mplayer \
    ncurses-term \
    netcat \
    netcat-openbsd \
    net-tools \
    network-manager \
    network-manager-gnome \
    nmap \
    notification-daemon \
    ntp \
    openssh-client \
    openssh-server \
    openssh-sftp-server \
    openssl \
    openvpn \
    p7zip-full \
    pandoc \
    parcellite \
    parted \
    passwd \
    pasystray \
    patch \
    patchutils \
    pavucontrol \
    pkg-config \
    pm-utils \
    pulseaudio \
    pulseaudio-module-bluetooth \
    pulseaudio-utils \
    puppet-lint \
    pwgen \
    python3 \
    python3-all \
    python3-all-dev \
    python3-dev \
    python3-pip \
    qemu-kvm \
    qemu-system-common \
    qemu-system-x86 \
    qemu-utils \
    rdesktop \
    redshift \
    rfkill \
    rsync \
    sbuild \
    schroot \
    schroot-common \
    screen \
    scrot \
    sed \
    shellcheck \
    silversearcher-ag \
    snapd \
    socat \
    software-properties-common \
    sox \
    speedometer \
    sqlite3 \
    ssh-askpass \
    sshpass \
    sshuttle \
    ssl-cert \
    strace \
    sudo \
    sysstat \
    tar \
    tcpdump \
    tmux \
    traceroute \
    trayer \
    tree \
    ttf-bitstream-vera \
    tzdata \
    ubuntu-dev-tools \
    uidmap \
    unzip \
    util-linux \
    valgrind \
    vim-gtk \
    virtualenv \
    virtualenvwrapper \
    vlc \
    vpnc-scripts \
    wget \
    wireshark \
    xattr \
    xclip \
    xdg-utils \
    xmobar \
    xmonad \
    xorg \
    xserver-xorg-input-synaptics \
    xss-lock \
    xterm \
    xtightvncviewer \
    zip

umask 0022

# TODO: noatime in fstab

locale-gen en_US.UTF-8
locale-gen hu_HU.UTF-8

chsh -s /bin/bash $provisioning_user

sed -r -i 's/\s?#?(\s*)SendEnv (.*)$/#   SendEnv \2/g' /etc/ssh/ssh_config
sed -r -i 's/\s?#?(\s*)ForwardAgent\s+.*$/    ForwardAgent yes/g' /etc/ssh/ssh_config

sed -r -i 's/^GRUB_CMDLINE_LINUX=.*$/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1 elevator=noop"/g' /etc/default/grub
update-grub

echo 'KERNEL=="intel_backlight", SUBSYSTEM=="backlight", RUN+="/bin/chmod 0666 /sys/class/backlight/%k/brightness"' > /etc/udev/rules.d/97-intel_backlight.rules
echo 'Acquire::AllowInsecureRepositories "yes";' > /etc/apt/apt.conf.d/30allowinsecurerepos

rsync -av $curdir/dotfiles/ $homedir/
chown -R $provisioning_user: $homedir

rm -rf $homedir/.vim
curl 'https://vim-bootstrap.com/generate.vim' --data 'editor=vim&langs=c&langs=erlang&langs=html&langs=go&langs=haskell&langs=html&langs=javascript&langs=python&langs=ruby&langs=rust' > $homedir/.vimrc
chown $provisioning_user: $homedir/.vimrc

mkdir -p $homedir/.local
rsync -av $curdir/local/ $homedir/
chown -R $provisioning_user: $homedir/.local

mkdir -p $homedir/.terminfo
cp $curdir/terminfo/*.terminfo $homedir/.terminfo/
for ti in $homedir/.terminfo/*.terminfo; do
    tic $ti
done
chown -R $provisioning_user: $homedir/.terminfo

# Install latest Firefox.
apt-get remove -y firefox-esr || true
rm -rf /usr/local/firefox
curl -L "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" | \
    tar -xjf - -C /usr/local/
ln -snf /usr/local/firefox/firefox /usr/local/bin/firefox

# Go 1.13.
rm -rf /usr/local/go
curl -L https://dl.google.com/go/go1.13.10.linux-amd64.tar.gz | \
    tar -xzf - -C /usr/local/

# Install deb packages.
deb_urls="https://downloads.slack-edge.com/linux_releases/slack-desktop-4.14.0-amd64.deb https://releases.hashicorp.com/vagrant/2.2.7/vagrant_2.2.7_x86_64.deb https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb"
rm -rf /tmp/debs; mkdir -p /tmp/debs; pushd /tmp/debs
for deb in $deb_urls; do
    curl -LO $deb
done
popd; dpkg -i /tmp/debs/* || true; apt-get install -f -y; rm -rf /tmp/debs

# Other tools.
curl -L https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl > /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl
kubectl completion bash > /etc/bash_completion.d/kubectl

curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 > /usr/local/bin/minikube \
    && chmod +x /usr/local/bin/minikube

curl -L https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip > tf.zip \
    && unzip -o tf.zip -d /usr/local/bin/

curl -L https://github.com/ldx/closest-airport/releases/download/v1.0.0/closest-airport.tar.gz | tar xzf - -C /usr/local/bin

pip install awscli
pip install powerline-status powerline_gitstatus

# Install NeoVim.
mkdir -p $homedir/.local/bin
curl -L https://github.com/neovim/neovim/releases/latest/download/nvim.appimage > $homedir/.local/bin/nvim
chmod u+x $homedir/.local/bin/nvim
ln -snf $homedir/.local/bin/nvim $homedir/.local/bin/vim
python3 -m pip install --user --upgrade pynvim
