#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)
. ${SCRIPT_DIR}/util/shell_script_utils.sh

info "Installing starship prompt ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install starship prompt and nerdfont
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if installed starship; then
    info "starship prompt is already installed"
else
    info "Installing starship prompt"
    wget -qO- https://starship.rs/install.sh | sh -s -- -y
    success "Done"
fi

if answer_is_yes "Do you want to install 'DejaVuSansMono' Nerdfont?"; then
    info "Installing nerdfont"
    local current_version=$(curl -sSL -w %{url_effective} -o /dev/null https://github.com/ryanoasis/nerd-fonts/releases/latest | grep -Po 'v\d+\.\d+\.\d+')
    mkdir -p ~/Downloads
    wget -qO ~/Downloads/DejaVuSansMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/${current_version}/DejaVuSansMono.zip
    mkdir -p ~/.local/share/fonts
    unzip -o ~/Downloads/DejaVuSansMono.zip -d ~/.local/share/fonts/ 1> /dev/null
    direct_install fontconfig
    fc-cache -f
    success "Done"
else
    warn "You need to install a Nerdfont yourself to (fully) utilize starship prompt."
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Installing starship prompt finished ..."
