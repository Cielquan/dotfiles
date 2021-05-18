# Unfinished - SSL cert probs

#  1. Install ubuntu

#  2. Send ssh key from OTHER MACHINE
cd ~/.ssh && ssh-copy-id -i id_rsa_home.pub guenther

#  3. ssh into remote
ssh guenther

#  4. Install dotfiles
pushd ~ && git clone https://github.com/Cielquan/dotfiles.git && cd dotfiles && ./install.sh && popd

#  5. Upgrade && shutdown (for snapshot)
sudo apt update && sudo apt dist-upgrade -y && shutdown now

#  6. Install dependencies
sudo apt install -y docker-compose docker.io

#  7. Add user to docker group and reboot to apply
sudo usermod -aG docker krys && sudo reboot

#  8. Move DoTH-DNS via scp
scp -r DoTH-DNS guenther:~/DoTH-DNS

#  9. Update .env

# 10. Build DoH image
cd DoTH-DNS && ./doh-docker/docker_build.sh

# 11. Set name.com env vars (set token before and whitelist IP on name.com)
export NAMECOM_USERNAME=Cielquan && export NAMECOM_API_TOKEN=

# 11. Run container
dcup





#  5. Shutdown (for snapshot)
shutdown now

#  6. Init or load conf via Webapp

#  7. Backup conf via Webapp

