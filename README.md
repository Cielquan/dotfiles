# Prerequisites

The installer scripts are mostly shell script, except for the dotfiles installer script
which is a python script.

Therefore you need:
- POSIX compliant shell
- apt package manager
- python >3.6

# Usage

## Git clone repo and run setup script
```
git clone https://github.com/Cielquan/dotfiles.git
./dotfiles/bin/00_setup.sh
```

or oneliner with `curl`:
```
curl -sSL https://raw.githubusercontent.com/Cielquan/dotfiles/main/bin/00_setup.sh | sh -s && ~/.dotfiles/bin/00_setup.sh
```
or with `wget`:
```
wget -qO - https://raw.githubusercontent.com/Cielquan/dotfiles/main/bin/00_setup.sh | sh -s && ~/.dotfiles/bin/00_setup.sh
```

## Scripts
You can find all the scripts to utilize this repo inside the `/bin` directory.

#### `00_setup.sh`
This shell script will install git if missing and then git clone the repo if its not
called from within the repo (like in the oneliner setups above). If it is called from
within it will call all the other scripts in numeric order.

#### `10_install_dotfiles.py`
This python script installes the dotfiles you can find inside the `/dotfiles` directory.
It will rename existing files by appending a suffix und then copy the files to their locations.
The script can take different configuration via it's CLI. Call the script with `--help`
for more information about its options.
To uninstall the dotfiles run the python script again with the `--uninstall` switch.
This will delete the installed files and remove the backup suffix

#### `20_linux_setup.sh`
This script installs basic linux tooling. At first it will install `ca-certificates`
and `apt-transport-https`, add the git ppa and upgrade the system. Afterwards some
packages are installed. See the top of the script for the packages. Some following
scripts depend on some packages installed by this script.

#### `30_prompt_setup.sh`
This script installs the [starship prompt](https://starship.rs/)
and the [nerd font](https://www.nerdfonts.com/) DejaVuSansMono for starship prompt to
use. The prompt is automatically loaded by the bash config from this repo.

#### `40_coding_setup.sh`
This script installs programming langauges and some tooling for them.
The deadsnakes ppa is added and from there different python versions are installed.
See the top of the script for the actual versions. But it keeps the default installed
one. The corresponding pythonX.Y-venv and pythonX.Y-dev packages are also installed for
all versions. Then [poetry](https://python-poetry.org/) is installed and configured to create python venvs inside the project dirs. Then rust and nodejs are installed.

#### `41_vscode_setup.sh`
This script installs the VS Code IDE. Afterwards my default config and keybindings are
copied to there location on the system and the extensions from the `extensions.txt` file
are installed. You can find the mentioned files in `/configs/vscode` directory.

# Acknowledgements
Thanks to those inspiring repos:
- https://github.com/flipsidecreations/dotfiles
- https://github.com/pgporada/dotfiles
- https://github.com/alrra/dotfiles
- https://github.com/zellwk/dotfiles
- https://sanctum.geek.nz/cgit/dotfiles.git/about
- https://github.com/necolas/dotfiles
- https://github.com/janmoesen/tilde
- https://github.com/cowboy/dotfiles
