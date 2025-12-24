# pokemon-inix

> **Note:** This is a refactored version of [pokemon-icat](https://github.com/aflaag/pokemon-inix). 
> It has been optimized for NixOS and includes several stability and UI improvements.

## ❄️ NixOS Installation (Recommended)

This repository exports a standard Flake with a NixOS module. This is the cleanest way to install on NixOS.

**flake.nix:**
```nix
inputs.pokemon-inix.url = "github:0cx96/pokemon-inix";
# ...
modules = [
  inputs.pokemon-inix.nixosModules.default
];
```

**configuration.nix:**
```nix
programs.pokemon-inix.enable = true;
```

---

## 🚀 Quick Start (Arch / Debian / generic Linux)

For a simple installation on most distributions, use the unified installation script. It handles **automated system dependency detection** and installation for Arch and Debian based distributions.

### Install
```bash
git clone https://github.com/0cx96/pokemon-inix
cd pokemon-inix
chmod +x install.sh
./install.sh
```

### 📂 Where do the files go?
- **Binary:** `/usr/local/bin/pokemon-inix`
- **Data/Icons:** `~/.local/share/pokemon-inix/` (XDG standard)
- **Shell Config:** Automatically adds required vars to `.bashrc`, `.zshrc`, or `config.fish`.

---

## 🛠️ Usage

```bash
# Show a random Pokemon
pokemon-inix

# Check for icon updates (requires 'nix' on NixOS or manual setup elsewhere)
pokemon-inix -u
```

## ✨ Key Improvements & Fixes

- **Fully Renamed:** Migrated all internals from `pokemon-icat` to `pokemon-inix`.
- **NixOS Native:** Refactored Flake and Module to work seamlessly with NixOS.
- **Improved Stability:** Fixed intermittent crashes when Pokémon icons were missing or failed to load.
- **Graceful Error Handling:** Added robust parsing for Pokémon data to prevent runtime panics.
- **Automated Hash Management:** Implemented `update-icons.sh` to automatically track and update icon asset hashes.
