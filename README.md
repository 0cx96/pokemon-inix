# pokemon-inix

> **Note:** This is a refactored version of [pokemon-icat](https://github.com/aflaag/pokemon-inix). 
> It has been optimized for NixOS and includes several stability and UI improvements.

## Key Improvements & Fixes

- **NixOS Native:** Refactored Flake and Module to work seamlessly with NixOS.
- **Improved Stability:** Fixed intermittent crashes when Pokémon icons were missing or failed to load.
- **Graceful Error Handling:** Added robust parsing for Pokémon data (like typing and ID) to prevent runtime panics.
- **Clean Terminal Exit:** Modified the TUI to exit cleanly inline, preventing terminal residues.
- **Optimized Nix Build:** Optimized the build process to prevent unnecessary recompilations of binary assets.
- **Automated Hash Management:** Implemented `update-icons.sh` to automatically track and update icon asset hashes, ensuring reproducible builds without manual intervention.

## Other Distributions

To install on other Linux distributions, please check the [original repository](https://github.com/aflaag/pokemon-icat).

## NixOS Installation

This repository exports a standard Flake with a NixOS module.

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

## Usage

```bash | fish | zsh
# Show a random Pokemon
pokemon-inix

# Check for icon updates
pokemon-inix -u
```

## Automated Icon Updates

To keep the Pokémon icons up to date while maintaining Nix reproducibility, you can use the built-in update flag:

```bash | fish | zsh
pokemon-inix -u
```

Alternatively, you can run the provided script directly:

```bash
./update-icons.sh
```

These methods require `nvchecker` and `nix` to be installed. They detect upstream changes and automatically update the hashes in `default.nix`.
