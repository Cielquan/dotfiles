#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)
. ${SCRIPT_DIR}/util/shell_script_utils.sh

info "Starting basic linux setup ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install basic linux stuff
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PACKAGES="nano curl unzip htop"

apt_update

direct_install ca-certificates apt-transport-https

info "Upgading system."
if test_apt_install; then
    sudo=""
else
    elevate_priv "upgrade"
    sudo="sudo"
fi
${sudo} apt-get dist-upgrade -y 1> /dev/null
success "Done."

echo ${PACKAGES} | tr ' ' '\n' | while read package; do
    checked_install ${package}
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Basic linux setup finished ..."
