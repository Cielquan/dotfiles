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
    echo '##########'
    # skip empty line and lines staring with '#'
    if [ -z "$line" ] || [ $(echo $line | cut -c1-1) = "#" ]; then
        continue
    fi

    echo $line

    do_inactivate=$(echo "$line" | grep -qe inactive && echo 1 || echo 0)

    if [ $do_inactivate = 1 ]; then
        line=$(echo $line | sed 's/ (inactive)//')
    fi

    $(code --install-extension --force $line)

    if [ $do_inactivate = 1 ]; then
        $(code --disable-extension $line)
    fi
done <${BIN_DIR}/../configs/vscode/extensions.txt