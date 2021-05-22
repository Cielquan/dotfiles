#!/usr/bin/env sh

# This script needs elevated permissions for `apt` calls

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)
. ${SCRIPT_DIR}/util/shell_script_utils.sh

info "Starting VSCode setup ..."
sudo -v

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install code
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if installed code; then
    info "VSCode is already installed."
else
    info "Installing VSCode"
    local link="https://packages.microsoft.com/keys/microsoft.asc"
    curl ${curl_args} ${link} | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt-get update 1> /dev/null
    direct_install code
    success "Done."
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install code extensions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Installing VSCode extensions."
while read -r line; do
    # skip empty line and lines staring with '#'
    if [ -z "$line" ] || [ $(echo $line | cut -c1-1) = "#" ]; then
        continue
    fi

    info "Extension: ${line}"
    code --install-extension "${line}" --force && success "Done." || error "Failed to install."
done <${SCRIPT_DIR}/../configs/vscode/extensions.txt

# Install color theme
if ! [ -d ~/.vscode/extensions/krys-colors ]; then
    info "Installing krys-colors color theme."
    git clone https://github.com/Cielquan/krys-colors ~/.vscode/extensions/krys-colors
    success "Done."
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   copy configs
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ -n "$APPDATA" ]; then
    copy_target="$APPDATA/Code/User"
    old_bin="bin"
    new_bin="Scripts"
else
    copy_target="$HOME/.config/Code/User"
    old_bin="Scripts"
    new_bin="bin"
fi

if ! [ -d $copy_target ]; then
    info "Creating '$copy_target'"
    mkdir -p $copy_target
fi

info "Copying configs to '$copy_target'."
cp ${SCRIPT_DIR}/../configs/vscode/settings.json $copy_target
cp ${SCRIPT_DIR}/../configs/vscode/keybindings.json $copy_target
cp ${SCRIPT_DIR}/../configs/vscode/sphinx_docstring_template_custom.mustache $copy_target
success "Done."

# OSify settings.json
info "OSify configs."
sed -i "s|.venv/${old_bin}|.venv/${new_bin}|g" $copy_target/settings.json
success "Done."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "VSCode setup finished ..."
