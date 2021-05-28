#!/usr/bin/env sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Script messages
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

BOLD="$(tput bold 2> /dev/null || printf '')"
UNDERLINE="$(tput smul 2> /dev/null || printf '')"
BLINK="$(tput blink 2> /dev/null || printf '')"
REVERSE="$(tput rev 2> /dev/null || printf '')"
export BOLD
export UNDERLINE
export BLINK
export REVERSE

BLACK="$(tput setaf 0 2> /dev/null || printf '')"
RED="$(tput setaf 1 2> /dev/null || printf '')"
GREEN="$(tput setaf 2 2> /dev/null || printf '')"
YELLOW="$(tput setaf 3 2> /dev/null || printf '')"
BLUE="$(tput setaf 4 2> /dev/null || printf '')"
MAGENTA="$(tput setaf 5 2> /dev/null || printf '')"  # often violet
CYAN="$(tput setaf 6 2> /dev/null || printf '')"
WHITE="$(tput setaf 7 2> /dev/null || printf '')"
export BLACK
export RED
export GREEN
export YELLOW
export BLUE
export MAGENTA
export CYAN
export WHITE

BLACK_BG="$(tput setab 0 2> /dev/null || printf '')"
RED_BG="$(tput setab 1 2> /dev/null || printf '')"
GREEN_BG="$(tput setab 2 2> /dev/null || printf '')"
YELLOW_BG="$(tput setab 3 2> /dev/null || printf '')"
BLUE_BG="$(tput setab 4 2> /dev/null || printf '')"
MAGENTA_BG="$(tput setab 5 2> /dev/null || printf '')"  # often violet
CYAN_BG="$(tput setab 6 2> /dev/null || printf '')"
WHITE_BG="$(tput setab 7 2> /dev/null || printf '')"
export BLACK_BG
export RED_BG
export GREEN_BG
export YELLOW_BG
export BLUE_BG
export MAGENTA_BG
export CYAN_BG
export WHITE_BG

NO_COLOR="$(tput sgr0 2> /dev/null || printf '')"
export NO_COLOR

info() {
    printf '%b\n' "${BOLD}${CYAN}>${NO_COLOR} $*"
}

warn() {
    printf '%b\n' "${BOLD}${YELLOW}[!]${NO_COLOR}${YELLOW} $*${NO_COLOR}"
}

error() {
    printf '%b\n' "${BOLD}${RED}[x]${NO_COLOR}${RED} $*${NO_COLOR}" >&2
}

success() {
    printf '%b\n' "${BOLD}${GREEN}[✓]${NO_COLOR} $*"
}

question() {
    printf '%b' "${BOLD}${CYAN}[?]${NO_COLOR} ${CYAN}$*${NO_COLOR}"
}

answer_is_yes() {
    QUESTION="${1}"
    FORCE="${2}"
    YN="${3}" # Default answer
    if [ -z "${FORCE-}" ]; then
        question "${QUESTION} ${BOLD}[y/N]"
        set +e
        read -r YN </dev/tty
        rc=$?
        set -e
        if [ $rc -ne 0 ]; then
            error "Error reading from prompt. Please rerun with the '--yes' option to" \
                "take the default options or try running from another terminal or shell."
        exit 1
    fi
    fi
    case $(echo "${YN}" | tr '[:upper:]' '[:lower:]') in
        "y" | "yes")
            return 0
            ;;
        "n" | "no")
            return 1
            ;;
    esac
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Default parameters
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CURL_ARGS="--proto =https --tlsv1.2 -sSLf"
export CURL_ARGS

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Permission / Testing
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

installed() {
    command -v "${1}" 1> /dev/null 2>&1
}

test_writeable() {
    # Test if a location is writeable by trying to write to it. Windows does not let
    # you test writeability other than by writing: https://stackoverflow.com/q/1999988
    # source: https://sh.rustup.rs
    path="${1:-}/test.txt"
    if touch "${path}" 2> /dev/null; then
        rm "${path}"
        return 0
    else
        return 1
    fi
}

