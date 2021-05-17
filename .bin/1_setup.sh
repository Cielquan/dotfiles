#!/usr/bin/env sh

set -e

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   utils
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PWD=$(pwd)

answer_is_yes() {
    printf "%b" "   [?] $1 (y/n) "
    read -r REPLY
    printf "\n"
    answers="yY"
    test "${answers#*$REPLY}" != "$answers" && return 0 || return 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   call scripts
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# cd into `.bin` dir
cd $(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if answer_is_yes "Do you want to install the dotfiles?"; then
    python3 ./2_install_dotfiles.py
fi

if answer_is_yes "Do you want to install linux basics?"; then
    ./3_linux_setup.sh
fi

if answer_is_yes "Do you want to install starship prompt? Its automatically used by bash."; then
    ./4_prompt_setup.sh
fi

if answer_is_yes "Do you want to install coding setup?"; then
    ./5_coding_setup.sh
fi

cd $PWD

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   finish
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n\n## Setup finished please restart the shell for the new environment.\n"
