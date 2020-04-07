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

# Install latest Firefox.
sudo apt-get remove firefox-esr || true
curl -LO "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" > FirefoxSetup.tar.bz2
tar xvf FirefoxSetup.tar.bz2
sudo mv firefox /opt/
sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox
rm FirefoxSetup.tar.bz2
