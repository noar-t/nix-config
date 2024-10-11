{ config, pkgs, lib, specialArgs, ... }:
let
  # moduleMode = "NixOS" OR "HomeManager"
  moduleMode = specialArgs.moduleMode;
  cfg = config.common.guiPackages;
  guiPackages = with pkgs; [
    discord
    firefox
  ];
in {
  options.common.guiPackages = {
    enable = lib.mkOption {
      default = false;
      example = true;
      description = "Whether to enable my standard gui packages";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable (
    if (moduleMode == "NixOS") 
    # Used as NixOS module
    then { environment.systemPackages = guiPackages; }
    # Used as Home-Manager module
    else { home.packages = guiPackages; }
  );
}
