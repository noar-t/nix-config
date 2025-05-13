{
  pkgs,
  ...
}:
{
  fonts.fontconfig.enable = true;
  home.packages = [ pkgs.nerd-fonts.hack ];

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      window = {
        decorations = "full";
        opacity = 0.9;
        dynamic_title = true;
        decorations_theme_variant = "Dark";
      };

      font = {
        size = 14.0;
        normal = {
          family = "Hack Nerd Font";
          style = "Regular";
        };
      };

      colors = {
        primary = {
          background = "#282828";
          foreground = "#ebdbb2";
        };

        normal = {
          black = "#282828";
          red = "#cc241d";
          green = "#98971a";
          yellow = "#d79921";
          blue = "#458588";
          magenta = "#b16286";
          cyan = "#689d6a";
          white = "#a89984";
        };

        bright = {
          black = "#928374";
          red = "#fb4934";
          green = "#b8bb26";
          yellow = "#fabd2f";
          blue = "#83a598";
          magenta = "#d3869b";
          cyan = "#8ec97c";
          white = "#ebdbb2";
        };
      };

      bell.duration = 0;

      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };

        blink_interval = 750;
        blink_timeout = 5;
      };
    };
  };
}
