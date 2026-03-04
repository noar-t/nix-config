{
  config,
  pkgs,
  ...
}:
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.hack
  ];

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installBatSyntax = true;
    installVimSyntax = true;
    settings = {
      font-family = "Hack Nerd Font";
      theme = "\"Gruvbox Dark Hard\"";
      command = "${config.programs.fish.package}/bin/fish";
      cursor-style = "underline";
      cursor-style-blink = true;
      background-opacity = 0.95;
    };
  };
}
