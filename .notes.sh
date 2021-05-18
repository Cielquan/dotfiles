# git data
[user]
    name = Christian Riedel
    email = cielquan@protonmail.com
    signingkey = FA3BA3BF51282609

####################################

BOLD="$(tput bold 2>/dev/null || printf '')"
GREY="$(tput setaf 0 2>/dev/null || printf '')"
UNDERLINE="$(tput smul 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"


####################################


# Detect machine
unameOut="$(uname -s)"
case "${unameOut}" in
  Linux*)     MACHINE=Linux;;
  Darwin*)    MACHINE=Mac;;
  CYGWIN*)    MACHINE=Cygwin;;
  MINGW*)     MACHINE=MinGw;;
  *)          MACHINE="UNKNOWN:${unameOut}"
esac

echo $MACHINE


####################################



sudo apt-add-repository ppa:fish-shell/release-3
sudo apt-get update
sudo apt-get install fish


cmd_exists() {
    command -v "$1" &> /dev/null
}

#################################
# https://github.com/alrra/dotfiles
# Automatically normalize line endings for all text-based files.
#
# https://git-scm.com/docs/gitattributes#_end_of_line_conversion

* text=auto

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Exclude the following files when generating an archive
#
# https://git-scm.com/book/en/Customizing-Git-Git-Attributes#Exporting-Your-Repository

.editorconfig export-ignore
.gitattributes export-ignore
.github export-ignore
src/vim/vim/pack/* export-ignore
tests export-ignore

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Override the language definitions for the following files to
# ensure that GitHub not only correctly syntax highlights them
# but also generates better language statistics.
#
# https://github.com/github/linguist

src/git/gitattributes   linguist-language=gitattributes
src/git/gitconfig       linguist-language=gitconfig
src/git/gitignore       linguist-language=gitignore
src/tmux/tmux.conf      linguist-language=sh
#################################


def osify_vscode_settings() -> None:
    """Replace `bin`/`Scripts` in venv dir paths with the other based on os."""
    if sys.platform == "win32":
        bin_dir_new = "Scripts"
        bin_dir_old = "bin"
    else:
        bin_dir_new = "bin"
        bin_dir_old = "Scripts"

    local_settings_file = [f for f in HOME_DIR.glob("**/Code/User/settings.json")]
    for file in local_settings_file:
        with open(file) as read_file:
            content = read_file.read()
        with open(file, "w") as write_file:
            write_file.write(content.replace(bin_dir_old, bin_dir_new))
