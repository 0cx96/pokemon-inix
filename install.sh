#!/usr/bin/env bash

set -e

# Configuration
PROJECT_NAME="pokemon-inix"
DATA_DIR="$HOME/.local/share/$PROJECT_NAME"
BIN_DIR="/usr/local/bin"

echo "Installing $PROJECT_NAME..."

# Step 0: Check System Dependencies
check_and_install_dependencies() {
    if [ -f /etc/arch-release ]; then
        deps=("rust" "python" "python-pip" "gcc")
        missing_deps=()
        for dep in "${deps[@]}"; do
            if ! pacman -Qs "^$dep$" > /dev/null; then
                missing_deps+=("$dep")
            fi
        done
        if [ ${#missing_deps[@]} -gt 0 ]; then
            echo "Missing Arch dependencies: ${missing_deps[*]}"
            read -p "Would you like to install them now? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo pacman -S --needed "${missing_deps[@]}"
            fi
        fi
    elif [ -f /etc/debian_version ]; then
        deps=("rustc" "cargo" "python3" "python3-pip" "python3-venv" "build-essential")
        missing_deps=()
        for dep in "${deps[@]}"; do
            if ! dpkg -l "$dep" > /dev/null 2>&1; then
                missing_deps+=("$dep")
            fi
        done
        if [ ${#missing_deps[@]} -gt 0 ]; then
            echo "Missing Debian dependencies: ${missing_deps[*]}"
            read -p "Would you like to install them now? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo apt update && sudo apt install -y "${missing_deps[@]}"
            fi
        fi
    fi
}

check_and_install_dependencies

# Step 1: Rust Compilation
echo "Building Rust binary..."
cargo build --release

# Step 2: Install Binary
echo "Installing binary to $BIN_DIR (requires sudo)..."
sudo cp target/release/$PROJECT_NAME "$BIN_DIR/"

# Step 3: Setup Data Directory
echo "Setting up data directory at $DATA_DIR..."
mkdir -p "$DATA_DIR/pokemon-icons/normal"
mkdir -p "$DATA_DIR/pokemon-icons/shiny"
cp -r bin/* "$DATA_DIR/" 2>/dev/null || true

# Step 4: Python Setup & Icons
echo "Setting up Python environment for icons..."
rm -rf venv
python3 -m venv venv

# Activate venv
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
else
    echo "Failed to create virtual environment."
    exit 1
fi

pip install -r requirements.txt
python3 setup_icons.py "$@"

deactivate
rm -rf venv

# Step 5: Shell Configuration
USER_SHELL=$(basename "$SHELL")

add_line_if_missing() {
  local line="$1"
  local file="$2"
  if [ -f "$file" ]; then
    grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
  fi
}

echo "Updating shell configuration..."
case "$USER_SHELL" in
  bash)
    add_line_if_missing "export POKEMON_INIX_DATA=$DATA_DIR" "$HOME/.bashrc"
    add_line_if_missing "$PROJECT_NAME" "$HOME/.bashrc"
    ;;
  zsh)
    add_line_if_missing "export POKEMON_INIX_DATA=$DATA_DIR" "$HOME/.zshrc"
    add_line_if_missing "$PROJECT_NAME" "$HOME/.zshrc"
    ;;
  fish)
    FISH_CONF="$HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$FISH_CONF")"
    add_line_if_missing "set -x POKEMON_INIX_DATA $DATA_DIR" "$FISH_CONF"
    add_line_if_missing "$PROJECT_NAME" "$FISH_CONF"
    ;;
  *)
    echo "Manual action required: Add 'export POKEMON_INIX_DATA=$DATA_DIR' to your shell config."
    ;;
esac

echo "$PROJECT_NAME was successfully installed! :)"
