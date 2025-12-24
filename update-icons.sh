#!/usr/bin/env bash

# This script automates the update of pokemon-icons in default.nix

# 1. Check for updates using nvchecker
echo "Checking for new icons on GitHub..."
NV_OUTPUT=$(nvchecker -c nvchecker.toml --json)

NEW_COMMIT=$(echo "$NV_OUTPUT" | grep -oP '(?<="version": ")[^"]+')

if [ -z "$NEW_COMMIT" ]; then
    echo "Could not find latest commit. Are you offline?"
    exit 1
fi

# Get current commit from setup_icons.py
CURRENT_COMMIT=$(grep -oP '(?<=trees/)[a-f0-9]{40}' setup_icons.py)

if [ "$NEW_COMMIT" == "$CURRENT_COMMIT" ]; then
    echo "Icons are already up to date ($NEW_COMMIT)."
    exit 0
fi

echo "New icons found!"
echo "Old Commit: $CURRENT_COMMIT"
echo "New Commit: $NEW_COMMIT"

# 2. Prefetch the new hash
echo "Calculating new hash (this may take a minute)..."

# Path to the files we need to modify
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
DEFAULT_NIX="$SCRIPT_DIR/default.nix"
SETUP_ICONS="$SCRIPT_DIR/setup_icons.py"

# Update setup_icons.py with the new commit
sed -i "s/trees\/$CURRENT_COMMIT/trees\/$NEW_COMMIT/" "$SETUP_ICONS"

# Now calculate the new hash of the pokemon-icons derivation
# We use a dummy hash first to force nix to tell us the real one
OLD_HASH=$(grep -oP '(?<=outputHash = ")[^"]+' "$DEFAULT_NIX")
sed -i "s/outputHash = \".*\"/outputHash = \"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\"/" "$DEFAULT_NIX"

echo "Prefetching... (Nix will complain about hash mismatch, this is normal)"
# Capture the actual hash from the error message
# We use 'nix build' on the flake if it exists, otherwise use nix-build
if [ -f "flake.nix" ]; then
    NEW_HASH=$(nix build .#pokemon-icons 2>&1 | grep "got:" | awk '{print $2}')
else
    NEW_HASH=$(nix-build -A pokemon-icons 2>&1 | grep "got:" | awk '{print $2}')
fi

if [ -z "$NEW_HASH" ]; then
    # Some nix versions have different error formats
    if [ -f "flake.nix" ]; then
         NEW_HASH=$(nix build .#pokemon-icons 2>&1 | grep -oP 'sha256-[a-zA-Z0-9/+=]{44}')
    else
         NEW_HASH=$(nix-build -A pokemon-icons 2>&1 | grep -oP 'sha256-[a-zA-Z0-9/+=]{44}')
    fi
fi

if [ -z "$NEW_HASH" ]; then
    echo "Error: Could not calculate new hash. Reverting changes..."
    sed -i "s/trees\/$NEW_COMMIT/trees\/$CURRENT_COMMIT/" "$SETUP_ICONS"
    sed -i "s/outputHash = \".*\"/outputHash = \"$OLD_HASH\"/" "$DEFAULT_NIX"
    exit 1
fi

# Update default.nix with the real hash
sed -i "s/outputHash = \".*\"/outputHash = \"$NEW_HASH\"/" "$DEFAULT_NIX"

echo "Success! default.nix and setup_icons.py have been updated."
echo "New Hash: $NEW_HASH"
echo ""
echo "Now run your system update (e.g., sudo nixos-rebuild switch) to apply the changes."
