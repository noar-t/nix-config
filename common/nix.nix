{
  inputs,
  moduleMode,
  pkgs,
  ...
}:
let
  hmGcOption = {
    frequency = "weekly";
  };

  nixOsGcOption = {
    dates = "weekly";
  };
in
{
  nix = {
    # package = pkgs.nix;

    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    # Perform garbage collection weekly to save disk space
    settings = {
      # You can also manually run nix-store --optimize
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      #substituters = [
      #  # Hyprland
      #  "https://hyprland.cachix.org"
      #];

      #trusted-public-keys = [
      #  # Hyprland
      #  "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      #];
    }
    // (if moduleMode == "NixOS" then { auto-optimise-store = true; } else { });

    gc = {
      automatic = true;
      options = "--delete-older-than 1w";
    }
    // (if moduleMode == "NixOS" then nixOsGcOption else hmGcOption);
  }
  // (if moduleMode == "NixOS" then { optimise.automatic = true; } else { });
}
