#!/usr/bin/env bash

sudo -v

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

sudo rm -f /usr/local/bin/pokemon-inix
rm -rf "$HOME/.local/share/pokemon-inix"

echo "pokemon-inix was successfully uninstalled! :("
