#!/usr/bin/env bash

WLAN_IF=wlp0s20f3

sudo systemd-resolve --set-mdns=yes --interface=$WLAN_IF
sudo systemd-resolve --status $WLAN_IF
sudo systemctl restart systemd-resolved 
