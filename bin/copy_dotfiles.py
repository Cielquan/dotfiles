#!/usr/bin/env python3
# ruff: noqa: TRY400
"""Script to copy dotfiles."""

import argparse
import enum
import logging
import pathlib
import shutil
import sys
import typing as t
from datetime import datetime

SUCCESS_LEVEL_NUM = 20
logging.addLevelName(SUCCESS_LEVEL_NUM, "SUCCESS")


class CustomLogger(logging.Logger):
    """Custom logger."""

    def success(self, message: object, *args, **kwargs) -> None:  # noqa: ANN002, ANN003
        """Log a SUCCESS-level message."""
        if self.isEnabledFor(SUCCESS_LEVEL_NUM):
            self._log(SUCCESS_LEVEL_NUM, message, args, **kwargs)


logging.setLoggerClass(CustomLogger)
logger = t.cast("CustomLogger", logging.getLogger(__name__))


root_dir = pathlib.Path(__file__).parents[1]
home = pathlib.Path.home()

dotfiles_dir = root_dir / "dotfiles"
backup_base_dir = root_dir / "backups" / datetime.now().strftime("%Y%m%d_%H%M%S")  # noqa: DTZ005


GIT_USER_CONFIG_FILE = """\
[user]
    name=
    email=
"""


def run_cli() -> argparse.Namespace:
    """CLI definition."""
    parser = argparse.ArgumentParser(allow_abbrev=False)

    parser.add_argument(
        "--dry",
        action="store_true",
        default=False,
        help="Run in dry mode. No files will be changed",
    )
    parser.add_argument(
        "--no-color",
        action="store_true",
        default=False,
        help="Disable colorful output. Colors are automatically disabled for non-tty stdout",
    )
    parser.add_argument(
        "--missing-only",
        action="store_true",
        default=False,
        help="Only copy missing dotfiles. File content comparision is deactivated.",
    )

    log_lvl_group = parser.add_mutually_exclusive_group()
    log_lvl_group.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        default=False,
        help="Set logging level to DEBUG",
    )
    log_lvl_group.add_argument(
        "-q",
        "--quiet",
        action="store_true",
        default=False,
        help="Set logging level to WARNING",
    )

    return parser.parse_args()


class Color(enum.StrEnum):
    """ANSI color codes."""

    RESET = "\033[" + "39" + "m"
    BLACK = "\033[" + "30" + "m"
    RED = "\033[" + "31" + "m"
    GREEN = "\033[" + "32" + "m"
    YELLOW = "\033[" + "33" + "m"
    BLUE = "\033[" + "34" + "m"
    MAGENTA = "\033[" + "35" + "m"
    CYAN = "\033[" + "36" + "m"
    WHITE = "\033[" + "37" + "m"


class Style(enum.StrEnum):
    """ANSI style codes."""

    RESET = "\033[" + "0" + "m"
    BRIGHT = "\033[" + "1" + "m"
    DIM = "\033[" + "2" + "m"
    NORMAL = "\033[" + "22" + "m"


class CustomFormatter(logging.Formatter):
    """Custom logging formatter."""

    COLORS: t.ClassVar = {
        "DEBUG": Color.CYAN + Style.BRIGHT,
        "INFO": Color.GREEN + Style.BRIGHT,
        "SUCCESS": Color.GREEN + Style.BRIGHT,
        "WARNING": Color.YELLOW + Style.BRIGHT,
        "ERROR": Color.RED + Style.BRIGHT,
        "CRITICAL": Color.MAGENTA + Style.BRIGHT,
    }
    ICONS: t.ClassVar = {
        "DEBUG": ">",
        "INFO": "i",
        "SUCCESS": "✓",
        "WARNING": "!",
        "ERROR": "✗",
        "CRITICAL": "X",
    }
    RESET = Color.RESET + Style.RESET

    def __init__(self, *args, no_color: bool, **kwargs) -> None:  # noqa: ANN002, ANN003
        """Init custom logging formatter.

        Determine if colorful output should be enabled.
        """
        self.use_colors = (
            False if no_color else hasattr(sys.stdout, "isatty") and sys.stdout.isatty()
        )
        super().__init__(*args, **kwargs)

    def format(self, record: logging.LogRecord) -> str:
        """Format the logging message."""
        if self.use_colors:
            icon = self.ICONS.get(record.levelname, " ")
            color = self.COLORS.get(record.levelname, self.RESET)
            record.levelname = f"{color}[{icon}]{self.RESET}"
        else:
            record.levelname = f"{record.levelname:<8} - "

        return super().format(record)


def setup_logging(args: argparse.Namespace) -> None:
    """Set up logging."""
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(CustomFormatter(fmt="%(levelname)s %(message)s", no_color=args.no_color))
    logger.addHandler(handler)

    if args.quiet:
        level = logging.WARNING
    elif args.verbose:
        level = logging.DEBUG
    else:
        level = logging.INFO
    logger.setLevel(level)


