#!/usr/bin/env sh

# This scripts needs elevated permissions for `apt` calls

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)
. ${SCRIPT_DIR}/util/shell_script_utils.sh

info "Starting basic linux setup ..."
sudo -v

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install basic linux stuff
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PACKAGES="ldnsutils net-tools htop git nano curl wget unzip fontconfig"

info "Updating repos"
sudo apt-get update 1> /dev/null
success "Done"

info "Installing certs and apt https"
sudo apt-get install -y ca-certificates apt-transport-https 1> /dev/null
success "Done"

info "Adding git ppa"
sudo add-apt-repository -y ppa:git-core/ppa 1> /dev/null
success "Done"

info "Updating repos"
sudo apt-get update 1> /dev/null
success "Done"

info "Upgading all"
sudo apt-get dist-upgrade -y 1> /dev/null
success "Done"

echo ${PACKAGES} | tr ' ' '\n' | while read package; do
    info "Installing ${package}"
    if ! installed ${package}; then    
        sudo apt-get install -y ${package} 1> /dev/null
        success "Done"
    else
        info "${package} is already installed"
    fi
done

success "Basic linux setup finished ..."
