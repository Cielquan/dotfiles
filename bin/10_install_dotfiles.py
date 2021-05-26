#!/usr/bin/env python3
"""Script for installing/uninstalling dotfiles."""
import argparse
import shutil
import sys

from pathlib import Path
from typing import Dict, List, Set


if sys.version_info < (3, 6):
    raise RuntimeError("Only python version 3.6 and above are supported.")

INSTALL_LIST_TYPE = Set[str]
CONFIG_TYPE = Dict[str, str]

HOME_DIR = Path.home()
DOTFILE_DIR = Path(__file__).parents[1].joinpath("dotfiles").absolute()

GIT_INFOS = ["git_name", "git_email", "git_signingKey"]

DEFAULT_BACKUP_SUFFIX = ".df.bak"
INSTALL_LISTS = {
    "bash": ["sh", "bash"],
    "bin": ["bin"],
    "cargo": ["cargo"],
    "curl": ["curl"],
    "git": ["git"],
    "gpg": ["gpg"],
    "less": ["less"],
    "pdb": ["pdb"],
    "pdbpp": ["pdbpp"],
    "pip": ["pip"],
    "poetry": ["poetry"],
    "sh": ["sh"],
    "starship": ["bash", "starship"],
    "wget": ["wget"],
    "default": ["bash", "bin", "curl", "less", "wget"],
    "prompt": ["starship"],
    "coding": ["cargo", "git", "gpg", "pdb", "pdbpp", "pip", "poetry"],
}
INSTALL_LISTS["all"] = [k for k in INSTALL_LISTS if k != "all"]


def install(install_list: INSTALL_LIST_TYPE, config: CONFIG_TYPE) -> None:
    """Install dotfiles and backup existing files."""
    print("INFO Start installing dotfiles ...")

    for file in get_all_dotfiles():
        if file.parts[0] not in install_list:
            continue

        print(f"INFO Copying file: '{file}'")

        dest_path = HOME_DIR / Path(*file.parts[1:])
        orig_path = DOTFILE_DIR / file

        if dest_path.is_dir():
            print(f"ERROR Skipping. Destination is a directory: {dest_path}")
            continue
        elif dest_path.is_symlink():
            print(f"WARNING Overwriting existing symlink: {dest_path}")
            dest_path.unlink()
        elif dest_path.exists() and not dest_path.is_file():
            print(f"ERROR Skipping. Path is not a dir/symlink/file: {dest_path}")
            continue
        elif dest_path.is_file() and config["backup"]:
            backup_path = dest_path.parent / (dest_path.name + config["backup_suffix"])
            print(f"INFO Renaming file as backup file: {backup_path}")

            try:
                dest_path.rename(backup_path)
            except FileExistsError:
                print(f"WARNING Overwriting existing backup file: {backup_path}")
                backup_path.unlink()
                dest_path.rename(backup_path)

        dest_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(orig_path, dest_path.parent, follow_symlinks=True)

    if "git" in install_list:
        create_git_user_file()
        print(
            "WARNING The gitconfig uses 'bright' colors added in version 2.26.0. "
            "Please make sure that your git version is greater or equal elsewise you "
            "will experience errors when running 'git'."
        )

    print("SUCCESS Installing dotfiles finished ...")


def create_git_user_file() -> None:
    """Create/Overwrite the git user config file."""
    file_path = HOME_DIR / ".gitconfig.d" / "user.gitconfig"

    config_text = (
        "# WARNING !!!\n"
        "# This file was created by the dotfiles script.\n"
        "# Changes are overwritten when rerunning the script.\n"
        "# The file is deleted when running the script to uninstall dotfiles.\n\n"
        "[user]\n"
    )

    print("## For the git config some data is required. The signingkey is optional.")

    for info in GIT_INFOS:
        try:
            data = input(f"## Please enter your {info}: ").strip()
        except EOFError:
            data = ""
            print(
                f"\nERROR Could not get user input for {info}. "
                f"Please check the config file and add data: {file_path}"
            )
        if info == "git_signingKey" and data == "":
            continue
        config_text += info[4:] + "=" + data + "\n"

    file_path.touch()
    file_path.write_text(config_text)


