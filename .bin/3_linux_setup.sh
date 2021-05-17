#!/usr/bin/env sh

# This scripts needs elevated permissions for `apt` calls

set -e
sudo -v

PACKAGES="ldnsutils htop git nano curl wget"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install basic linux stuff
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n\n## Updating repos\n"
sudo apt-get update -qq

printf "\n\n## Install certs and apt https\n"
sudo apt-get install -yqq ca-certificates apt-transport-https

printf "\n\n## Add git ppa\n"
sudo add-apt-repository -y ppa:git-core/ppa

printf "\n\n## Updating repos\n"
sudo apt-get update -qq

printf "\n\n## Upgade all\n"
sudo apt-get dist-upgrade -yqq

echo ${PACKAGES} | tr ' ' '\n' | while read package; do
    printf "\n\n## Installing ${package}\n"
    if ! command -v ${package} > /dev/null 2>&1; then    
        sudo apt-get install -yqq ${package}
    else
        printf "## ${package} is installed\n"
    fi
done
