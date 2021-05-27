#!/usr/bin/env sh

set -e

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   utils (vendored)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

BOLD="$(tput bold 2> /dev/null || printf '')"
RED="$(tput setaf 1 2> /dev/null || printf '')"
GREEN="$(tput setaf 2 2> /dev/null || printf '')"
CYAN="$(tput setaf 6 2> /dev/null || printf '')"
NO_COLOR="$(tput sgr0 2> /dev/null || printf '')"

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "${0}")")" && pwd -P)

info() {
    printf '%b\n' "${BOLD}${CYAN}>${NO_COLOR} $*"
}

error() {
    printf '%b\n' "${RED}[x] $*${NO_COLOR}" >&2
}

success() {
    printf '%b\n' "${GREEN}[✓]${NO_COLOR} $*"
}

installed() {
    command -v "$1" 1> /dev/null 2>&1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   utils (local)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

called_locally() {
    if echo "${SCRIPT_DIR}" | grep -q .dotfiles/bin; then
        return 0
    else
        return 1
    fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Parse argv
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# DEFAULTS
DOTFILES_DIR="${HOME}/.dotfiles"

# PARSER
while [ "$#" -gt 0 ]; do
    case "$1" in
    -d | --dotfiles-dir)
        DOTFILES_DIR="$2"
        shift 2
        ;;

    -f | -y | --force | --yes)
        FORCE="y"
        shift 1
        ;;

    -d=* | --dotfiles-dir=*)
        DOTFILES_DIR="${1#*=}"
        shift 1
        ;;

    -)
        shift 1
        ;;

    *)
        error "Unknown option: $1"
        exit 1
        ;;
    esac
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Clone repo
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ -d "${DOTFILES_DIR}/.git" ]; then
    info "'dotfiles' repo found - Skip cloning."
    if ! called_locally; then
        error "Please call the script from your local machine:" \
            "${DOTFILES_DIR}/bin/00_setup.sh"
        exit 1
    fi
else
    if ! installed git; then
        error "Missing 'git' cannot clone the 'dotfiles' repo."
        info "Please install 'git' and rerun the script."
        exit 1
    fi
    info "Cloning dotfiles repo."
    git clone -q https://github.com/Cielquan/dotfiles.git "${DOTFILES_DIR}"
    success "Done."
    info "Repo is ready for usage. Call ${DOTFILES_DIR}/bin/00_setup.sh"
    exit 0
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Call scripts
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# shellcheck disable=1091
. "${SCRIPT_DIR}/util/shell_script_utils.sh"

if [ -n "${FORCE-}" ]; then
    elevate_priv "do default actions by the scripts"
fi

Q="Do you want to install the dotfiles?"
DEFAULT_ANSWER="yes"
if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
    if [ -z "${FORCE-}" ]; then
        info "Installer script's help page:"
        python3 "${SCRIPT_DIR}/10_install_dotfiles.py" --help
        info "Please see the script's help page above. If you want to customize the" \
            "install add your parameters before pressing enter."
        printf "Args: "
        read -r ARGV </dev/tty
    fi
    # shellcheck disable=2086
    python3 "${SCRIPT_DIR}/10_install_dotfiles.py" ${ARGV}
fi

printf "\n"
Q="Do you want to install linux basics? Some following scripts depend on those."
DEFAULT_ANSWER="yes"
if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
    "${SCRIPT_DIR}/20_linux_setup.sh"
fi

printf "\n"
Q="Do you want to install additional software for linux?."
DEFAULT_ANSWER="yes"
if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
    "${SCRIPT_DIR}/21_additional_software.sh" "-${FORCE}"
fi

printf "\n"
Q="Do you want to install starship prompt? Its automatically used by bash."
DEFAULT_ANSWER="no"
if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
    "${SCRIPT_DIR}/30_prompt_setup.sh" "-${FORCE}"
fi

printf "\n"
Q="Do you want to install LS-COLORS?"
DEFAULT_ANSWER="yes"
if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
    "${SCRIPT_DIR}/31_ls_colors.sh"
fi

printf "\n"
Q="Do you want to install coding setup (languages)?"
DEFAULT_ANSWER="no"
if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
    "${SCRIPT_DIR}/40_coding_setup.sh" "-${FORCE}"
fi

printf "\n"
Q="Do you want to install and setup VSCode?"
DEFAULT_ANSWER="no"
if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
    "${SCRIPT_DIR}/41_vscode_setup.sh" "-${FORCE}"
fi

printf "\n"
info "Installation of a nerdfont is highly recommend if you installed starship prompt."
Q="Do you want to install the vendored nerdfont?"
DEFAULT_ANSWER="no"
if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT}"; then
    "${SCRIPT_DIR}/42_nerdfonts.sh" "-${FORCE}"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n"
success "Setup finished please reboot your system to fully finish the installation."
