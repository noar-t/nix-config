{ inputs }:
let
  defaultHomeManagerConfig = import ../modules/home;
in
{

  mkNixOS =
    {
      profile,
      arch ? "x86_64-linux",
      extraModules ? [ ],
    }:
    inputs.nixpkgs.lib.nixosSystem {
      system = arch;
      specialArgs = {
        inherit inputs profile;
        moduleMode = "NixOS";
      };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = {
            inherit inputs profile;
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
      homeDirectory,
      username,
      arch ? "x86_64-linux",
      extraModules ? [ ],
      extraHomeModules ? [ ],
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = (import inputs.nixpkgs { system = arch; });
      extraSpecialArgs = {
        inherit inputs homeDirectory username;
        moduleMode = "HomeManager";
      };
      modules = [
        ../common
        {
          home.username = username;
          home.homeDirectory = homeDirectory;
        }
        ../modules/home/home.nix
        { inherit extraHomeModules; }
      ] ++ extraModules;
    };

  mkDarwin =
    {
      homeDirectory,
      username,
      arch ? "aarch64-darwin",
      extraModules ? [ ],
      extraHomeModules ? [ ],
    }:
    inputs.nix-darwin.lib.darwinSystem {
      system = arch;
      specialArgs = {
        inherit inputs homeDirectory username;
        moduleMode = "NixOS";
      };
      modules = [
        ../common
        ../hosts/nix-darwin/configuration.nix
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.extraSpecialArgs = {
            inherit inputs;
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
          };
          home-manager.config = defaultHomeManagerConfig;
        }
      ] ++ extraModules;
    };
}
