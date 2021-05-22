#!/usr/bin/env sh

set -e

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   utils (vendored)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

BOLD="$(tput bold 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
CYAN="$(tput setaf 6 2>/dev/null || printf '')"
NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)

info() {
    printf '%b\n' "${BOLD}${CYAN}>${NO_COLOR} $*"
}

error() {
    printf '%b\n' "${RED}[x] $*${NO_COLOR}" >&2
}

success() {
    printf '%b\n' "${GREEN}[✓]${NO_COLOR} $*"
}

installed() {
    command -v "$1" 1> /dev/null 2>&1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   utils (local)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

called_locally() {
    echo ${SCRIPT_DIR} | grep -q .dotfiles/bin && return 0 || return 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Clone repo
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ -d ~/.dotfiles/.git ]; then
    info "'dotfiles' repo found - Skip cloning."
    if ! called_locally; then
        error "Please call the script from your local machine:" \
            "~/.dotfiles/bin/00_setup.sh"
        exit 1
    fi
else
    if ! installed git; then
        error "Missing 'git' cannot clone the 'dotfiles' repo."
        info "Please install 'git' and rerun the script."
        exit 1
    fi
    info "Cloning dotfiles repo."
    git clone -q https://github.com/Cielquan/dotfiles.git ~/.dotfiles
    success "Done."
    info "Repo is ready for usage. Call ~/.dotfiles/bin/00_setup.sh"
    exit 0
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Call scripts
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${SCRIPT_DIR}/util/shell_script_utils.sh

if answer_is_yes "Do you want to install the dotfiles?"; then
    info "Installer script's help page:"
    python3 ~/.dotfiles/bin/10_install_dotfiles.py --help
    info "Please see the script's help page above. If you want to customize the" \
        "install add your parameters before pressing enter."
    printf "Args: "
    read -r ARGV </dev/tty
    python3 ~/.dotfiles/bin/10_install_dotfiles.py $ARGV
fi

printf "\n"
Q="Do you want to install linux basics? Some following scripts depend on those."
if answer_is_yes ${Q}; then
    ~/.dotfiles/bin/20_linux_setup.sh
fi

printf "\n"
Q="Do you want to install additional software for linux?."
if answer_is_yes ${Q}; then
    ~/.dotfiles/bin/21_additional_software.sh
fi

printf "\n"
Q="Do you want to install starship prompt? Its automatically used by bash."
if answer_is_yes ${Q}; then
    ~/.dotfiles/bin/30_prompt_setup.sh
fi

printf "\n"
Q="Do you want to install LS-COLORS?"
if answer_is_yes ${Q}; then
    ~/.dotfiles/bin/31_ls_colors.sh
fi

printf "\n"
Q="Do you want to install coding setup (languages)?"
if answer_is_yes ${Q}; then
    ~/.dotfiles/bin/40_coding_setup.sh
fi

printf "\n"
Q="Do you want to install and setup VSCode?"
if answer_is_yes ${Q}; then
    ~/.dotfiles/bin/41_vscode_setup.sh
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n"
success "Setup finished please restart the shell for the new environment."
