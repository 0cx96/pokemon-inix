# Using pokemon-inix from GitHub (Refactored)

Now that the repository is refactored to export a proper NixOS module, you need to commit the right files.

## 1. Prepare Files

You should commit:
- `flake.nix` & `flake.lock` (Critical for reproducibility)
- `default.nix` & `pokemon_icat.nix`
- `bin/`, `src/`, `setup_icons.py` (Source code)
- `Cargo.toml`, `Cargo.lock`
- `.gitignore`, `readme.md`, `LICENSE`

**Do NOT commit:**
- `target/` directory (Rust build artifacts)
- `result` link
- `__pycache__`

I've updated your `.gitignore` to help with this.

## 2. Push your changes

Create a new repository on GitHub (e.g., `0cx96/pokemon-inix`), then:

```bash
git remote add origin git@github.com:yourusername/pokemon-inix.git
git branch -M main
git push -u origin main
```

## 2. Update your NixOS Configuration

Now you can use the standard module installation method.

### flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Point to your fork
    pokemon-inix.url = "github:yourusername/pokemon-inix";
  };

  outputs = { self, nixpkgs, pokemon-inix, ... }@inputs: {
    nixosConfigurations.myhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        
        # Import the module exported by the flake
        pokemon-inix.nixosModules.default
      ];
    };
  };
}
```

### configuration.nix

Now enabling it is as simple as setting the option:

```nix
{ config, pkgs, ... }:

{
  # This option is now available because of the module import
  programs.pokemon-inix.enable = true;
}
```

## Verification

After rebuilding (`sudo nixos-rebuild switch ...`), you can verify correct installation:

```bash
pokemon-inix --help
```
