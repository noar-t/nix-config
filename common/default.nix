{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./packages/base-packages.nix
    ./packages/gui-packages.nix
  ];
}
