{ config, pkgs, specialArgs, inputs, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    colorschemes.gruvbox.enable = true;

    extraPlugins = with pkgs.vimPlugins; [
      plenary-nvim  # hardtime dependency
      nui-nvim      # hardtime dependency
    ];
    plugins = {
      # Syntactic aware editing and highlighting
      treesitter.enable = true;

      # Give advice abuot vim movement
      hardtime.enable = true;

      # Autodetect indent
      sleuth.enable = true;

      # Easily comment out code
      comment.enable = true;

      # Enable git status in the gutter
      gitsigns.enable = true;

      # Enable todo comment highlighting
      todo-comments.enable = true;

      # Autoclose brackets and parenthesis
      autoclose.enable = true;

      # A popup that shows possible keybinds for commands typed
      which-key.enable = true;

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

      # Language server tooling
      lsp-format.enable = true;
      lsp-lines.enable = true;
      lsp = {
        enable = true;
        servers = {
          elmls.enable = true;
          java-language-server.enable = true;
          kotlin-language-server.enable = true;
          nil-ls.enable = true;
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
      # Later if needed
      # fzf-lua
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

      # TODO have_nerd_font?

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

      # decrease mapped sequence wait time
      # show which-key faster?
      # Exit terminal shortcut?
      # PLUGINS:
      #   which-key -> describe shortcuts
      #   nvim-lspconfig -> configure lsps
      #     mason.nvim
      #     mason-lspconfig.nvim
      #     mason-tool-installer.nvim
      #   conform.nvim -> autoformat
      #   nvim-cmp -> autocomplete
      #   todo-comments.nvim -> highlight todo
      #   nvim-treesitter -> code highlighting
    };
  };
}
