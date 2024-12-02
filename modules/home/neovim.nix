{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    colorschemes.gruvbox.enable = true;

    # Some binaries are necessary for plugins
    extraPackages = with pkgs; [
      jdt-language-server
    ];

    plugins = {
      # Better error alerts
      notify.enable = true;

      # Snippets
      luasnip.enable = true;
      friendly-snippets.enable = true;

      # Auto trim trailing spaces
      trim.enable = true;

      # Quick file navigator and required icons
      telescope.enable = true;
      web-devicons.enable = true;

      # Quick file switcher
      harpoon.enable = true;

      # Highlight current word within buffer
      cursorline.enable = true;

      # Airline style status bar
      lualine.enable = true;

      # Git wrapper
      fugitive.enable = true;

      # Toggle-able terminal
      toggleterm.enable = true;

      # File browser
      oil.enable = true;

      # Show status loading in bottom right
      fidget.enable = true;

      # Syntactic aware editing and highlighting
      treesitter.enable = true;

      # Autodetect indent
      sleuth.enable = true;

      # Easily comment out code
      comment.enable = true;

      # Smart motion inline
      precognition.enable = true;

      # Enable git status in the gutter
      gitsigns.enable = true;

      # Enable todo comment highlighting
      todo-comments.enable = true;

      # Autoclose brackets and parenthesis
      autoclose.enable = true;

      # A popup that shows possible keybinds for commands typed
      which-key = {
        enable = true;
        settings = {
          operators = {
            gc = "Comments";
          };
          triggers_black_list = {
            i = [
              "j"
              "k"
            ];
            v = [
              "j"
              "k"
            ];
          };
          triggers_no_wait = [
            "`"
            "'"
            "g`"
            "g'"
            "\""
            "<C-r>"
            "z="
          ];
          plugins.presets = {
            g = true;
            motions = true;
            nav = true;
            operators = true;
            text_objects = true;
            windows = true; # <C-w>
            z = true; # folds
          };
        };
      };

      # Auto-complete engine
      cmp = {
        enable = true;
        settings = {
          completion.autocomplete = [ "TextChanged" ];
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
            { name = "nvim_lsp_signature_help"; }
            { name = "emoji"; }
          ];
          mapping = {
            # Use default C-n/C-d with cmp
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
            # Scroll
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            # Use C-space to trigger completion menu
            "<C-Space>" = "cmp.mapping.complete()";
            # Use C-y to accept completion
            "<C-y>" = "cmp.mapping.confirm({ select = true })";
          };
        };
      };
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp-emoji.enable = true;

      ## Language server tooling
      #lsp-format.enable = true;
      lsp-lines.enable = true;
      lspkind.enable = true;
      lsp = {
        enable = true;
        servers = {
          elmls.enable = true;
          jdtls.enable = true;
          lua_ls.enable = true;
          kotlin_language_server.enable = true;
          nixd = {
            enable = true;
            settings = {
              nixpkgs = {

                expr = "import <nixpkgs> { }";
              };
              formatting = {
                command = [ "nixfmt" ];
              };
              options = {
                nixos = {
                  # TODO fix hostname to be dynamic, for now will just pin to WSL
                  expr = "(builtins.getFlake \"github:noar-t/nix-config\").nixosConfigurations.wsl.options";
                };
                home_manager = {
                  expr = "(builtins.getFlake \"github:noar-t/nix-config\").homeConfigurations.default.options";
                };
                darwin = {
                  expr = "(builtins.getFlake \"github:noar-t/nix-config\").darwinConfigurations.default.options";
                };
              };
            };
          };
          pyright.enable = true;
        };

        keymaps = {
          lspBuf = {
            gd = {
              action = "definition";
              desc = "Goto Defintion";
            };
          };
        };
      };
      transparent.enable = true;
      # Later if needed
    };

    keymaps = [
      {
        # Ctrl + d moves down and centers
        action = "<C-d>zz";
        key = "<C-d>";
        mode = "n";
      }
      {
        # Ctrl + u moves up and centers
        action = "<C-u>zz";
        key = "<C-u>";
        mode = "n";
      }
    ];

    opts = {
      # Show line numbers by default
      number = true;

      # Show relative line numbers
      relativenumber = true;

      # Enable mouse mode
      mouse = "a";

      # TODO remove when adding status line
      showmode = true;

      # Always split right/down
      splitright = true;
      splitbelow = true;

      # -- Search
      # Ignore case until capital is included
      ignorecase = true;
      smartcase = true;

      # Highlight on search, clear on <Esc>
      hlsearch = true;

      # Incrementally highlight while searching
      incsearch = true;
      # -- Search

      # Decrease update time
      updatetime = 250;

      # Show line cursor is on
      cursorline = true;

      # Minimal lines +/- of the cursor
      scrolloff = 10;

      # Preview substitutions live as you type
      inccommand = "split";

      # When text wraps, indent to show wrapping
      breakindent = true;

      # Momentarily jump to the matching bracket/parenthesis
      showmatch = true;

      # Always show column for git gutter
      signcolumn = "yes";

      # Show visual queue instead of beeping terminal bell
      visualbell = true;

      # Note may be able to disable this with plugins
      tabstop = 8;
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;

      # Enable syntax highlighting
      syntax = "on";

      # Enable spell checking
      spell = true;

      list = true;
      listchars = {
        space = "·";
        eol = "⏎";
        tab = "␉·";
        trail = "·";
        nbsp = "⎵";
      };

      # Time to wait for mapped sequence to complete, effects wait time for which-key
      timeout = true;
      timeoutlen = 300;

      # INVESTIGATION SECTION
      # undofile = true?

      # Exit terminal shortcut?
      # PLUGINS:
      # nvim-navbuddy
      # telescope.nvim
      # toggleterm.nvim
      # lspkind.nvim
      # rainbow-delimiters?
      # configure vim.diagnostics.config
      # configure
      # lsp highlighting bindings from kickstart
    };
  };
}
