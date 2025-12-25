{
  description = "pokemon-inix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        packages = pkgs.callPackage ./default.nix {};
      in {
        packages.default = packages.pokemon-inix;
        packages.pokemon-inix = packages.pokemon-inix;
        packages.pokemon-icons = packages.pokemon-icons;
      }
    ) // {
      overlays.default = final: prev: {
        pokemon-inix = (final.callPackage ./default.nix {}).pokemon-inix;
      };

      nixosModules.default = { config, lib, pkgs, ... }: {
        imports = [ ./pokemon_inix.nix ];
        nixpkgs.overlays = [ self.overlays.default ];
      };
    };
}
