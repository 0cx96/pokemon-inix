# pokemon-inix

> **Note:** This is a refactored version of [pokemon-inix](https://github.com/aflaag/pokemon-inix). 
> It has been optimized for NixOS and includes several stability and UI improvements.

## Key Improvements & Fixes

- **NixOS Native:** Refactored Flake and Module to work seamlessly with NixOS.
- **Improved Stability:** Fixed intermittent crashes when Pokémon icons were missing or failed to load.
- **Graceful Error Handling:** Added robust parsing for Pokémon data (like typing and ID) to prevent runtime panics.
- **Clean Terminal Exit:** Modified the TUI to exit cleanly inline, preventing terminal residues.
- **Optimized Nix Build:** Optimized the build process to prevent unnecessary recompilations of binary assets.

## Other Distributions

To install on other Linux distributions, please check the [original repository](https://github.com/aflaag/pokemon-inix).

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

```bash
pokemon-inix
```
