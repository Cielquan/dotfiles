#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "${0}")")" && pwd -P)
# shellcheck disable=1091
. "${SCRIPT_DIR}/util/shell_script_utils.sh"

info "Starting coding setup ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install python versions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PY_VERSIONS="3.6 3.7 3.8 3.9"

Q="Do you want to install python versions ${PY_VERSIONS}?"
if answer_is_yes "${Q}"; then
    add_ppa deadsnakes/ppa

    echo "${PY_VERSIONS}" | tr ' ' '\n' | while read -r version; do
        checked_install "python${version}"
        direct_install "python${version}-venv" "python${version}-dev"
    done
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install and setup poetry
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Q="Do you want to install poetry?"
if answer_is_yes "${Q}"; then
    info "Installing poetry."
    link="https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py"
    curl "${CURL_ARGS}" ${link} | python3 - -y
    success "Done."

    info "Setting poetry so put venv into project directory."
    # shellcheck disable=1091
    . "${HOME}/.poetry/env" && poetry config virtualenvs.in-project true
    success "Done."
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install rust
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Q="Do you want to install rust?"
if answer_is_yes "${Q}"; then
    info "Installing rust."
    link="https://sh.rustup.rs"
    curl "${CURL_ARGS}" ${link} | sh -s -- -y
    success "Done."
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install node
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Q="Do you want to install nodeJS?"
if answer_is_yes "${Q}"; then
    checked_install nodejs
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Coding setup finished ..."
