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
      profiles = import ./common/profiles.nix;
    in {
      nixosConfigurations = let
        linuxSystem = "x86_64-linux";
        mkNixOS = { arch, profile, extraModules }:
          nixpkgs.lib.nixosSystem {
            system = arch;
            specialArgs = { inherit inputs profile; };
            modules = [
              home-manager.nixosModules.home-manager
              {
                home-manager.extraSpecialArgs = { inherit inputs profile; };
                home-manager.useUserPackages = true;
                home-manager.useGlobalPkgs = true;
                home-manager.backupFileExtension = "bak";
                home-manager.users.noah = import ./common/home-manager/home.nix;
              }
            ] ++ extraModules;
          };
      in {
        # WSL
        wsl = mkNixOS { 
          arch = linuxSystem;
          profile = profiles.personal;
          extraModules = [ 
            nixos-wsl.nixosModules.default
            ./hosts/nixos/wsl/configuration.nix 
          ];
        };

        # Home server
        rinsler = mkNixOS {
          arch = linuxSystem;
          profile = profiles.personal;
          extraModules = [
            ./hosts/nixos/rinsler/configuration.nix
            ./common/nix-cleanup.nix # TODO move to nixOS common module
          ];
        };

        # Gaming desktop
        raiden = mkNixOS {
          arch = linuxSystem;
          profile = profiles.personal;
          extraModules = [
            ./hosts/nixos/raiden/configuration.nix
            ./common/nix-cleanup.nix
            nix-hardware.nixosModules.gigabyte-b550
          ];
        };
      };

      homeConfigurations = let
        username = "placeholder";
        homeDirectory = "placeholder";
        profile = profiles.work;
      in {
        clouddesktop = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          extraSpecialArgs = { inherit inputs profile; };
          modules = [
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
            ./common/home-manager/home.nix
          ];
        };
      };

      # Work MacBook
      darwinConfigurations = let
        profile = profiles.work;
      in {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs profile; };
        kodoma = nix-darwin.lib.darwinSystem {
          modules = [
            ./hosts/nix-darwin/configuration.nix
          ];
        };
      };

      # Galaxy Tab S8+
      nixOnDroidConfigurations.default = let
        profile = profiles.personal ;
      in nix-on-droid.lib.nixOnDroidConfiguration {
        extraSpecialArgs = { inherit inputs profile; };
        modules = [
          ./hosts/nix-on-droid/default/nix-on-droid.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = { inherit inputs profile; };
            home-manager.config = ./common/home-manager/home.nix;
          }
        ];
      };
  };
}
