#!/bin/bash
#
# Run this without sudo to ensure dotfiles are installed for the right user:
#     $ ./provision.sh
#

# Required packages.
su -c "apt-get install python-dev python-pip"
su -c "pip install ansible markupsafe rsync"

ansible-playbook -K -c local -i localhost, base-packages.yml
ansible-playbook -K -c local -i localhost, workstation.yml
ansible-playbook -c local -i localhost, dotfiles.yml
