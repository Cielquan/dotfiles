#!/usr/bin/env sh

set -e

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   utils
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

answer_is_yes() {
    printf "%b" "   [?] $1 (y/n) "
    read -r REPLY </dev/tty
    printf "\n"
    answers="yY"
    test "${answers#*$REPLY}" != "$answers" && return 0 || return 1
}

clone_repo() {
    if test -d ~/.dotfiles/.git; then
        printf "\n\n## dotfiles repo found - Skip cloning\n"
        return
    fi
    if ! command -v git > /dev/null 2>&1; then    
        printf "\n\n## Installing missing git\n"
        sudo apt-get install -yqq git
    fi
    printf "\n\n## Cloning dotfiles repo\n"
    git clone -q https://github.com/Cielquan/dotfiles.git ~/.dotfiles
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   call scripts
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if answer_is_yes "Do you want to install the dotfiles?"; then
    clone_repo
    printf "\n\n## Installer script's help page:\n"
    python3 ~/.dotfiles/.bin/2_install_dotfiles.py --help
    printf "\n\n## Please see the script's help page above. "
    printf "If you want to customize the install add your parameters before pressing enter.\n"
    printf "Args: "
    read -r ARGV </dev/tty
    python3 ~/.dotfiles/.bin/2_install_dotfiles.py $ARGV
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   finish
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n\n## Setup finished please restart the shell for the new environment.\n"
