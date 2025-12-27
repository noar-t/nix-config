{ inputs, ... }:
let
  defaultProfile = (import ../common/profile.nix);
  defaultHomeManagerConfig = import ../modules/home;
  system = "aarch64-linux";
in
{
  flake = {
    # Galaxy Tab S8+
    nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      extraSpecialArgs = {
        inherit inputs;
        profile = defaultProfile;
      };
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      modules = [
        ../hosts/nix-on-droid/default/nix-on-droid.nix
        {
          home-manager = {
            useGlobalPkgs = true;
            backupFileExtension = "bak";
            extraSpecialArgs = {
              inherit inputs;
              profile = defaultProfile;
              moduleMode = "NixOS";
            };
            config = defaultHomeManagerConfig;
          };
        }
      ];
    };
  };
}