class DotfileCopier:
    """Dotfile copy handler."""

    def __init__(self, *, dry_run: bool = False, missing_only: bool = False) -> None:
        """Init dotfile copy handler."""
        self._dry_run = dry_run
        self._missing_only = missing_only
        self._backup_base_dir_created: bool = False

        self.files_copied = 0
        self.files_skipped = 0
        self.files_ignored = 0
        self.files_failed = 0

    def _reset_stats(self) -> None:
        self.files_copied = 0
        self.files_skipped = 0
        self.files_ignored = 0
        self.files_failed = 0

    def run(self) -> int:
        """Run the dotfile copying process and print a summary afterwards.

        Also resets statistics before running.

        Returns 0 when nothing failed else 1.
        """
        self._reset_stats()

        start_msg = "Starting dotfile copy process..."
        if self._dry_run:
            summary_msg = "[DRY-RUN] " + start_msg
        logger.info(start_msg)

        self._iter_dotfiles_dir()
        rv_git_user = self._create_git_user_config_file()

        summary_msg = f"Summary: dotfiles copied: {self.files_copied}"
        if self._dry_run:
            summary_msg = "[DRY-RUN] " + summary_msg

        if self.files_skipped:
            summary_msg += f", skipped: {self.files_skipped}"
        if self.files_ignored:
            summary_msg += f", ignored: {self.files_ignored}"
        if self.files_failed:
            summary_msg += f", failed: {self.files_failed}"

        if self.files_failed:
            logger.error(summary_msg)
        else:
            logger.info(summary_msg)

        return max(min(self.files_failed, 1), rv_git_user)

    def _create_git_user_config_file(self) -> int:
        user_config_file = home / ".gitconfig.d" / "user.gitconfig"

        if user_config_file.exists():
            logger.debug("Skipping git user config file creation, already exists")
            return 0

        try:
            user_config_file.parent.mkdir(parents=True, exist_ok=True)
        except (PermissionError, OSError) as exc:
            logger.error(f"Failed to create gitconfig directory '{user_config_file.parent}': {exc}")
            return 1

        try:
            user_config_file.write_text(GIT_USER_CONFIG_FILE)
        except (PermissionError, OSError) as exc:
            logger.error(f"Failed to create git user config file '{user_config_file}': {exc}")
            return 1

        logger.warning(f"Please don't forget to update '{user_config_file}'")
        return 0

    def _iter_dotfiles_dir(self) -> None:
        """Iterate through the application dirs in the 'dotfiles' dir."""
        for path in sorted(dotfiles_dir.iterdir()):
            if path.is_dir():
                self._recursive_iter_dir_and_copy_files(path, path)
            else:
                logger.warning(f"Ignoring file in 'dotfiles' root dir '{path}'")
                self.files_ignored += 1

    def _recursive_iter_dir_and_copy_files(
        self,
        dir_path: pathlib.Path,
        relative_root_dir: pathlib.Path,
    ) -> None:
        """Recursively iterate over the given dir and copy the dotfiles accordingly."""
        path: pathlib.Path
        for path in sorted(dir_path.iterdir()):
            if path.is_dir():
                logger.debug(f"Checking dir '{path}'")
                self._recursive_iter_dir_and_copy_files(path, relative_root_dir)
            elif path.is_file():
                self._copy_dotfile(path, relative_root_dir)
            else:
                logger.warning(f"Ignoring special file '{path}'")
                self.files_ignored += 1

    def _copy_dotfile(  # noqa: PLR0911
        self,
        source_path: pathlib.Path,
        relative_root_dir: pathlib.Path,
    ) -> None:
        """Copy the given dotfile.

        The target path is checked before. If the file already exists, its content is compared.
        If the contents are the same, the file is skipped, else the target file is backed up and the
        source file is copied over.
        """
        relative_path = source_path.relative_to(relative_root_dir)
        logger.info(f"Handling dotfile '{relative_path}' ...")

        target_path = home / relative_path

        if target_path.exists():
            logger.debug(f"Target file already exists '{target_path}'")

            if self._missing_only:
                logger.info(f"Skipping '{source_path}' as '{target_path}' already exists")
                self.files_skipped += 1
                return

            if source_path.read_bytes() == target_path.read_bytes():
                logger.info(f"Skipping '{source_path}' as '{target_path}' has identical content")
                self.files_skipped += 1
                return

            if not self._backup_base_dir_created:
                logger.debug("Creating backup base directory")

                if not self._dry_run:
                    try:
                        backup_base_dir.mkdir(parents=True, exist_ok=True)
                    except (PermissionError, OSError) as exc:
                        logger.error(
                            f"Failed to create backup base directory '{backup_base_dir}': {exc}"
                        )
                        self.files_failed += 1
                        return

                self._backup_base_dir_created = True

            logger.debug(f"Backing up target file '{target_path}'")
            backup_path = backup_base_dir / relative_path
            if not self._dry_run:
                try:
                    backup_path.parent.mkdir(parents=True, exist_ok=True)
                except (PermissionError, OSError) as exc:
                    logger.error(
                        f"Failed to create sub-directory for backup '{backup_path.parent}': {exc}"
                    )
                    self.files_failed += 1
                    return

                try:
                    shutil.copy2(target_path, backup_path)
                except (PermissionError, OSError) as exc:
                    logger.error(
                        f"Failed to back-up (copy) target file '{target_path}' to '{backup_path}': {exc}"
                    )
                    self.files_failed += 1
                    return

            logger.success(f"Backed up target file '{target_path}' to '{backup_path}'")

        logger.debug(f"Copying source file '{source_path}'")
        if not self._dry_run:
            try:
                target_path.parent.mkdir(parents=True, exist_ok=True)
            except (PermissionError, OSError) as exc:
                logger.error(
                    f"Failed to create sub-directory for target '{target_path.parent}': {exc}"
                )
                self.files_failed += 1
                return

            try:
                shutil.copy2(source_path, target_path)
            except (PermissionError, OSError) as exc:
                logger.error(
                    f"Failed to copy source file '{source_path}' to '{target_path}': {exc}"
                )
                self.files_failed += 1
                return

        self.files_copied += 1
        logger.success(f"Copied source file '{source_path}' to '{target_path}'")


def main() -> int:
    """Run the script."""
    args = run_cli()

    setup_logging(args)

    dotfile_copier = DotfileCopier(dry_run=args.dry, missing_only=args.missing_only)
    return dotfile_copier.run()


if __name__ == "__main__":
    sys.exit(main())
