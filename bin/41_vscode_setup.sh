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

info "Starting VSCode setup ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install code
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_code() {
    Q="Do you want to install VSCode?"
    DEFAULT="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
        if installed code; then
            info "VSCode is already installed."
        else
            info "Installing VSCode ppa."

            info "Installing mircosoft packages keyring."
            link="https://packages.microsoft.com/keys/microsoft.asc"
            # shellcheck disable=2086
            curl ${CURL_ARGS} "${link}" | gpg --dearmor > packages.microsoft.gpg
            elevate_priv "install keyring"
            sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
            rm -f packages.microsoft.gpg
            success "Done."

            apt_source="deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main"
            add_apt_source "${apt_source}" "vscode.list"

            direct_install code
        fi
    fi
}
install_code

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install code extensions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
install_code_extensions() {
    Q="Do you want to install VSCode extionsions from the list?"
    DEFAULT="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
        info "Installing VSCode extensions."
        while read -r line; do
            # skip empty line and lines staring with '#'
            if [ -z "$line" ] || [ "$(echo "${line}" | cut -c1-1)" = "#" ]; then
                continue
            fi

            info "Extension: ${line}"
            if code --install-extension "${line}" --force; then
                success "Done."
            else
                error "Failed to install."
            fi
        done <"${SCRIPT_DIR}/../configs/vscode/extensions.txt"

        # Install color theme
        if ! [ -d "${HOME}/.vscode/extensions/krys-colors" ]; then
            info "Installing krys-colors color theme."
            git clone https://github.com/Cielquan/krys-colors "${HOME}/.vscode/extensions/krys-colors"
            success "Done."
        fi
    fi
}
install_code_extensions

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Copy configs
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

copy_code_configs() {
    Q="Do you want to copy the VSCode configuration files?"
    DEFAULT="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then

        if [ -n "${APPDATA}" ]; then
            copy_target=$(echo "${APPDATA}/Code/User" | sed 's|\\|/|g')
            old_bin="bin"
            new_bin="Scripts"
        else
            copy_target="${HOME}/.config/Code/User"
            old_bin="Scripts"
            new_bin="bin"
        fi

        if ! [ -d "${copy_target}" ]; then
            info "Creating '${copy_target}'"
            mkdir -p "${copy_target}"
        fi

        info "Copying configs to '${copy_target}'."
        cp "${SCRIPT_DIR}/../configs/vscode/settings.json" "${copy_target}"
        cp "${SCRIPT_DIR}/../configs/vscode/keybindings.json" "${copy_target}"
        cp "${SCRIPT_DIR}/../configs/vscode/sphinx_docstring_template_custom.mustache" "${copy_target}"
        success "Done."

        # OSify settings.json
        info "OSify configs."
        # Switch `bin` and `Scripts` for python venvs accoring to OS
        sed -i "s|.venv/${old_bin}|.venv/${new_bin}|g" "${copy_target}/settings.json"
        # Fix path for `sphinx_docstring_template_custom.mustache` file
        export old="\"autoDocstring.customTemplatePath\": \".*sphinx_docstring_template_custom.mustache\","
        export new="\"autoDocstring.customTemplatePath\": \"${copy_target}/sphinx_docstring_template_custom.mustache\","
        sed -i "s|${old}|${new}|g" "${copy_target}/settings.json"
        success "Done."
    fi
}
copy_code_configs

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "VSCode setup finished ..."
