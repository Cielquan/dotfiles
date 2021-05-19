#!/usr/bin/env sh

# This scripts needs elevated permissions for `apt` calls

set -e
sudo -v

BIN_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd )

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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install code extensions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

while read -r line; do
    # skip empty line and lines staring with '#'
    if [ -z "$line" ] || [ $(echo $line | cut -c1-1) = "#" ]; then
        continue
    fi

    printf "\n## Extension: ${line}\n"

    echo "$(code --install-extension "${line}" --force)"
done <${BIN_DIR}/../configs/vscode/extensions.txt

# Install color theme
if ! [ -d ~/.vscode/extensions/krys-colors ]; then
    printf "\n## Install color theme\n"
    git clone https://github.com/Cielquan/krys-colors ~/.vscode/extensions/krys-colors
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
    printf "## Creating dir '$copy_target'\n"
    mkdir -p $copy_target
fi

printf "## Copying configs to '$copy_target'\n"
cp ${BIN_DIR}/../configs/vscode/settings.json $copy_target
cp ${BIN_DIR}/../configs/vscode/keybindings.json $copy_target
cp ${BIN_DIR}/../configs/vscode/sphinx_docstring_template_custom.mustache $copy_target

# OSify settings.json
sed -i "s|.venv/${old_bin}|.venv/${new_bin}|g" $copy_target/settings.json
