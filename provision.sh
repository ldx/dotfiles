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
    docker.io \
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
    flatpak \
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
    postgresql-client \
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

rm -rf $homedir/.vim
rm -rf $homedir/.config/nvim; mkdir -p $homedir/.config/nvim
curl 'https://vim-bootstrap.com/generate.vim' --data 'editor=vim&langs=c&langs=erlang&langs=html&langs=go&langs=haskell&langs=html&langs=javascript&langs=python&langs=ruby&langs=rust' > $homedir/.vimrc
curl 'https://vim-bootstrap.com/generate.vim' --data 'editor=vim&langs=c&langs=erlang&langs=html&langs=go&langs=haskell&langs=html&langs=javascript&langs=python&langs=ruby&langs=rust' > $homedir/.config/nvim/init.vim
chown -R $provisioning_user: $homedir/.vimrc
chown -R $provisioning_user: $homedir/.config

mkdir -p $homedir/.local
rsync -av $curdir/local/ $homedir/
chown -R $provisioning_user: $homedir/.local

mkdir -p $homedir/.terminfo
cp $curdir/terminfo/*.terminfo $homedir/.terminfo/
for ti in $homedir/.terminfo/*.terminfo; do
    tic $ti
done
chown -R $provisioning_user: $homedir/.terminfo

rsync -av $curdir/dotfiles/ $homedir/
chown -R $provisioning_user: $homedir

# Remove Firefox ESR.
apt-get remove -y firefox-esr || true

# Go.
rm -rf /usr/local/go
curl -L https://dl.google.com/go/go1.17.2.linux-amd64.tar.gz | \
    tar -xzf - -C /usr/local/

# Kubectl.
curl -L https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl > /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl
kubectl completion bash > /etc/bash_completion.d/kubectl

# Minikube.
curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 > /usr/local/bin/minikube \
    && chmod +x /usr/local/bin/minikube

# Closest-airport.
curl -L https://github.com/ldx/closest-airport/releases/download/v1.0.0/closest-airport.tar.gz | tar xzf - -C /usr/local/bin

# Awscli.
pip3 install awscli

# Powerline.
pip3 install powerline-status powerline_gitstatus

# NeoVim.
snap install --classic nvim
pip3 install pynvim

# Directory for user-installed binaries.
rm -rf "$homedir/.local/bin"
mkdir -p "$homedir/.local/bin"

# TFenv.
rm -rf "$homedir/.tfenv"
git clone https://github.com/tfutils/tfenv.git "$homedir/.tfenv"
chown -R "$provisioning_user:" "$homedir/.tfenv"
for x in "$homedir/.tfenv/bin/"*; do
   ln -s "$x" "$homedir/.local/bin/"
done

# Bazelisk.
curl -L "https://github.com/bazelbuild/bazelisk/releases/download/v1.10.1/bazelisk-linux-amd64" > "$homedir/.local/bin/bazel"

# Dropbox.
flatpak install -y com.dropbox.Client/x86_64/stable

# Slack.
flatpak install -y com.slack.Slack/x86_64/stable

# Firefox.
flatpak install -y app/org.mozilla.firefox/x86_64/stable

chmod 0755 "$homedir/.local/bin/"*
chown -R "$provisioning_user:" "$homedir/.local/bin"
