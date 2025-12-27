{ inputs, ... }:
{
  flake =
    let
      defaultProfile = (import ../common/profile.nix);
      defaultHomeManagerConfig = import ../modules/home;

      mkStandaloneHomeManager =
        {
          profile ? defaultProfile,
          homeDirectory,
          system ? "x86_64-linux",
          extraHomeModules ? [ ],
          extraExtraSpecialArgs ? { },
        }:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit
              inputs
              homeDirectory
              profile
              ;
            moduleMode = "HomeManager";
          }
          // extraExtraSpecialArgs;
          modules = [
            ../common
            {
              home.username = profile.username;
              home.homeDirectory = homeDirectory;
            }
            (import ../modules/home/home.nix { inherit extraHomeModules; })
          ];
        };
    in
    {
      # Standalone Home Manager configuration
      homeConfigurations.default = mkStandaloneHomeManager {
        homeDirectory = "/home/noah";
      };

      # Export individual Home Manager modules for reuse
      homeModules = {
        alacritty = ../modules/home/alacritty.nix;
        bat = ../modules/home/bat.nix;
        eza = ../modules/home/eza.nix;
        fish = ../modules/home/fish.nix;
        fzf = ../modules/home/fzf.nix;
        ghostty = ../modules/home/ghostty.nix;
        git = ../modules/home/git.nix;
        htop = ../modules/home/htop.nix;
        hyprland = ../modules/home/hyprland.nix;
        neovim = ../modules/home/neovim.nix;
        ssh = ../modules/home/ssh.nix;
        tealdeer = ../modules/home/tealdeer.nix;
        tmux = ../modules/home/tmux.nix;
        default = ../modules/home/home.nix;
      };

      # Export standalone home-manager builder for external flakes
      lib.mkStandaloneHomeManager = mkStandaloneHomeManager;
    };
}
