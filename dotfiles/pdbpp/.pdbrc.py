#!/usr/bin/env python3
"""Custom PDB++ config.

Last commit on PDB++ was 2022-07-14, so it seems to be dead.
"""

import pdb


class Config(pdb.DefaultConfig):  # ty:ignore[unresolved-attribute]
    """Custom PDB config."""

    editor = "nano"
    stdin_paste = "epaste"
    filename_color = pdb.Color.lightgray  # ty:ignore[unresolved-attribute]
    use_terminal256formatter = False

    def __init__(self) -> None:
        """Init custom PDB++ config."""
        try:
            from pygments.formatters import terminal  # noqa: PLC0415
        except ImportError:
            pass
        else:
            self.colorscheme = terminal.TERMINAL_COLORS.copy()
            self.colorscheme.update(
                {
                    terminal.Keyword: ("darkred", "red"),
                    terminal.Number: ("darkyellow", "yellow"),
                    terminal.String: ("brown", "green"),
                    terminal.Name.Function: ("darkgreen", "blue"),
                    terminal.Name.Namespace: ("teal", "turquoise"),
                }
            )

    def setup(self, pdb) -> None:  # noqa: ANN001
        """Set up PDB++."""
        # make 'l' an alias to 'longlist'
        Pdb = pdb.__class__  # noqa: N806
        Pdb.do_l = Pdb.do_longlist
        Pdb.do_st = Pdb.do_sticky
