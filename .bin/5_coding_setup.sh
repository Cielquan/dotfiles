#!/usr/bin/env sh

# This scripts needs elevated permissions for `apt` calls

set -e
sudo -v

PY_VERSIONS="3.6 3.7 3.8 3.9"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install python versions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n\n## Adding deadsnakes ppa\n"
sudo add-apt-repository -y ppa:deadsnakes/ppa 1> /dev/null 
sudo apt-get update 1> /dev/null

echo ${PY_VERSIONS} | tr ' ' '\n' | while read version; do
    printf "\n\n## Installing python${version}\n"
    if ! command -v python${version} > /dev/null 2>&1; then
        sudo apt-get install -y python${version} 1> /dev/null
    else
        printf "## python${version} is already installed\n"
    fi
    printf "## Installing venv and dev packages\n"
    sudo apt-get install -y python${version}-venv python${version}-dev 1> /dev/null
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install and setup poetry
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -
source $HOME/.poetry/env && poetry config virtualenvs.in-project true

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install rust
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install node
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

sudo apt-get install -y nodejs 1> /dev/null

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install code
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if ! command -v code > /dev/null 2>&1; then
    printf "\n\n## Install VSCode\n"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt-get update 1> /dev/null
    sudo apt-get install -y code 1> /dev/null
else
    printf "## VSCode is installed\n"
fi
