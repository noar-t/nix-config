{
  pkgs,
  ...
}:
{
  # some basic gui packages
  environment.systemPackages = with pkgs; [
    discord
    firefox
  ];
}
