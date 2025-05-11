{
  pkgs,
  config,
  ...
}:
{
  xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/modules/home/dots/ghostty/config";
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.hack
    pkgs.ghostty
  ];
}
