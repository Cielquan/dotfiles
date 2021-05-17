#!/usr/bin/env sh

set -e
sudo -v

PY_VERSIONS="3.6 3.7 3.8 3.9"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install python versions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n\n## Adding deadsnakes ppa\n"
sudo add-apt-repository -y ppa:deadsnakes/ppa && sudo apt-get update

echo ${PY_VERSIONs} | tr ' ' '\n' | while read version; do
    if ! command -v python${version} &> /dev/null; then
        printf "\n\n## Installing python${version}\n"
        sudo apt-get install -y python${version} python${version}-venv python${version}-dev
    else
        printf "\n\n## python${version} is installed. Installing additional packages\n"
        sudo apt-get install -y python${version}-venv python${version}-dev
    fi
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

sudo apt-get install -y nodejs

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install code
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if ! command -v code > /dev/null 2>&1; then
    printf "\n\n## Install VSCode\n"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt-get update
    sudo apt-get install -y code
else
    printf "## VSCode is installed\n"
fi
