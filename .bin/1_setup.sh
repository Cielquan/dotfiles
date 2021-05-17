#!/usr/bin/env sh

set -e

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   utils
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# PWD=$(pwd)

answer_is_yes() {
    printf "%b" "   [?] $1 (y/n) "
    read -r REPLY
    printf "\n"
    answers="yY"
    test "${answers#*$REPLY}" != "$answers" && return 0 || return 1
}

clone_repo() {
    if test -d ~/.dotfiles/.git; then
        printf "\n\n## dotfiles repo found - Skip cloning\n"
        return
    if ! command -v git > /dev/null 2>&1; then    
        printf "\n\n## Installing missing git\n"
        sudo apt install -y git
    fi
    printf "\n\n## Cloning dotfiles repo\n"
    git clone https://github.com/Cielquan/dotfiles.git ~/.dotfiles
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   call scripts
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# cd into `.bin` dir
# cd $(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if answer_is_yes "Do you want to install the dotfiles?"; then
    clone_repo
    printf "\n\n## Starting script ...\n"
    python3 ~/.dotfiles/.bin/2_install_dotfiles.py
fi

if answer_is_yes "Do you want to install linux basics?"; then
    clone_repo
    printf "\n\n## Starting script ...\n"
    ~/.dotfiles/.bin/3_linux_setup.sh
fi

if answer_is_yes "Do you want to install starship prompt? Its automatically used by bash."; then
    clone_repo
    printf "\n\n## Starting script ...\n"
    ~/.dotfiles/.bin/4_prompt_setup.sh
fi

if answer_is_yes "Do you want to install coding setup?"; then
    clone_repo
    printf "\n\n## Starting script ...\n"
    ~/.dotfiles/.bin/5_coding_setup.sh
fi

# cd $PWD

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   finish
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n\n## Setup finished please restart the shell for the new environment.\n"
