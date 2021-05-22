#!/usr/bin/env sh

# This script needs elevated permissions for `apt` calls

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)
. ${SCRIPT_DIR}/util/shell_script_utils.sh

info "Starting coding setup ..."
sudo -v

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install python versions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PY_VERSIONS="3.6 3.7 3.8 3.9"

if answer_is_yes "Do you want to install python versions ${PY_VERSIONS}?"; then
    add_ppa deadsnakes/ppa

    echo ${PY_VERSIONS} | tr ' ' '\n' | while read version; do
        checked_install python${version}
        direct_install python${version}-venv python${version}-dev
    done
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install and setup poetry
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if answer_is_yes "Do you want to install poetry?"; then
    info "Installing poetry"
    local link="https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py"
    curl ${curl_args} ${link} | python3 - -y
    success "Done"

    info "Setting poetry so put venv into project directory"
    source $HOME/.poetry/env && poetry config virtualenvs.in-project true
    success "Done"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install rust
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if answer_is_yes "Do you want to install rust?"; then
    info "Installing rust"
    local link="https://sh.rustup.rs"
    curl ${curl_args} ${link} | sh -s -- -y
    success "Done"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install node
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if answer_is_yes "Do you want to install nodeJS?"; then
    checked_install nodejs
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Coding setup finished ..."
