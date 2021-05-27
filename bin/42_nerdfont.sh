#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "${0}")")" && pwd -P)
# shellcheck disable=1091
. "${SCRIPT_DIR}/util/shell_script_utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Parse argv
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# PARSER
while [ "$#" -gt 0 ]; do
    case "$1" in

    -f | -y | --force | --yes)
        FORCE="yes"
        shift 1
        ;;

    -- | -n | --no)
        shift 1
        ;;

    *)
        error "Unknown option: $1"
        exit 1
        ;;
    esac
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   START
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Installing nerdfonts ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install vendored nerdfont
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_nerdfonts() {
    Q="Do you want to install vendored nerdfonts?"
    DEFAULT_ANSWER="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then

        if [ -n "${APPDATA}" ]; then
            font_target_dir="/c/Windows/Fonts"
            font_source_dir="${SCRIPT_DIR}/../fonts/windows"
            os="win"
        else
            font_target_dir="${HOME}/.local/share/fonts"
            font_source_dir="${SCRIPT_DIR}/../fonts/linux"
            os="lin"
            if ! [ -d "${font_target_dir}" ]; then
                mkdir -p "${font_target_dir}"
            fi
        fi

        if test_writeable "${font_target_dir}"; then
            sudo=""
        else
            sudo="sudo"
            elevate_priv "add fonts"
        fi
        info "Copying nerdfonts. (Skipping existing)"
        # shellcheck disable=2086
        ${sudo} find "${font_source_dir}" -type f -exec cp {} "${font_target_dir}" \;
        success "Done."

        if [ "${os}" = "lin" ]; then
            info "Installing nerdfont."
            fc_installed="y"
            if ! installed fc-cache; then
                fc_installed="n"
                Q="For installation the 'fontconfig' package needs to be installed. Install?"
                DEFAULT_ANSWER="yes"
                if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
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
            info "The fonts should be available after rebooting ht system."
        fi
    fi
}
install_nerdfonts

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Installing nerdfonts finished ..."
