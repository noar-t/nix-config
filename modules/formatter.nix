{ ... }:
{
  # Code formatter for flake, use command "nix fmt" to format entire repo
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-rfc-style;
    };
}
