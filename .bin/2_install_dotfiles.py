#!/usr/bin/env python3
"""Script for installing/uninstalling dotfiles."""
import argparse
import shutil
import sys

from pathlib import Path
from typing import Dict, List, Set, Tuple


if sys.version_info < (3, 6):
    raise RuntimeError("Only python version 3.6 and above are supported.")

INSTALL_LIST_TYPE = Set[str]
CONFIG_TYPE = Dict[str, str]

HOME_DIR = Path.home()
DOTFILE_DIR = Path(__file__).parents[1].absolute()
CHECK_FILE = DOTFILE_DIR.joinpath(".dotfiles_installed")
CONFIG_FILE = DOTFILE_DIR.joinpath(".config.ini")

GIT_INFOS = ["git_name", "git_email", "git_signingkey"]

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
    print("Start installing ...")

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
        elif dest_path.is_file():
            backup_path = dest_path.parent / (dest_path.name + config["backup_suffix"])
            print(f"INFO Renaming file as backup file: {backup_path}")

            try:
                dest_path.rename(backup_path)
            except FileExistsError:
                print(f"WARNING Overwriting existing backup file: {backup_path}")
                backup_path.unlink()
                dest_path.rename(backup_path)

        dest_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(orig_path, dest_path.parent)

    if "git" in install_list:
        create_git_user_file(config)


def create_git_user_file(config: CONFIG_TYPE) -> None:
    """Create/Overwrite the git user config file."""
    file_path = HOME_DIR / ".gitconfig.d" / "user.gitconfig"

    config_text = (
        "# WARNING !!!\n"
        "# This file was created by the dotfiles script.\n"
        "# Changes are overwritten when rerunning the script.\n"
        "# The file is deleted when running the script to uninstall dotfiles.\n\n"
        "[user]\n"
    )

    for info in GIT_INFOS:
        if config.get(info):
            if info == "git_signingkey" and config[info] == "":
                continue
            config_text += info[4:] + "=" + config[info] + "\n"
        else:
            try:
                data = input(f"\n\n## Please enter your {info}: ").strip()
            except EOFError:
                data = ""
                print(
                    f"Could not get user input for {info}."
                    f"Please check the config file and add data: {file_path}"
                )
            if info == "git_signingkey" and data == "":
                continue
            config_text += info[4:] + "=" + data + "\n"

    file_path.touch()
    file_path.write_text(config_text)


def uninstall(install_list: INSTALL_LIST_TYPE, config: CONFIG_TYPE) -> None:
    """Uninstall dotfiles and restoring files form existing backup files."""
    print("Start uninstalling ...")
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
        if backup_path.is_file():
            print(f"INFO Restoring from backup file: {backup_path}")
            backup_path.rename(dest_path)


def get_all_dotfiles():
    """Create list of all dotfiles in this repo."""
    len_repo_dir = len(DOTFILE_DIR.parts)
    relative_file_paths = [
        Path(*p.parts[(len_repo_dir):]) for p in DOTFILE_DIR.glob("**/*") if p.is_file()
    ]
    # Sort root dot-dirs and root files out
    return [
        p
        for p in relative_file_paths
        if not p.parts[0].startswith(".") and len(p.parts) > 1
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


def parse_config_file() -> Tuple[INSTALL_LIST_TYPE, CONFIG_TYPE]:
    """Read config file and parse its content.

    Example file content:
        install=default,prompt
        git_name=Max Mustermann
        git_email=max@mustermann.com
        git_signingkey=ABCDEFGHI123456789
        backup_suffix=.bak
    """
    if not CONFIG_FILE.is_file():
        return set(), {}

    with open(CONFIG_FILE) as conffile:
        content = conffile.read().split("\n")

    file_config_raw = [l.split("=") for l in content if l and not l.startswith("[")]
    file_config = {kv[0].strip().casefold(): kv[1].strip() for kv in file_config_raw}

    install_config = set()
    if "install" in file_config:
        install_config = set(
            [t.strip().casefold() for t in file_config.pop("install").split(",")]
        )

    return install_config, file_config


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
        "--backup-suffix",
        nargs="?",
        default="",
        help=(
            f"Overwrites the default suffix '{DEFAULT_BACKUP_SUFFIX}' "
            "for the backup files. "
            f"Can be set in config file '{CONFIG_FILE}' with 'backup_suffix='. "
            "Config hierarchy is CLI > config file > default"
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
            "For further info which target includes which directories see this script. "
            f"Can be set in config file '{CONFIG_FILE}' with 'install=' "
            "(comma separated list). "
            "Config hierarchy is CLI > config file > default"
        ),
    )
    return parser


if __name__ == "__main__":
    args = parser().parse_args()
    install_conf, conf_vars = parse_config_file()

    install_this = parse_install_list(
        args.install_list or list(install_conf) or ["default"]
    )

    if args.backup_suffix:
        conf_vars["backup_suffix"] = args.backup_suffix
    elif "backup_suffix" not in conf_vars:
        conf_vars["backup_suffix"] = DEFAULT_BACKUP_SUFFIX

    if args.install:
        install(install_this, conf_vars)
    else:
        uninstall(install_this, conf_vars)
