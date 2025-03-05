{
  pkgs,
  inputs,
  platform,
  system,
  config,
  ...
}:
{
  xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/modules/home/dots/ghostty/config";
  fonts.fontconfig.enable = true;

  # TODO probably a cleaner way to do this, but check if we are on linux and install ghostty from source if so
  # on darwin/mac ghostty will be handled via homebrew
  home.packages =
    with pkgs;
    [
      nerd-fonts.hack
    ]
    ++ (
      if platform == "linux" then
        [
          inputs.ghostty.packages.${system}.default

        ]
      else
        [ ]
    );

}
