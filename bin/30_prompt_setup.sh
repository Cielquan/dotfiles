#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "${0}")")" && pwd -P)
# shellcheck disable=1091
. "${SCRIPT_DIR}/util/shell_script_utils.sh"

info "Installing starship prompt ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install starship prompt
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if installed starship; then
    info "starship prompt is already installed."
else
    info "Installing starship prompt."
    link="https://starship.rs/install.sh"
    curl "${CURL_ARGS}" ${link} | sh -s -- -y
    success "Done."
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install DejaVuSansMono nerdfont
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Q="Do you want to download 'DejaVuSansMono' Nerdfont?"
if answer_is_yes "${Q}"; then
    font_dir="${HOME}/.local/share/fonts"

    info "Downloading nerdfont."
    link="https://github.com/ryanoasis/nerd-fonts/releases/latest"
    current_version=$(curl "${CURL_ARGS}" -w "%{url_effective}" -o /dev/null ${link} | grep -Po 'v\d+\.\d+\.\d+')
    link="https://github.com/ryanoasis/nerd-fonts/releases/download/${current_version}/DejaVuSansMono.zip"
    curl "${CURL_ARGS}" --create-dirs -o "${font_dir}/DejaVuSansMono.zip" "${link}"
    success "Done."

    info "Unzipping nerdfont and removing archive."
    unzip -o "${font_dir}/DejaVuSansMono.zip" -d "${font_dir}" 1> /dev/null
    rm -f "${font_dir}/DejaVuSansMono.zip"
    success "Done."

    info "Installing nerdfont."
    fc_installed="y"
    if ! installed fc-cache; then
        fc_installed="n"
        Q="For installing the 'fontconfig' package needs to be installed. Install?"
        if answer_is_yes "${Q}"; then
            direct_install fontconfig
            fc_installed="y"
        fi
    fi
    if [ "${fc_installed}" = "y" ]; then
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
