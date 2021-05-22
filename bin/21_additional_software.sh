#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)
. ${SCRIPT_DIR}/util/shell_script_utils.sh

info "Installing additonal software ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Additional basic tooling
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PACKAGES="ldnsutils net-tools wget"

echo ${PACKAGES} | tr ' ' '\n' | while read package; do
    if answer_is_yes "Do you want to install '${package}' package?"; then
        checked_install ${package}
    fi
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   git
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if answer_is_yes "Do you want to install 'git' package or ppa?"; then
    checked_install_via_ppa git phoerious/git-core/ppa
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   docker.io / docker-compose
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if answer_is_yes "Do you want to install/setup docker stuff?"; then
    if answer_is_yes "Do you want to install 'docker.io' package?"; then
        checked_install docker.io
    fi

    if answer_is_yes "Do you want to install 'docker-compose' package?"; then
        checked_install docker-compose
    fi

    if answer_is_yes "Do you want to add the current user to 'docker' group?"; then
        if $(groups | grep -q docker); then
            info "User is already in 'docker' group."
        # https://stackoverflow.com/a/46040491
        elif $(/usr/bin/getent group docker > /dev/null 2>&1); then
            info "Adding user to 'docker' group."
            sudo usermod -aG docker ${USER}
            success "Done."
        else
            error "Could not add user to 'docker' group. Group does not exist."
        fi
    fi
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   KeePassXC
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if answer_is_yes "Do you want to install 'keepassxc' package or ppa?"; then
    checked_install_via_ppa keepassxc phoerious/keepassxc
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Brave
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if answer_is_yes "Do you want to install 'brave-browser' package and ppa?"; then
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
    ${sudo} curl ${CURL_ARGS} -o ${keyring} ${link}
    success "Done."

    apt_source="deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"
    add_apt_source ${apt_source} "brave-browser-release.list"

    apt_update

    direct_install brave-browser
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Installing additonal software finsihed ..."
