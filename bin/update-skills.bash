#!/usr/bin/env bash

set -euox pipefail

pushd dotfiles/claude

pnpx skills update --project

popd
