#!/usr/bin/env bash

set -euox pipefail

out="$HOME/pc-backup/software"

mkdir -p "$out/apt-sources"

apt-mark showmanual | sort > "$out/apt-manual.txt"
cp /etc/apt/sources.list.d/* "$out/apt-sources/"

flatpak list --app --columns=application,origin > "$out/flatpak.txt"

cargo install --list > "$out/cargo.txt"

flatpak run com.github.mtkennerly.ludusavi backup --force
