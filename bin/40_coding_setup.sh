#!/usr/bin/env sh

# This scripts needs elevated permissions for `apt` calls

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)
. ${SCRIPT_DIR}/util/shell_script_utils.sh

info "Starting coding setup ..."
sudo -v

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install python versions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PY_VERSIONS="3.6 3.7 3.8 3.9"

info "Adding deadsnakes ppa"
sudo add-apt-repository -y ppa:deadsnakes/ppa 1> /dev/null 
sudo apt-get update 1> /dev/null
success "Done"

echo ${PY_VERSIONS} | tr ' ' '\n' | while read version; do
    info "Installing python${version}"
    if ! installed python${version}; then
        sudo apt-get install -y python${version} 1> /dev/null
    else
        info "python${version} is already installed"
    fi
    info "Installing venv and dev packages"
    sudo apt-get install -y python${version}-venv python${version}-dev 1> /dev/null
    success "Done"
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install and setup poetry
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Installing poetry"
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 - -y
success "Done"

info "Setting poetry so put venv into project directory"
source $HOME/.poetry/env && poetry config virtualenvs.in-project true
success "Done"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install rust
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Installing rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
success "Done"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install node
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if ! installed nodejs; then
    info "Installing nodejs"
    sudo apt-get install -y nodejs 1> /dev/null
    success "Done"
else
    info "nodeJS is already installed"
fi

success "Coding setup finsihed ..."
