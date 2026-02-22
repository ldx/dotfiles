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
  copyq \
  cpp \
  cscope \
  cups \
  curl \
  debootstrap \
  desktop-base \
  devscripts \
  direnv \
  dnsutils \
  dput \
  ebtables \
  ed \
  evince \
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
  gcc-multilib \
  gdb \
  ghostscript \
  greetd \
  tuigreet \
  gimp \
  git \
  git-man \
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
  psmisc \
  pipewire \
  pipewire-audio \
  pipewire-pulse \
  wireplumber \
  pwgen \
  python3 \
  python3-all \
  python3-all-dev \
  python3-dev \
  python3-pip \
  python3-venv \
  freerdp2-x11 \
  redshift \
  rfkill \
  rsync \
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
  tzdata \
  uidmap \
  unzip \
  util-linux \
  v4l-utils \
  valgrind \
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
  xss-lock \
  alacritty \
  grim \
  mako-notifier \
  slurp \
  seatd \
  sway \
  swayidle \
  swaylock \
  waybar \
  wl-clipboard \
  wofi \
  xdg-desktop-portal-wlr \
  xterm \
  xwayland \
  xtightvncviewer \
  zip \
  docker-buildx-plugin

# Keyd is not in Debian 13.
mkdir -p /etc/keyd
cat <<EOF >/etc/keyd/default.conf
[ids]
#04d8:eed3:ab0dc860
*

[main]
capslock = escape
leftalt  = rightalt
leftcontrol+leftmeta = leftalt

# Dual-role example: tap=esc, hold=ctrl
#capslock = overload(control, esc)
EOF

keyd_tmpdir=$(mktemp -d /tmp/keyd-XXXXXX)
git clone https://github.com/rvaiya/keyd.git "$keyd_tmpdir"
pushd "$keyd_tmpdir"
make && make install
popd
rm -rf "$keyd_tmpdir"

# Remove Firefox ESR.
apt-get remove -y firefox-esr || true

bash "$cur_dir"/InstallAzureCLIDeb

# Flatpak hub.
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

umask 0022

sed -r -i 's/\s?#?(\s*)SendEnv (.*)$/#   SendEnv \2/g' /etc/ssh/ssh_config
sed -r -i 's/\s?#?(\s*)ForwardAgent\s+.*$/    ForwardAgent yes/g' /etc/ssh/ssh_config

echo 'KERNEL=="intel_backlight", SUBSYSTEM=="backlight", RUN+="/bin/chmod 0666 /sys/class/backlight/%k/brightness"' >/etc/udev/rules.d/97-intel_backlight.rules

cat <<EOF >/etc/sudoers.d/50-utils
%sudo  ALL=(ALL) NOPASSWD: /sbin/resolvconf
%sudo  ALL=(ALL) NOPASSWD: /usr/bin/resolvectl
%sudo  ALL=(ALL) NOPASSWD: /usr/sbin/openconnect
%sudo  ALL=(ALL) NOPASSWD: /usr/sbin/openvpn
EOF

mkdir -p /etc/openvpn
cp "$cur_dir"/update-resolv-conf /etc/openvpn/update-resolv-conf

usermod -a -G sudo "$provisioning_user"

chsh -s /bin/bash "$provisioning_user"

# greetd + tuigreet display manager setup.
# greeter user needs a home dir for --remember state and input group for keyboard.
mkdir -p /home/greeter
chown greeter:greeter /home/greeter
usermod -aG input greeter

# Deploy XMonad wayland session entry for tuigreet.
mkdir -p /usr/local/share/wayland-sessions
cp "$cur_dir/config/wayland-sessions/xmonad.desktop" /usr/local/share/wayland-sessions/

cat <<EOF >/etc/greetd/config.toml
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-session --sessions /usr/share/wayland-sessions:/usr/local/share/wayland-sessions"
user = "greeter"
EOF

# Prevent getty@tty1 from fighting greetd on VT1.
systemctl mask getty@tty1
systemctl enable greetd
