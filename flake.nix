{
  description = "flake for nix-on-droid and nix-os devices/hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = inputs@{ self, nixpkgs, nix-on-droid, home-manager, nix-darwin, nixvim, nixos-wsl, nix-hardware }: 
    let 
      profiles = (import ./common/profiles.nix);
      libx = (import ./lib { inherit inputs; });
    in {
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
      };

      homeConfigurations = {
        clouddesktop = libx.mkStandaloneHomeManager { profile = profiles.work; };
      };

      # Work MacBook
      darwinConfigurations = {
        kodoma = libx.mkDarwin {
          profile = profiles.work;
        };
      };

      # Galaxy Tab S8+
      nixOnDroidConfigurations.default = libx.mkNixOnDroid {
        profile = profiles.personal;
      };

      functions = libx;
  };
}
