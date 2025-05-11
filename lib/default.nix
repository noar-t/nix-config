{ inputs }:
let
  defaultProfile = (import ../common/profile.nix);
  defaultHomeManagerConfig = import ../modules/home;
  moduleFiles = builtins.filter (file: file != "home.nix" && builtins.match ".*\\.nix$" file != null) (builtins.attrNames (builtins.readDir ../modules/home));
  homeModules = builtins.listToAttrs (builtins.map (file: {
    name = builtins.replaceStrings [".nix"] [""] file;
    value = import ../modules/home/${file};
  }) moduleFiles);
in
{

  mkNixOS =
    {
      hostName,
      profile ? defaultProfile,
      system ? "x86_64-linux",
      platform ? "linux",
    }:
    inputs.nixpkgs.lib.nixosSystem {
      system = system;
      specialArgs = {
        inherit inputs profile platform;
        moduleMode = "NixOS";
      };
      modules = [
        ../hosts/nixos/${hostName}/configuration.nix
        ../common
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = {
            inherit
              inputs
              profile
              system
              platform
              ;
          };
          home-manager.useUserPackages = true;
          home-manager.useGlobalPkgs = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.noah = defaultHomeManagerConfig;
        }
      ];
    };

  mkStandaloneHomeManager =
    {
      profile ? defaultProfile,
      homeDirectory,
      system ? "x86_64-linux",
      platform ? "linux",
      extraModules ? [ ],
      extraHomeModules ? [ ],
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = (import inputs.nixpkgs { inherit system; });
      extraSpecialArgs = {
        inherit
          inputs
          homeDirectory
          profile
          platform
          system
          ;
        moduleMode = "HomeManager";
      };
      modules = [
        #../common
        {
          home.username = profile.username;
          home.homeDirectory = homeDirectory;
        }
        (import ../modules/home/home.nix { inherit extraHomeModules; })
      ] ++ extraModules;
    };

  mkNixOnDroid =
    {
      profile ? defaultProfile,
      extraModules ? [ ],
    }:
    let
      system = "aarch64-linux";
      platform = "linux";
    in
    inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      extraSpecialArgs = {
        inherit inputs profile platform;
        moduleMode = "NixOS";
      };
      pkgs = import inputs.nixpkgs { inherit system; };
      modules = [
        #../common TODO fix this module to work for nix-on-droid
        ../hosts/nix-on-droid/default/nix-on-droid.nix
        {
          home-manager.useGlobalPkgs = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = {
            inherit inputs profile platform system;
          };
          home-manager.config = defaultHomeManagerConfig;
        }
      ] ++ extraModules;
    };

  inherit homeModules;
}
