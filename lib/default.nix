{ inputs }:
let
  defaultHomeManagerConfig = import ../modules/home;
in
{

  mkNixOS =
    {
      profile,
      system ? "x86_64-linux",
      extraModules ? [ ],
    }:
    inputs.nixpkgs.lib.nixosSystem {
      system = system;
      specialArgs = {
        inherit inputs profile;
        moduleMode = "NixOS";
      };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = {
            inherit inputs profile system;
          };
          home-manager.useUserPackages = true;
          home-manager.useGlobalPkgs = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.noah = defaultHomeManagerConfig;
        }
        ../common
      ] ++ extraModules;
    };

  mkStandaloneHomeManager =
    {
      profile,
      homeDirectory,
      username,
      system ? "x86_64-linux",
      extraModules ? [ ],
      extraHomeModules ? [ ],
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = (import inputs.nixpkgs { inherit system; });
      extraSpecialArgs = {
        inherit
          inputs
          homeDirectory
          username
          profile
          ;
        moduleMode = "HomeManager";
      };
      modules = [
        ../common
        {
          home.username = username;
          home.homeDirectory = homeDirectory;
        }
        ../modules/home/home.nix
        { inherit extraHomeModules profile; }
      ] ++ extraModules;
    };

  mkDarwin =
    {
      profile,
      homeDirectory,
      username,
      system ? "aarch64-darwin",
      extraModules ? [ ],
      extraHomeModules ? [ ],
    }:
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          homeDirectory
          username
          profile
          system
          ;
        moduleMode = "NixOS";
      };
      modules = [
        ../common
        ../hosts/nix-darwin/configuration.nix
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.extraSpecialArgs = {
            inherit inputs profile system;
          };
          home-manager.useUserPackages = true;
          home-manager.useGlobalPkgs = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.${username} = import ../modules/home/home.nix {
            inherit extraHomeModules;
          };
        }
      ] ++ extraModules;
    };

  mkNixOnDroid =
    {
      profile,
      extraModules ? [ ],
    }:
    inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      extraSpecialArgs = {
        inherit inputs profile;
        moduleMode = "NixOS";
      };
      pkgs = import inputs.nixpkgs { system = "aarch64-linux"; };
      modules = [
        #../common TODO fix this module to work for nix-on-droid
        ../hosts/nix-on-droid/default/nix-on-droid.nix
        {
          home-manager.useGlobalPkgs = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = {
            inherit inputs profile;
            system = "aarch64-linux";
          };
          home-manager.config = defaultHomeManagerConfig;
        }
      ] ++ extraModules;
    };
}
