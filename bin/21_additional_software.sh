#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "${0}")")" && pwd -P)
# shellcheck disable=1091
. "${SCRIPT_DIR}/util/shell_script_utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Parse argv
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# PARSER
while [ "$#" -gt 0 ]; do
    case "$1" in

    -f | -y | --force | --yes)
        FORCE="y"
        shift 1
        ;;

    -)
        shift 1
        ;;

    *)
        error "Unknown option: $1"
        exit 1
        ;;
    esac
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   START
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Installing additonal software ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Additional basic tooling
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_packages() {
    PACKAGES="${1}"
    echo "${PACKAGES}" | tr ' ' '\n' | while read -r package; do
        Q="Do you want to install '${package}' package?"
        DEFAULT="yes"
        if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
            checked_install "${package}"
        fi
    done
}
install_packages "ldnsutils net-tools wget"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   git
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_git_with_ppa() {
    Q="Do you want to install 'git' package or ppa?"
    DEFAULT="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
        checked_install_via_ppa git git-core/ppa "${FORCE}" ""
    fi
}
install_git_with_ppa

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   docker.io / docker-compose
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

setup_docker() {
    Q="Do you want to install/setup docker stuff?"
    DEFAULT="no"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
        Q="Do you want to install 'docker.io' package?"
        DEFAULT="yes"
        if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
            checked_install docker.io
        fi

        Q="Do you want to install 'docker-compose' package?"
        DEFAULT="yes"
        if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
            checked_install docker-compose
        fi

        Q="Do you want to add the current user to 'docker' group?"
        DEFAULT="yes"
        if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
            if groups | grep -q docker; then
                info "User is already in 'docker' group."
            # https://stackoverflow.com/a/46040491
            elif /usr/bin/getent group docker > /dev/null 2>&1; then
                info "Adding user to 'docker' group."
                sudo usermod -aG docker "${USER}"
                success "Done."
            else
                error "Could not add user to 'docker' group. Group does not exist."
            fi
        fi
    fi
}
setup_docker

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   KeePassXC
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_keepassxc() {
    Q="Do you want to install 'keepassxc' package or ppa?"
    DEFAULT="no"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
        checked_install_via_ppa keepassxc phoerious/keepassxc "${FORCE}" ""
    fi
}
install_keepassxc

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Brave
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_brave() {
    Q="Do you want to install 'brave-browser' package and ppa?"
    DEFAULT="no"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
        info "Install brave-browser ppa."

        info "Installing brave-browser keyring."
        link="https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
        keyring="/usr/share/keyrings/brave-browser-archive-keyring.gpg"
        if test_writeable "${keyring}"; then
            sudo=""
        else
            sudo="sudo"
            elevate_priv "add keyring"
        fi
        # shellcheck disable=2086
        ${sudo} curl ${CURL_ARGS} -o "${keyring}" "${link}"
        success "Done."

        apt_source="deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"
        add_apt_source "${apt_source}" "brave-browser-release.list"

        direct_install brave-browser
    fi
}
install_brave

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Installing additonal software finsihed ..."
