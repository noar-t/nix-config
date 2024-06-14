{ config, pkgs, ... }:
{
  programs.home-manager.enable = true;

  # Improved cat
  programs.bat.enable = true;

  # Improved ls
  programs.eza = {
    enable = true;
    enableFishIntegration = true;

    # list git status if tracked
    git = true;

    # show icons next to items
    icons = true;
  };

  # User-friendly shell
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

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    # TODO tmux integration?
  };

  # TODO stuff to add later/explore
  # borgmatic
  # broot
  # chromium/firefox w/ extensions
  # fd
  #
  # MacOS
  # aerospace config
  # sketchybar config
  # janky borders config
  


  home.stateVersion = "24.05";
}
