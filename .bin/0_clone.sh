#!/usr/bin/env sh

set -e

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install git (if missing) and git clone dotfiles
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if ! command -v git > /dev/null 2>&1; then    
    printf "\n\n## Installing missing git\n"
    sudo apt install -y git
fi

git clone https://github.com/Cielquan/dotfiles.git ~/.dotfiles

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   call setup script
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n\n## Calling setup script\n"
~/.dotfiles/.bin/1_setup.sh
