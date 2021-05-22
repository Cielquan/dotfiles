#!/usr/bin/env sh

BOLD="$(tput bold 2>/dev/null || printf '')"
UNDERLINE="$(tput smul 2>/dev/null || printf '')"
BLINK="$(tput blink 2>/dev/null || printf '')"
REVERSE="$(tput rev 2>/dev/null || printf '')"

BLACK="$(tput setaf 0 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"  # often violet
CYAN="$(tput setaf 6 2>/dev/null || printf '')"
WHITE="$(tput setaf 7 2>/dev/null || printf '')"

BLACK_BG="$(tput setab 0 2>/dev/null || printf '')"
RED_BG="$(tput setab 1 2>/dev/null || printf '')"
GREEN_BG="$(tput setab 2 2>/dev/null || printf '')"
YELLOW_BG="$(tput setab 3 2>/dev/null || printf '')"
BLUE_BG="$(tput setab 4 2>/dev/null || printf '')"
MAGENTA_BG="$(tput setab 5 2>/dev/null || printf '')"  # often violet
CYAN_BG="$(tput setab 6 2>/dev/null || printf '')"
WHITE_BG="$(tput setab 7 2>/dev/null || printf '')"

NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"

info() {
    printf '%b\n' "${BOLD}${CYAN}>${NO_COLOR} $*"
}

warn() {
    printf '%b\n' "${YELLOW}[!] $*${NO_COLOR}"
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

answer_is_yes() {
    printf '%b' "${YELLOW}[?] $1 (y/n) ${NO_COLOR}"
    read -r REPLY </dev/tty
    answers="yY"
    test "${answers#*$REPLY}" != "$answers" && return 0 || return 1
}

test_writeable() {
    # Test if a location is writeable by trying to write to it. Windows does not let
    # you test writeability other than by writing: https://stackoverflow.com/q/1999988
    # source: https://sh.rustup.rs
    local path
    path="${1:-}/test.txt"
    if touch "${path}" 2>/dev/null; then
        rm "${path}"
        return 0
    else
        return 1
    fi
}

direct_install() {
    # Can install multiple packages at once
    # but does not check if they are already installed.
    local packages=$1
    info "Installing ${packages}."
    sudo apt-get install -y ${packages} 1> /dev/null
    success "Done."
}

direct_install_via_ppa() {
    # Installs a package from a ppa which gets added before installing.
    local package=$1
    local ppa=$2
    info "Adding ${ppa} ppa"
    sudo add-apt-repository -y ppa:${ppa} 1> /dev/null
    sudo apt-get update 1> /dev/null
    success "Done."
    direct_install ${package}
}

checked_install() {
    # Installs a single package but checks if it is already installed.
    # If it is the install step is skipped.
    local package=$1
    info "Installing ${package}."
    if installed ${package}; then
        info "${package} is already installed."
    else
        sudo apt-get install -y ${package} 1> /dev/null
        success "Done."
    fi
}

checked_install_via_ppa() {
    # Installs a package from a ppa, but checks if there is a need to add the ppa.
    # If not the addition is optional.
    # If the package is already installed the install step is skipped.
    local package=$1
    local ppa=$2
    if $(apt-cache search ${package} | grep -q ${package}); then
        success "Found ${package} in your repositories. PPA can be added."
        local ppa_needed="n"
    else
        info "Could not find ${package} in your repositories. PPA must be added to install."
        local ppa_needed="y"
    fi
    if answer_is_yes "Do you want to add ${ppa} ppa?"; then
        info "Adding ${ppa} ppa"
        sudo add-apt-repository -y ppa:${ppa} 1> /dev/null
        sudo apt-get update 1> /dev/null
        success "Done."
        local ppa_added="y"
    else
        local ppa_added="n"
    fi
    if [ ${ppa_needed} = "n" ] || [ ${ppa_needed} = ${ppa_added} ]; then
        checked_install ${package}
    else
        warn "Skip installing ${package}. No repository to install from."
    fi
}
