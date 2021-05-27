#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "${0}")")" && pwd -P)
# shellcheck disable=1091
. "${SCRIPT_DIR}/util/shell_script_utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Parse argv
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# PARSER
while [ "$#" -gt 0 ]; do
    case "$1" in

    -f | -y | --force | --yes)
        FORCE="yes"
        shift 1
        ;;

    -- | -n | --no)
        shift 1
        ;;

    *)
        error "Unknown option: $1"
        exit 1
        ;;
    esac
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   START
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Starting coding setup ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install python versions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_python_versions() {
    PY_VERSIONS="${1}"
    Q="Do you want to install python versions ${PY_VERSIONS}?"
    DEFAULT="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
        add_ppa deadsnakes/ppa

        echo "${PY_VERSIONS}" | tr ' ' '\n' | while read -r version; do
            checked_install "python${version}"
            direct_install "python${version}-venv" "python${version}-dev"
        done
    fi
}
install_python_versions "3.6 3.7 3.8 3.9"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install and setup poetry
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_poetry() {
    Q="Do you want to install poetry?"
    DEFAULT="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
        info "Installing poetry."
        link="https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py"
        # shellcheck disable=2086
        curl ${CURL_ARGS} ${link} | python3 - -y
        success "Done."

        info "Setting poetry so put venv into project directory."
        # shellcheck disable=1091
        . "${HOME}/.poetry/env" && poetry config virtualenvs.in-project true
        success "Done."
    fi
}
install_poetry

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install rust
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_rust() {
    Q="Do you want to install rust?"
    DEFAULT="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
        info "Installing rust."
        link="https://sh.rustup.rs"
        # shellcheck disable=2086
        curl ${CURL_ARGS} ${link} | sh -s -- -y
        success "Done."
    fi
}
install_rust

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install node
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_nodejs() {
    Q="Do you want to install nodeJS?"
    DEFAULT="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
        checked_install nodejs
    fi
}
install_nodejs

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Coding setup finished ..."
