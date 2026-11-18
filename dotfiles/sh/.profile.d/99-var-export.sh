#!/usr/bin/env sh

# Make the login environment available to apps started by systemd (e.g. terminals)
# Keep this list in sync with the variables exported in ~/.profile.d
# Only for the session's own login (non-interactive); interactive login shells
# or SSH may carry a modified PATH (e.g. an activated venv)
case $- in
    *i*) ;;
    *)
        if command -v systemctl >/dev/null 2>&1 ; then
            systemctl --user import-environment \
                PATH \
                ENV \
                EDITOR \
                PAGER \
                LANG \
                TZ \
                OS \
                XDG_CONFIG_HOME \
                LESSKEYIN \
                LESSOPEN \
                LESSCLOSE \
                GCC_COLORS \
                PIP_REQUIRE_VIRTUALENV \
                PNPM_HOME \
                SUDO_PROMPT \
                WGETRC \
                2>/dev/null
        fi
        ;;
esac
