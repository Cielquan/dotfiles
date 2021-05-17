# git data
[user]
    name = Christian Riedel
    email = cielquan@protonmail.com
    signingkey = FA3BA3BF51282609

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
