# shellcheck disable=SC2317

echo "This file is not intended to be run!"
exit 1


# -----------------------------------------------------------------------------
# Basics (APT)
# -----------------------------------------------------------------------------
sudo apt install ca-certificates apt-transport-https
sudo apt install nano curl unzip htop ldnsutils net-tools wget


# -----------------------------------------------------------------------------
# Needed for SMB network share
# -----------------------------------------------------------------------------
sudo apt install cifs-utils


# -----------------------------------------------------------------------------
# Docker setup
# -----------------------------------------------------------------------------
sudo apt install docker.io docker-compose
# Add current user to docker group to reduce need for sudo with docker
sudo usermod -aG docker "${USER}"


# -----------------------------------------------------------------------------
# `brave-browser`
# -----------------------------------------------------------------------------
sudo curl -fsSL --proto '=https' --tlsv1.2 -o /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSL --proto '=https' --tlsv1.2 -o /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources


# -----------------------------------------------------------------------------
# KeePassXC
# -----------------------------------------------------------------------------
# NOTE: Flatpak is recommended for `keepassxc`
sudo add-apt-repository ppa:phoerious/keepassxc


# -----------------------------------------------------------------------------
# LS_COLORS
# -----------------------------------------------------------------------------
echo "check LS_COLORS for updates: https://github.com/trapd00r/LS_COLORS/"


# -----------------------------------------------------------------------------
# Python (additional versions)
# -----------------------------------------------------------------------------
sudo add-apt-repository ppa:deadsnakes/ppa
export V=3.14 && sudo apt install "python${V}" "python${V}-dev"


# -----------------------------------------------------------------------------
# Rust
# -----------------------------------------------------------------------------
curl -fsSL --proto '=https' --tlsv1.2 https://sh.rustup.rs | sh


# -----------------------------------------------------------------------------
# PNPM
# -----------------------------------------------------------------------------
curl -fsSL --proto '=https' --tlsv1.2 https://get.pnpm.io/install.sh | sh -


# -----------------------------------------------------------------------------
# Ruby (Needed by some pre-commit hooks)
# -----------------------------------------------------------------------------
sudo apt install ruby-full


# -----------------------------------------------------------------------------
# Nerdfont (needed by starship)
# -----------------------------------------------------------------------------
echo "Install a nerdfont"
mkdir -p ~/.local/share/fonts
cp fonts ~/.local/share/fonts
fc-cache -fv
fc-list | grep -i "FONT_NAME"


# -----------------------------------------------------------------------------
# Git
# -----------------------------------------------------------------------------
sudo add-apt-repository ppa:git-core/ppa
cargo install --locked git-delta


# -----------------------------------------------------------------------------
# Starship prompt
# -----------------------------------------------------------------------------
cargo install --locked starship
sudo apt install starship
curl -sS https://starship.rs/install.sh | sh


# -----------------------------------------------------------------------------
# uv (Python toolchain)
# -----------------------------------------------------------------------------
cargo install --locked uv
curl -fsSL --proto '=https' --tlsv1.2 https://astral.sh/uv/install.sh | sh


# -----------------------------------------------------------------------------
# VSCodium (`codium`)
# -----------------------------------------------------------------------------
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' \
    | sudo tee /etc/apt/sources.list.d/vscodium.sources
echo "ext list in dotfiles/vscodium/.config/VSCodium/User/extensions.txt"

# -----------------------------------------------------------------------------
# Godot
# -----------------------------------------------------------------------------
echo "Download godot from in ~/bin: https://godotengine.org/download/linux/"
# `godot` wrapper is in `dotfiles`; `godot4` is needed by a VSCode ext
ln -s godot godot4
# `godot-raw` is used in above wrapper script
ln -s ... godot-raw

echo "Download gdscript-formatter from in ~/bin:https://github.com/GDQuest/GDScript-formatter/releases"
# `godot-raw` is used in above wrapper script
ln -s ... gdscript-formatter

# -----------------------------------------------------------------------------
# General tools
# -----------------------------------------------------------------------------
cargo install --locked ripgrep
