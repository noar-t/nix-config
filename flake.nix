{
  description = "flake for nix-on-droid and nix-os devices/hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-on-droid,
      home-manager,
      hyprland,
      nixvim,
      nixos-wsl,
      nix-hardware,
    }:
    let
      libx = (import ./lib { inherit inputs; });
      homeModules = libx.homeModules;
    in
    {
      nixosConfigurations = builtins.listToAttrs (
        map (hostName: {
          name = hostName;
          value = libx.mkNixOS {
            extraModules = [
              ./hosts/nixos/${hostName}/configuration.nix
            ];
          };
        })
        [ "wsl" "rinsler" "raiden" "thinkpad" ]
      );

      homeConfigurations.default = libx.mkStandaloneHomeManager {
        homeDirectory = "/home/noah";
        username = "noah";
      };

      # Galaxy Tab S8+
      nixOnDroidConfigurations.default = libx.mkNixOnDroid {};

      # Export functions to enable importing flake to work computers
      lib = libx;

      inherit homeModules;

      # Code formatter for flake, use command "nix fmt" to format entire repo
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
