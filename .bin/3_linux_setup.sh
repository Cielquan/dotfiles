#!/usr/bin/env sh

# This scripts needs elevated permissions for `apt` calls

set -e
sudo -v

PACKAGES="ldnsutils net-tools htop git nano curl wget unzip fontconfig"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install basic linux stuff
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n\n## Updating repos\n"
sudo apt-get update 1> /dev/null

printf "\n\n## Install certs and apt https\n"
sudo apt-get install -y ca-certificates apt-transport-https 1> /dev/null

printf "\n\n## Add git ppa\n"
sudo add-apt-repository -y ppa:git-core/ppa 1> /dev/null

printf "\n\n## Updating repos\n"
sudo apt-get update 1> /dev/null

printf "\n\n## Upgade all\n"
sudo apt-get dist-upgrade -y 1> /dev/null

echo ${PACKAGES} | tr ' ' '\n' | while read package; do
    printf "\n\n## Installing ${package}\n"
    if ! command -v ${package} > /dev/null 2>&1; then    
        sudo apt-get install -y ${package} 1> /dev/null
    else
        printf "## ${package} is installed\n"
    fi
done
