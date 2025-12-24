# pokemon-inix

> **Note:** This is a fork of [pokemon-inix](https://github.com/aflaag/pokemon-inix). I used AI to refactor the Flake and Module to make it work out-of-the-box with NixOS.

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
