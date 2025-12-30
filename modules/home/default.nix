{ ... }:
{
  # Here we import home.nix with no extra modules
  imports = [
    (import ./home.nix)
  ];
}
