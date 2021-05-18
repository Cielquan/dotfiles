#  0. Setup VM
#  - 60GB HDD
#  - 8192GB RAM
#  - 4 Cores
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
echo -e "\n//10.8.32.20/share /mnt/share cifs guest,noperm,rw,soft,dir_mode=0777,file_mode=0777,iocharset=utf8 0 0" | sudo tee -a /etc/fstab && sudo mkdir /mnt/share && echo "//10.8.32.20/backup_data /mnt/backup_data cifs username=cvm,password=PASSWORD,noperm,rw,soft,dir_mode=0777,file_mode=0777,iocharset=utf8 0 0" | sudo tee -a /etc/fstab && sudo mkdir /mnt/backup_data && echo "//10.8.32.20/pwdb /mnt/pwdb cifs username=cvm,password=PASSWORD,noperm,rw,soft,dir_mode=0777,file_mode=0777,iocharset=utf8 0 0" | sudo tee -a /etc/fstab && sudo mkdir /mnt/pwdb
sudo mount -a

#  8. Install VSCode
# https://code.visualstudio.com/docs/setup/linux

#  9. Add deadsnakes ppa
sudo add-apt-repository ppa:deadsnakes/ppa && sudo apt update

# 10. Install relevant python versions
sudo apt install -y
# python3.6 python3.6-dev python3.6-venv
# python3.7 python3.7-dev python3.7-venv
# python3.8 python3.8-dev python3.8-venv
# python3.9 python3.9-dev python3.9-venv
# python3.10 python3.10-dev python3.10-venv

# 11. Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 12. Install node.js
sudo apt install -y nodejs

# 13. Install KeePassXC
sudo add-apt-repository ppa:phoerious/keepassxc && sudo apt update
sudo apt install -y keepassxc

# 14. Install and setup poetry
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -
source $HOME/.poetry/env && poetry config virtualenvs.in-project true

# 15. Install starship prompt
curl -fsSL https://starship.rs/install.sh | bash -s -- -y

# 16. Install nerd font
version=$(curl -sS https://github.com/ryanoasis/nerd-fonts/releases/latest | grep -Po 'v\d+\.\d+\.\d+')
curl -sSL -o ~/Downloads/DejaVuSansMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/DejaVuSansMono.zip
mkdir -p ~/.local/share/fonts
unzip -o ~/Downloads/DejaVuSansMono.zip -d ~/.local/share/fonts/
fc-cache -fv

