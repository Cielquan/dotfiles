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
        FORCE="y"
        shift 1
        ;;

    -)
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
    DEFAULT_ANSWER="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
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
    DEFAULT_ANSWER="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
        info "Installing poetry."
        link="https://install.python-poetry.org"
        # shellcheck disable=2086
        curl ${CURL_ARGS} ${link} | python3 - -y
        success "Done."

        info "Setting poetry so put venv into project directory."
        # shellcheck disable=1091
        . "${HOME}/.poetry/env" && poetry config virtualenvs.in-project true
        success "Done."
        Q="Do you want to add completion for poetry in bash?"
        DEFAULT_ANSWER="yes"
        if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
            poetry completions bash > /etc/bash_completion.d/poetry.bash-completion
        fi
    fi
}
install_poetry

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install rust
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_rust() {
    Q="Do you want to install rust?"
    DEFAULT_ANSWER="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
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
    DEFAULT_ANSWER="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
        info "Downloading and running NVM."
        link="https://github.com/nvm-sh/nvm/releases/latest"
        # shellcheck disable=2086
        current_version=$(curl ${CURL_ARGS} -w "%{url_effective}" -o /dev/null ${link} | grep -Po 'v\d+\.\d+\.\d+')
        link="https://raw.githubusercontent.com/nvm-sh/nvm/${current_version}/install.sh"
        # shellcheck disable=2086
        curl ${CURL_ARGS} --create-dirs -o- "${link}" | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        success "Done."

        info "Installing latest node."
        nvm install node --latest-npm
        success "Done."

        info "Using installed node."
        nvm use node
        success "Done."

        Q="Do you want to install nodeJS package manager 'yarn' globally?"
        DEFAULT_ANSWER="yes"
        if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
            elevate_priv "install 'yarn' globally"
            (sudo npm install -g yarn)
            success "Done."
        fi
    fi
}
install_nodejs

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install ruby
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_ruby() {
    Q="Do you want to install ruby?"
    DEFAULT_ANSWER="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
        checked_install ruby-full
    fi
}
install_ruby

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Coding setup finished ..."
