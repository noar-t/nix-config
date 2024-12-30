{
  pkgs,
  inputs,
  system,
  ...
}:
{
  xdg.configFile."ghostty/config".source = ./dots/ghostty/config;

  home.packages = with pkgs; [
    nerd-fonts.hack
    inputs.ghostty.packages.${system}.default
  ];

  fonts.fontconfig.enable = true;
}
