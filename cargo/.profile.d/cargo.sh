# If ~/.cargo/env exists, set ENV to that
if [ -f "$HOME"/.cargo/env ] ; then
    . "$HOME/.cargo/env"
fi
