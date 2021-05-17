#!/usr/bin/env sh

set -e

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install starship prompt and nerdfont
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ -f ~/.config/starship/starship.toml ]; then
    if ! command -v starship > /dev/null 2>&1; then
        printf "\n\n## Installing starship prompt\n"
        curl -fsSL https://starship.rs/install.sh | sh -s -- -y
    else
        printf "## starship prompt is installed\n"
    fi

    printf "\n\n## Installing nerdfont\n"
    version=$(curl -sS https://github.com/ryanoasis/nerd-fonts/releases/latest | grep -Po 'v\d+\.\d+\.\d+')
    curl -sSL -o ~/Downloads/DejaVuSansMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/DejaVuSansMono.zip
    mkdir -p ~/.local/share/fonts
    unzip -o ~/Downloads/DejaVuSansMono.zip -d ~/.local/share/fonts/
    fc-cache -fv
fi
