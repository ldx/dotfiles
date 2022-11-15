#!/usr/bin/env bash

set -euxo pipefail

if [[ ! -f /swapfile ]]; then
    fallocate -l 8G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
else
    echo "Swapfile already exists."
fi

grep '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab

grep 'vm.swappiness' /etc/sysctl.conf || echo 'vm.swappiness=10' >> /etc/sysctl.conf
