{ config, lib, pkgs, ... }:

let
  cfg = config.programs.pokemon-inix;
in
{
  options.programs.pokemon-inix = {
    enable = lib.mkEnableOption "pokemon-inix";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.pokemon-inix ];
  };
}
