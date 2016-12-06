#!/bin/bash

su -c "apt-get install python-dev python-pip"
su -c "pip install ansible markupsafe"

ansible-playbook -K -c local -i localhost, base-packages.yml
ansible-playbook -K -c local -i localhost, workstation.yml
ansible-playbook -c local -i localhost, dotfiles.yml
ansible-playbook -c local -i localhost, ycm.yml
