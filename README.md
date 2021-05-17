# Prerequisites

You need python 3.6 or newer to run the installer script.

# Usage

### Git clone repo and run setup script
```
git clone https://github.com/Cielquan/dotfiles.git
./dotfiles/.bin/1_setup.sh
```

or oneliner with ``curl``:
```
curl -sSL https://raw.githubusercontent.com/Cielquan/dotfiles/main/.bin/0_clone.sh | sh -s
```
or with ``wget``:
```
wget -qO - https://raw.githubusercontent.com/Cielquan/dotfiles/main/.bin/0_clone.sh | sh -s
```

### Scripts
In the repo's ``.bin`` directory are all the scripts for usage of the repo.

The ``0_clone.sh`` script is intendet to be used like above for the oneliner install.

The ``1_setup.sh`` script is intendet to call all the other script.

The python script ``2_install_dotfiles.py`` (for installing the dotfiles) has CLI
options. Run the script with ``--help`` for more information about the script and
its possibilities.
To uninstall the dotfiles run the python script again with the `--uninstall` flag.

The ``3_linux_setup.sh`` script installs basic tooling.

The ``4_prompt_setup.sh`` script installs the [starship prompt](https://starship.rs/)
and the [nerd font](https://www.nerdfonts.com/) DejaVuSansMono for starship prompt to
use. The prompt is automatically loaded by the bash config from this repo.

The ``5_coding_setup.sh`` script installs the deadsnakes ppa and from there python
versions 3.6 to 3.9, but keeps the default installed one. The corresponding
pythonX.Y-venv and pythonX.Y-dev packages are also installed. Then
[poetry](https://python-poetry.org/) is installed and configured to create python venvs
inside the project dirs. Then rust and nodejs are installed. At last VSCode is
installed.


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
