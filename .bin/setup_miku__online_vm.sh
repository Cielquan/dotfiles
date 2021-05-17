#  0. Setup VM
#  - 40GB HDD
#  - 8192GB RAM
#  - 2 Cores
#  - Bridged Network
#  - 3D Acceleration
#  - Copy/Paste Host/Guest - bidirectional

#  1. Install mint

#  2. Install VBox Guest tools

#  3. Update software

#  4. Install basic deps
sudo apt install -y apt-transport-https ca-certificates

#  5. Add git ppa
sudo add-apt-repository ppa:git-core/ppa && sudo apt update

#  5. Install other tools
sudo apt install -y git ldnsutils htop curl wget nano

#  6. Install dotfiles
pushd ~ && git clone https://github.com/Cielquan/dotfiles.git && cd dotfiles && ./install.sh && popd

#  7. Add share drive and backup drive (replace PASSWORD in file)
echo -e "\n//10.8.32.20/share /mnt/share cifs guest,noperm,rw,soft,dir_mode=0777,file_mode=0777,iocharset=utf8 0 0" | sudo tee /etc/fstab && sudo mkdir /mnt/share && echo "//10.8.32.20/backup_data /mnt/backup_data cifs username=ovm,password=PASSWORD,noperm,rw,soft,dir_mode=0777,file_mode=0777,iocharset=utf8 0 0" | sudo tee /etc/fstab && sudo mkdir /mnt/backup_data
sudo mount -a

#  8. Install brave
# https://brave.com/linux/
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update && sudo apt install -y brave-browser

#  9. Install protonmail bridge
# https://protonmail.com/bridge/install

# 10. Install KeePassXC
sudo add-apt-repository ppa:phoerious/keepassxc && sudo apt update
sudo apt install -y keepassxc


