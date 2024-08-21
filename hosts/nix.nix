{ pkgs, ... }@args:
{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '' + args.extraExtraOptions or "";
  };
}
