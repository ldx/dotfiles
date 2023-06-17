#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

provisioning_user="$SUDO_USER"
if [[ -z "$provisioning_user" ]]; then
    echo "Failed to detect user"
    exit 1
fi

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
    autorandr \
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
    firmware-sof-signed \
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
    tlp \
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

# Remove Firefox ESR.
apt-get remove -y firefox-esr || true

# Flatpak hub.
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Snap packages.
for p in firefox zoom-client; do
    snap install $p
done
for p in aws-cli go kubectl slack; do
    snap install --classic $p
done
export PATH=$PATH:/snap/bin
kubectl completion bash > /etc/bash_completion.d/kubectl

umask 0022

# TODO: noatime in fstab

grep '^hu_HU.UTF-8 UTF-8' /etc/locale.gen || echo 'hu_HU.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen

sed -r -i 's/\s?#?(\s*)SendEnv (.*)$/#   SendEnv \2/g' /etc/ssh/ssh_config
sed -r -i 's/\s?#?(\s*)ForwardAgent\s+.*$/    ForwardAgent yes/g' /etc/ssh/ssh_config

sed -r -i 's/^GRUB_CMDLINE_LINUX=.*$/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1 elevator=noop"/g' /etc/default/grub
update-grub

echo 'KERNEL=="intel_backlight", SUBSYSTEM=="backlight", RUN+="/bin/chmod 0666 /sys/class/backlight/%k/brightness"' > /etc/udev/rules.d/97-intel_backlight.rules

chsh -s /bin/bash $provisioning_user
