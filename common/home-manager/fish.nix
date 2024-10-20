{
  config,
  pkgs,
  specialArgs,
  inputs,
  ...
}:
{
  # user-friendly shell
  programs.fish = {
    enable = true;
    plugins = with pkgs.fishPlugins; [
      {
        # Import bash env
        name = "fenv";
        src = foreign-env.src;
      }
      {
        # Color theme
        name = "fish-gruvbox";
        src = gruvbox.src;
      }
      {
        # Auto close (),"",''
        name = "autopair";
        src = autopair.src;
      }
      {
        # Colorize man pages
        name = "colored-man";
        src = colored-man-pages.src;
      }
      {
        # Text expansions
        name = "puffer";
        src = puffer.src;
      }
      #{ TODO only in unstable
      #  # Remove failed commands from history
      #  name = "sponge";
      #  src = sponge.src;
      #}
    ];

    shellAliases = {
      "cat" = "bat";
      "tree" = "eza -T";
      "df" = "duf";
    };

    interactiveShellInit = ''
      # Disable fish greetings
      set fish_greeting

      # Use vim keys
      fish_vi_key_bindings

      # Set prompt path to show more info
      set -g fish_prompt_pwd_dir_length 3
      set -g fish_prompt_pwd_full_dirs 3

      # Source homebrew
      if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
      end
    '';

    # use fenv to source nix path correctly
    shellInit = "
      set -p fish_function_path ${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d\n
      fenv source ${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh > /dev/null\n
    ";
  };
}
