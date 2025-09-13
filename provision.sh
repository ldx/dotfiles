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

cur_dir=$(dirname "$(readlink -f "$0")")

mkdir -p /usr/local
chown "$provisioning_user" /usr/local

# Docker Engine apt sources.
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  tee /etc/apt/sources.list.d/docker.list >/dev/null

# Required packages.
apt-get update -y
apt-get install -y \
  acpi \
  acpica-tools \
  acpi-support \
  acpitool \
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
  ghostscript \
  gimp \
  git \
  git-man \
  git-svn \
  g++-multilib \
  gnupg \
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
  laptop-detect \
  less \
  libfuse-dev \
  libicu-dev \
  libnotify-bin \
  libnss-resolve \
  libpam-mount \
  libreadline-dev \
  libreoffice \
  libssl-dev \
  lightdm \
  light-locker \
  lshw \
  lsof \
  m4 \
  make \
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
  openssh-client \
  openssh-server \
  openssh-sftp-server \
  openssl \
  openvpn \
  p7zip-full \
  pandoc \
  parted \
  passwd \
  pasystray \
  patch \
  patchutils \
  pavucontrol \
  pkg-config \
  pm-utils \
  psmisc \
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
  python3-venv \
  rdesktop \
  redshift \
  rfkill \
  rsync \
  schroot \
  schroot-common \
  screen \
  scrot \
  sed \
  shellcheck \
  socat \
  sox \
  speedometer \
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
  v4l-utils \
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

cat <<EOF >/usr/share/applications/firefox.desktop
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=firefox %U
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF

bash "$cur_dir"/InstallAzureCLIDeb

# Flatpak hub.
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

umask 0022

# TODO: noatime in fstab

grep '^hu_HU.UTF-8 UTF-8' /etc/locale.gen || echo 'hu_HU.UTF-8 UTF-8' >>/etc/locale.gen
locale-gen

sed -r -i 's/\s?#?(\s*)SendEnv (.*)$/#   SendEnv \2/g' /etc/ssh/ssh_config
sed -r -i 's/\s?#?(\s*)ForwardAgent\s+.*$/    ForwardAgent yes/g' /etc/ssh/ssh_config

sed -r -i 's/^GRUB_CMDLINE_LINUX=.*$/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1 elevator=noop"/g' /etc/default/grub
update-grub

echo 'KERNEL=="intel_backlight", SUBSYSTEM=="backlight", RUN+="/bin/chmod 0666 /sys/class/backlight/%k/brightness"' >/etc/udev/rules.d/97-intel_backlight.rules

usermod -a -G sudo "$provisioning_user"

chsh -s /bin/bash "$provisioning_user"
