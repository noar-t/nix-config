#{ config, pkgs, lib, mode ? "NixOS", ... }:
{ config, pkgs, lib, specialArgs, ... }:
# TODO cant change argument to a module so need to make
# these an option or curry, I kinda like curry here
# since there might be multiple modules that need
# this pattern
let
  specialArgsMode = if (builtins.hasAttr "mode" specialArgs)
    then specialArgs.mode
    else "NixOS";
  cfg = config.common.basePackages;
  basePackages = with pkgs; [
    bat
    comma
    duf
    erdtree
    eza
    fish
    gcc
    git
    gotop
    htop
    lm_sensors
    memtester
    neofetch
    neovim
    nix-index
    stress
    silver-searcher
    tmux
    watch
    wget
  ];
in {
  options.common.basePackages = {
    enable = lib.mkEnableOption "basePackages";

    # mode = lib.mkOption {
    #   type = lib.types.enum [ "NixOS" "Home-Manager" ];
    #   default = specialArgsMode;
    #   description = "The mode in which this module should operate in.";
    # };
  };

  config = lib.mkIf cfg.enable (
    if (specialArgsMode == "NixOS") 
    # Used as NixOS module
    then { environment.systemPackages = basePackages; }
    # Used as Home-Manager module
    else { home.packages = basePackages; }
  );
}
