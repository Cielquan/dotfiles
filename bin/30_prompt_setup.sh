#!/usr/bin/env sh

set -e
printf "\n"

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)
. ${SCRIPT_DIR}/util/shell_script_utils.sh

info "Installing starship prompt ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install starship prompt and nerdfont
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if ! installed starship; then
    info "Installing starship prompt"
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
    success "Done"
else
    info "starship prompt is already installed"
fi

info "Installing nerdfont"
current_version=$(curl -sSL -w %{url_effective} -o /dev/null https://github.com/ryanoasis/nerd-fonts/releases/latest | grep -Po 'v\d+\.\d+\.\d+')
mkdir -p ~/Downloads
wget -qO ~/Downloads/DejaVuSansMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/${current_version}/DejaVuSansMono.zip
mkdir -p ~/.local/share/fonts
unzip -o ~/Downloads/DejaVuSansMono.zip -d ~/.local/share/fonts/ 1> /dev/null
fc-cache -f
success "Done"

success "starship prompt installed ..."
