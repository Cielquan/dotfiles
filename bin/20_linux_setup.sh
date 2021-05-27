#!/usr/bin/env sh

# No questions asked

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "${0}")")" && pwd -P)
# shellcheck disable=1091
. "${SCRIPT_DIR}/util/shell_script_utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   START
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Starting basic linux setup ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install basic linux stuff
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

apt_update

direct_install ca-certificates apt-transport-https

upgrade_system() {
    info "Upgading system."
    if test_apt_install; then
        sudo=""
    else
        elevate_priv "upgrade"
        sudo="sudo"
    fi
    ${sudo} apt-get dist-upgrade -y 1> /dev/null
    success "Done."
}
upgrade_system

install_packages() {
    PACKAGES="${1}"
    echo "${PACKAGES}" | tr ' ' '\n' | while read -r package; do
        checked_install "${package}"
    done
}
install_packages "nano curl unzip htop"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Basic linux setup finished ..."
