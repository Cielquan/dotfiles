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
    local link="https://starship.rs/install.sh"
    curl ${curl_args} ${link} | sh -s -- -y
    success "Done"
fi

if answer_is_yes "Do you want to install 'DejaVuSansMono' Nerdfont?"; then
    info "Installing nerdfont"
    local link="https://github.com/ryanoasis/nerd-fonts/releases/latest"
    local current_version=$(curl ${curl_args} -w %{url_effective} -o /dev/null ${link} | grep -Po 'v\d+\.\d+\.\d+')
    local link="https://github.com/ryanoasis/nerd-fonts/releases/download/${current_version}/DejaVuSansMono.zip"
    curl ${curl_args} -o DejaVuSansMono.zip ${link}
    mkdir -p ${HOME}/.local/share/fonts
    unzip -o DejaVuSansMono.zip -d ${HOME}/.local/share/fonts/ 1> /dev/null
    rm -f DejaVuSansMono.zip
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
