#!/usr/bin/env bash

# Clear console if possible when logging out
if [ "${SHLVL}" = 1 ] ; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q 2>/dev/null
fi
