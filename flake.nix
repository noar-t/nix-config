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

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-hardware.url = "github:NixOS/nixos-hardware/master";

    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-on-droid,
      home-manager,
      hyprland,
      nix-darwin,
      nixvim,
      nixos-wsl,
      nix-hardware,
      ghostty,
    }:
    let
      profiles = (import ./common/profiles.nix);
      libx = (import ./lib { inherit inputs; });
    in
    {
      nixosConfigurations = {
        # WSL
        wsl = libx.mkNixOS {
          profile = profiles.personal;
          extraModules = [
            nixos-wsl.nixosModules.default
            ./hosts/nixos/wsl/configuration.nix
          ];
        };

        # Home server
        rinsler = libx.mkNixOS {
          profile = profiles.personal;
          extraModules = [
            ./hosts/nixos/rinsler/configuration.nix
            ./common/nix-cleanup.nix
          ];
        };

        # Gaming desktop
        raiden = libx.mkNixOS {
          profile = profiles.personal;
          extraModules = [
            ./hosts/nixos/raiden/configuration.nix
            ./common/nix-cleanup.nix
            nix-hardware.nixosModules.gigabyte-b550
          ];
        };

	# Old thinkpad
        thinkpad = libx.mkNixOS {
          profile = profiles.personal;
          extraModules = [
            ./hosts/nixos/thinkpad/configuration.nix
            nix-hardware.nixosModules.gigabyte-b550
          ];
        };
      };

      homeConfigurations.default = libx.mkStandaloneHomeManager {
        homeDirectory = "/home/noah";
        username = "noah";
      };

      # Work MacBook
      darwinConfigurations.default = libx.mkDarwin {
        homeDirectory = "/Users/noah";
        username = "noah";
      };

      # Galaxy Tab S8+
      nixOnDroidConfigurations.default = libx.mkNixOnDroid { profile = profiles.personal; };

      # Export functions to enable importing flake to work computers
      lib = libx;

      # Code formatter for flake, use command "nix fmt" to format entire repo
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