def uninstall(install_list: INSTALL_LIST_TYPE, config: CONFIG_TYPE) -> None:
    """Uninstall dotfiles and restoring files form existing backup files."""
    print("INFO Start uninstalling dotfiles ...")
    print("INFO Directories are not removed.")

    for file in get_all_dotfiles():
        if file.parts[0] not in install_list:
            continue

        print(f"INFO Removing file: '{file}'")

        dest_path = HOME_DIR / Path(*file.parts[1:])

        if dest_path.is_dir():
            print(f"ERROR Skipping. Destination is a directory: {dest_path}")
            continue
        elif dest_path.is_symlink():
            print(f"ERROR Skipping. Destination is a symlink: {dest_path}")
            continue
        elif dest_path.exists() and not dest_path.is_file():
            print(f"ERROR Skipping. Path is not a dir/symlink/file: {dest_path}")
            continue
        elif dest_path.is_file():
            dest_path.unlink()

        backup_path = dest_path.parent / (dest_path.name + config["backup_suffix"])
        if backup_path.is_file() and config["backup"]:
            print(f"INFO Restoring from backup file: {backup_path}")
            backup_path.rename(dest_path)

    print("SUCCESS Uninstalling dotfiles finished ...")


def get_all_dotfiles():
    """Create list of all dotfiles."""
    len_df_dir = len(DOTFILE_DIR.parts)
    return [
        Path(*p.parts[len_df_dir:]) for p in DOTFILE_DIR.glob("**/*") if p.is_file()
    ]


def parse_install_list(list_to_install: List[str]) -> INSTALL_LIST_TYPE:
    """Parse given list with install targets recursively."""
    install_this = set()

    def parse_target_recursive(target_to_install: str) -> None:
        """Get given target from `install_lists` and parse it."""
        target = INSTALL_LISTS.get(target_to_install)
        if target is None:
            return
        if len(target) == 1:
            install_this.add(target[0])
        else:
            for dependency in target:
                if dependency == target_to_install:
                    install_this.add(dependency)
                else:
                    parse_target_recursive(dependency)

    for target_to_install in list_to_install:
        parse_target_recursive(target_to_install)

    return install_this


def parser() -> argparse.ArgumentParser:
    """Create a CLI parser."""
    parser = argparse.ArgumentParser(description="Installer for dotfiles.")
    parser.add_argument(
        "--uninstall",
        dest="install",
        action="store_false",
        help=(
            "Uninstall dotfiles by removing them and restoring old files "
            "from backup files if they exist."
        ),
    )
    parser.add_argument(
        "--no-backup",
        dest="backup",
        action="store_false",
        help=(
            "Do not backup existing files. Just overwrite them."
            "When `--uninstall`  is set do not restore backup files."
        ),
    )
    parser.add_argument(
        "--backup-suffix",
        nargs="?",
        default="",
        help=(
            f"Overwrites the default suffix '{DEFAULT_BACKUP_SUFFIX}' "
            "for the backup files. "
        ),
    )
    parser.add_argument(
        "--install-list",
        metavar="TARGET",
        nargs="*",
        default=[],
        help=(
            f"Overwrites the default install-list: {INSTALL_LISTS['default']}. "
            f"Valid targets are: {[k for k in INSTALL_LISTS]}. "
            "Install-list also applies when uninstalling. "
            "For further info which target includes which directories see this script."
        ),
    )
    return parser


if __name__ == "__main__":
    args = parser().parse_args()
    install_this = parse_install_list(args.install_list or ["default"])

    conf_vars = {}

    conf_vars["backup"] = args.backup

    if args.backup_suffix:
        conf_vars["backup_suffix"] = args.backup_suffix
    else:
        conf_vars["backup_suffix"] = DEFAULT_BACKUP_SUFFIX

    if args.install:
        install(install_this, conf_vars)
    else:
        uninstall(install_this, conf_vars)
