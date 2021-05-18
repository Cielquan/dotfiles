# https://help.ui.com/hc/en-us/articles/220066768-UniFi-How-to-Install-and-Update-via-APT-on-Debian-or-Ubuntu

#  1. Install ubuntu

#  2. Send ssh key from OTHER MACHINE
cd ~/.ssh && ssh-copy-id -i id_rsa_home.pub yui

#  3. ssh into remote
ssh yui

#  4. Install dotfiles
pushd ~ && git clone https://github.com/Cielquan/dotfiles.git && cd dotfiles && ./install.sh && popd

#  5. Upgrade && shutdown (for snapshot)
sudo apt update && sudo apt dist-upgrade -y && shutdown now

#  4. Run script
rm unifi-latest.sh &> /dev/null; wget https://get.glennr.nl/unifi/install/install_latest/unifi-latest.sh && bash unifi-latest.sh

#  5. Shutdown (for snapshot)
shutdown now

#  6. Init or load conf via Webapp

#  7. Backup conf via Webapp

