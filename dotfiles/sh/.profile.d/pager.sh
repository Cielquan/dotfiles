# If we don't have less(1), we'll just use whatever pager the application or
# system deems fit
command -v less >/dev/null 2>&1 || return

# Use less(1) as my PAGER
PAGER=less
export PAGER
