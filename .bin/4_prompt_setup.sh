#!/usr/bin/env sh

set -e

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install starship prompt and nerdfont
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if ! command -v starship > /dev/null 2>&1; then
    printf "\n\n## Installing starship prompt\n"
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
else
    printf "## starship prompt is installed\n"
fi

printf "\n\n## Installing nerdfont\n"
current_version=$(curl -sSL -w %{url_effective} -o /dev/null https://github.com/ryanoasis/nerd-fonts/releases/latest | grep -Po 'v\d+\.\d+\.\d+')
mkdir -p ~/Downloads
wget -qO ~/Downloads/DejaVuSansMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/${current_version}/DejaVuSansMono.zip
mkdir -p ~/.local/share/fonts
unzip -o ~/Downloads/DejaVuSansMono.zip -d ~/.local/share/fonts/ 1> /dev/null
fc-cache -f
