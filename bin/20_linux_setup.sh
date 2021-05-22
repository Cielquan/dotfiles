#!/usr/bin/env sh

# This script needs elevated permissions for `apt` calls

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)
. ${SCRIPT_DIR}/util/shell_script_utils.sh

info "Starting basic linux setup ..."
sudo -v

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install basic linux stuff
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PACKAGES="nano wget unzip htop"

info "Updating repos"
sudo apt-get update 1> /dev/null
success "Done"

info "Installing certs and apt-transport-https"
sudo apt-get install -y ca-certificates apt-transport-https 1> /dev/null
success "Done"

info "Upgading all"
sudo apt-get dist-upgrade -y 1> /dev/null
success "Done"

echo ${PACKAGES} | tr ' ' '\n' | while read package; do
    direct_install ${package}
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Basic linux setup finished ..."
