#!/usr/bin/env python3
"""Script to install VSCodium extensions."""

import subprocess
import sys

EXTENSIONS: dict[str, list[str]] = {
    "Editor - look / theme": [
        "cielquan.krys-colors",
        "file-icons.file-icons",
        "oderwat.indent-rainbow",
    ],
    "Editor - usability": [
        "usernamehw.errorlens",
        "eamodio.gitlens",
        "FanaticPythoner.better-todo-tree",
        "formulahendry.auto-rename-tag",
        "patbenatar.advanced-new-file",
        "sleistner.vscode-fileutils",
    ],
    "Binary file support": [
        # "tomoki1207.pdf",
    ],
    "NeoVim": [
        "asvetliakov.vscode-neovim",
    ],
    # Languages
    "Python": [
        "ms-python.python",
        "charliermarsh.ruff",
        "astral-sh.ty",
        "njpwerner.autodocstring",
        # "tcwalther.cython",
    ],
    "Rust": [
        "rust-lang.rust-analyzer",
        "BarbossHack.crates-io",
    ],
    "JavaScript / TypeScript (JS / TS) && HTML / CSS / JSX (web)": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "Orta.vscode-twoslash-queries",
        "wix.vscode-import-cost",
        # "dsznajder.es7-react-js-snippets",
        # "bradlc.vscode-tailwindcss",
        # "tlent.jest-snapshot-language-support",
    ],
    "Lua": [
        "sumneko.lua",
        "JohnnyMorganz.stylua",
    ],
    "Shell (bash, sh)": [
        "timonwong.shellcheck",
    ],
    "Godot": [
        "geequlim.godot-tools",
        "DoHe.godot-format",
    ],
    "TOML": [
        "tamasfe.even-better-toml",
    ],
    "YAML": [
        "redhat.vscode-yaml",
    ],
    "SQL": [
        "mtxr.sqltools",
        "alexcvzz.vscode-sqlite",
        "sqlfluff.vscode-sqlfluff",
    ],
    "CSV": [
        "mechatroner.rainbow-csv",
    ],
    "Excel": [
        # "GrapeCity.gc-excelviewer",
    ],
    "Gettext": [
        "mrorz.language-gettext",
    ],
    "Docker": [
        "jeff-hykin.better-dockerfile-syntax",
    ],
    "Jinja2": [
        "samuelcolvin.jinjahtml",
    ],
    "Markdown (md)": [
        # "yzhang.markdown-all-in-one",
    ],
    "reStructuredText (rst)": [
        "trond-snekvik.simple-rst",
        "lextudio.restructuredtext",
    ],
    "VSCode only": [
        # "ms-vscode-remote.remote-ssh",
    ],
}


def main() -> int:
    """Run the script."""
    for section_ext_list in EXTENSIONS.values():
        for ext in section_ext_list:
            subprocess.run(["codium", "--install-extension", ext], check=True)  # noqa: S603, S607

    return 0


if __name__ == "__main__":
    sys.exit(main())
