{ config, pkgs, ... }:
{
  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;
  };



  home.stateVersion = "24.05";
}