test_apt_install() {
    # TODO: kind hacky .. find smth better
    # Test if sudo is needed for apt-get install / upgrade / dist-upgrade
    if [ -r /var/lib/dpkg/lock-frontend ]; then return 0; else return 1; fi
}

test_apt_update() {
    # TODO: kind hacky .. find smth better
    # Test if sudo is needed for apt-get update
    if [ -r /var/lib/apt/lists/lock ]; then return 0; else return 1; fi
}

elevate_priv() {
    reason="${1}"
    if [ "${reason}" != "" ]; then
        warn "Elevated permissions are required to ${reason}."
    fi
    # source: https://sh.rustup.rs
    if ! installed sudo; then
        error 'Could not find the command "sudo", needed to get permissions for install.'
        info "If you are on Windows, please run your shell as an administrator, then"
        info "rerun this script. Otherwise, please run this script as root, or install"
        info "sudo."
        exit 1
    fi
    if ! sudo -v; then
        error "Superuser not granted, aborting installation"
        exit 1
    fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Installation
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

apt_update() {
    info "Updating package lists."
    if test_apt_update; then
        apt-get update 1> /dev/null
    else
        elevate_priv "update"
        sudo apt-get update 1> /dev/null
    fi
    success "Done."
}

add_ppa() {
    ppa="${1}"
    info "Adding ${ppa} ppa"
    elevate_priv "add a ppa"
    sudo add-apt-repository -y "ppa:${ppa}" 1> /dev/null
    success "Done."

    apt_update
}

add_apt_source() {
    apt_source="${1}"
    apt_source_dir="/etc/apt/sources.list.d/"
    apt_source_file="${2}"
    info "Adding apt source '${apt_source_file}'."
    if test_writeable "${apt_source_dir}"; then
        sudo=""
    else
        sudo="sudo"
        elevate_priv "add an apt source"
    fi
    echo "${apt_source}" | ${sudo} tee "${apt_source_dir}/${apt_source_file}" > /dev/null
    success "Done."

    apt_update
}

direct_install() {
    # Can install multiple packages at once
    # but does not check if they are already installed.
    info "Installing ${*}."
    if test_apt_install; then
        sudo=""
    else
        elevate_priv "install ${*}"
        sudo="sudo"
    fi
    ${sudo} apt-get install -y "${@}" 1> /dev/null
    success "Done."
}

direct_install_via_ppa() {
    # Installs a package from a ppa which gets added before installing.
    package="${1}"
    ppa="${2}"
    add_ppa "${ppa}"
    direct_install "${package}"
}

checked_install() {
    # Installs a single package but checks if it is already installed.
    # If it is the install step is skipped.
    package="${1}"
    info "Installing ${package}."
    if installed "${package}"; then
        success "${package} is already installed."
    else
        if test_apt_install; then
            sudo=""
        else
            elevate_priv "install ${package}"
            sudo="sudo"
        fi
        ${sudo} apt-get install -y "${package}" 1> /dev/null
        success "Done."
    fi
}

checked_install_via_ppa() {
    # Installs a package from a ppa, but checks if there is a need to add the ppa.
    # If not the addition is optional.
    # If the package is already installed the install step is skipped.
    package="${1}"
    ppa="${2}"
    FORCE="${3}"
    DEFAULT="${4}"
    if apt-cache search "${package}" | grep -q "${package}"; then
        success "Found ${package} in your repositories. [optional]"
        ppa_needed="n"
    else
        ppa_needed="y"
        info "Could not find ${package} in your repositories. PPA must be added to install."
    fi
    Q="Do you want to add ${ppa} ppa?"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT:-${ppa_needed}}"; then
        add_ppa "${ppa}"
        ppa_added="y"
    else
        ppa_added="n"
    fi
    if [ ${ppa_needed} = "n" ] && [ ${ppa_added} = "y" ]; then
        # Install possible updates from optionally added ppa.
        direct_install "${package}"
    elif [ ${ppa_needed} = ${ppa_added} ]; then
        # Install if `not needed & not added` or `needed and added`.
        checked_install "${package}"
    else
        warn "Skip installing ${package}. No repository to install from."
    fi
}
