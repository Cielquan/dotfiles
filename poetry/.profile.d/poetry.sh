# If ~/.poetry/env exists, set ENV to that
if [ -f "$HOME"/.poetry/env ] ; then
    . "$HOME/.poetry/env"
fi
