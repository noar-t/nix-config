{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.myHome.hyprland.enable = lib.mkEnableOption {
    name = "personal hyprland config";
  };

  config = lib.mkIf config.myHome.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
    };

    home.packages = with pkgs; [
      hyprlock
      wl-clipboard
    ];

    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
  };
}
