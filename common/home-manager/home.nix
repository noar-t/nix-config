{ config, pkgs, ... }:
{
  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "fenv";
        src = pkgs.fishPlugins.foreign-env;
      }
    ];
    shellInit = "
      set -p fish_function_path ${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d\n
      fenv source ${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh > /dev/null
    ";
  };



  home.stateVersion = "24.05";
}
