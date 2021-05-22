#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)
. ${SCRIPT_DIR}/util/shell_script_utils.sh

info "Installing starship prompt ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install starship prompt and nerdfont
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if installed starship; then
    info "starship prompt is already installed."
else
    info "Installing starship prompt."
    local link="https://starship.rs/install.sh"
    curl ${CURL_ARGS} ${link} | sh -s -- -y
    success "Done."
fi

if answer_is_yes "Do you want to download 'DejaVuSansMono' Nerdfont?"; then
    local font_dir="${HOME}/.local/share/fonts"

    info "Downloading nerdfont."
    local link="https://github.com/ryanoasis/nerd-fonts/releases/latest"
    local current_version=$(curl ${CURL_ARGS} -w %{url_effective} -o /dev/null ${link} | grep -Po 'v\d+\.\d+\.\d+')
    local link="https://github.com/ryanoasis/nerd-fonts/releases/download/${current_version}/DejaVuSansMono.zip"
    curl ${CURL_ARGS} --create-dirs -o ${font_dir}/DejaVuSansMono.zip ${link}
    success "Done."

    info "Unzipping nerdfont and removing archive."
    unzip -o ${font_dir}/DejaVuSansMono.zip -d ${font_dir} 1> /dev/null
    rm -f ${font_dir}/DejaVuSansMono.zip
    success "Done."

    info "Installing nerdfont."
    local fc_installed="y"
    if ! installed fc-cache; then
        fc_installed="n"
        if answer_is_yes "For installing the 'fontconfig' package needs to be installed. Install?"; then
            direct_install fontconfig
            fc_installed="y"
        fi
    fi
    if [ ${fc_installed} = "y" ]; then
        fc-cache -f
        success "Done."
    else
        warn "Aborting install."
    fi
else
    warn "You need to install a Nerdfont yourself to (fully) utilize starship prompt."
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Installing starship prompt finished ..."
