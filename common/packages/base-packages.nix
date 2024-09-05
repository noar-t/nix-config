{ config, pkgs, lib, specialArgs, ... }:
let
  # moduleMode = "NixOS" OR "HomeManager"
  moduleMode = specialArgs.moduleMode;
  cfg = config.common.basePackages;
  basePackages = with pkgs; [
    bat
    comma
    cowsay
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
    enable = lib.mkOption {
      default = true;
      example = true;
      description = "Whether to enable my standard cli packages";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable (
    if (moduleMode == "NixOS") 
    # Used as NixOS module
    then { environment.systemPackages = basePackages; }
    # Used as Home-Manager module
    else { home.packages = basePackages; }
  );
}
