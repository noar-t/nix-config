{ pkgs, inputs, ... }:
let
  enable_nerd_fonts = true;
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    globals = {
      have_nerd_font = true;
    };

    colorschemes.gruvbox.enable = true;

    autoGroups = {
      kickstart-highlight-yank = {
        clear = true;
      };
    };

    # [[ Basic Autocommands ]]
    #  See `:help lua-guide-autocommands`
    # https://nix-community.github.io/nixvim/NeovimOptions/autoCmd/index.html
    autoCmd = [
      # Highlight when yanking (copying) text
      #  Try it with `yap` in normal mode
      #  See `:help vim.hl.on_yank()`
      {
        event = [ "TextYankPost" ];
        desc = "Highlight when yanking (copying) text";
        group = "kickstart-highlight-yank";
        callback.__raw = ''
          function()
            vim.hl.on_yank()
          end
        '';
      }
    ];

    diagnostic = {
      settings = {
        severity_sort = true;
        float = {
          border = "rounded";
          source = "if_many";
        };
        underline = {
          severity.__raw = ''vim.diagnostic.severity.ERROR'';
        };
        signs.__raw = ''
          vim.g.have_nerd_font and {
            text = {
              [vim.diagnostic.severity.ERROR] = '󰅚 ',
              [vim.diagnostic.severity.WARN] = '󰀪 ',
              [vim.diagnostic.severity.INFO] = '󰋽 ',
              [vim.diagnostic.severity.HINT] = '󰌶 ',
            },
          } or {}
        '';
        virtual_text = {
          source = "if_many";
          spacing = 2;
          format.__raw = ''
            function(diagnostic)
              local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
              }
              return diagnostic_message[diagnostic.severity]
            end
          '';
        };
      };
    };

    plugins = {
      # Better error alerts
      notify.enable = true;

      # Use relative numbers only when focussed
      numbertoggle.enable = true;

      # Snippets
      luasnip.enable = true;
      friendly-snippets.enable = true;

      # Lua development support
      lazydev = {
        enable = true;
        settings = {
          library = [
            {
              path = "\${3rd}/luv/library";
              words = [ "vim%.uv" ];
            }
          ];
        };
      };

      # Auto trim trailing spaces
      trim.enable = true;

      # Quick file navigator and required icons
      telescope.enable = true;
      # Adds icons for plugins to utilize in ui
      web-devicons.enable = enable_nerd_fonts;
      mini.enable = true;

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
      oil = {
        enable = true;
        settings = {
          view_options = {
            show_hidden = true;
          };

          # Add Git status to Oil
          win_options = {
            signcolumn = "yes:2";
          };
        };

      };

      # Add Git status to Oil
      oil-git-status.enable = true;

      # Build better habits
      hardtime.enable = true;

      # Embed neovim into the browser
      firenvim.enable = true;

      # Show status loading in bottom right
      fidget.enable = true;

      # Syntactic aware editing and highlighting
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
        grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
      };

      # Autodetect indent
      sleuth.enable = true;

      # Easily comment out code
      comment.enable = true;

      # Smart motion inline
      precognition.enable = true;

      # Adds git related signs to the gutter, as well as utilities for managing changes
      # See `:help gitsigns` to understand what the configuration keys do
      # https://nix-community.github.io/nixvim/plugins/gitsigns/index.html
      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = "+";
            change.text = "~";
            changedelete.text = "~";
            delete.text = "_";
            topdelete.text = "‾";
            untracked.text = "┆";
          };
        };
      };

      # Enable todo comment highlighting
      todo-comments.enable = true;

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
          notify = false;
        };
      };

      # Autocompletion
      # See `:help cmp`
      # https://nix-community.github.io/nixvim/plugins/blink-cmp/index.html
      blink-cmp = {
        enable = true;

        settings = {

          keymap = {
            # 'default' (recommended) for mappings similar to built-in completions
            #   <c-y> to accept ([y]es) the completion.
            #    This will auto-import if your LSP supports it.
            #    This will expand snippets if the LSP sent a snippet.
            # 'super-tab' for tab to accept
            # 'enter' for enter to accept
            # 'none' for no mappings
            #
            # For an understanding of why the 'default' preset is recommended,
            # you will need to read `:help ins-completion`
            #
            # No, but seriously. Please read `:help ins-completion`, it is really good!
            #
            # All presets have the following mappings:
            # <tab>/<s-tab>: move to right/left of your snippet expansion
            # <c-space>: Open menu or open docs if already open
            # <c-n>/<c-p> or <up>/<down>: Select next/previous item
            # <c-e>: Hide menu
            # <c-k>: Toggle signature help
            #
            # See :h blink-cmp-config-keymap for defining your own keymap
            preset = "default";

            # For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
            #    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
          };

          appearance = {
            # 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            # Adjusts spacing to ensure icons are aligned
            nerd_font_variant = "mono";
          };

          completion = {
            # By default, you may press `<c-space>` to show the documentation.
            # Optionally, set `auto_show = true` to show the documentation after a delay.
            documentation = {
              auto_show = false;
              auto_show_delay_ms = 500;
            };
          };

          sources = {
            default = [
              "lsp"
              "path"
              "snippets"
              "lazydev"
            ];
            providers = {
              lazydev = {
                module = "lazydev.integrations.blink";
                score_offset = 100;
              };
            };
          };

          snippets = {
            preset = "luasnip";
          };

          # Blink.cmp includes an optional, recommended rust fuzzy matcher,
          # which automatically downloads a prebuilt binary when enabled.
          #
          # By default, we use the Lua implementation instead, but you may enable
          # the rust implementation via `'prefer_rust_with_warning'`
          #
          # See :h blink-cmp-config-fuzzy for more information
          fuzzy = {
            implementation = "lua";
          };

          # Shows a signature help window while you type arguments for a function
          signature = {
            enabled = true;
          };
        };
      };

      ## Language server tooling
      lsp-lines.enable = true;
      lsp = {
        enable = true;

        # Enable inlay hints globally
        inlayHints = true;

        # Enable inlay hints when LSP attaches to buffer
        onAttach = ''
          if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        '';

        servers = {
          fish_lsp.enable = true;
          jdtls.enable = true;
          kotlin_language_server.enable = true;
          lua_ls = {
            enable = true;
            settings = {
              Lua = {
                hint = {
                  enable = true;
                  arrayIndex = "Auto";
                  setType = true;
                };
              };
            };
          };
          ts_ls = {
            enable = true;
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayEnumMemberValueHints = true;
                  includeInlayFunctionLikeReturnTypeHints = true;
                  includeInlayFunctionParameterTypeHints = true;
                  includeInlayParameterNameHints = "all";
                  includeInlayParameterNameHintsWhenArgumentMatchesName = true;
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayVariableTypeHints = true;
                };
              };
              javascript = {
                inlayHints = {
                  includeInlayEnumMemberValueHints = true;
                  includeInlayFunctionLikeReturnTypeHints = true;
                  includeInlayFunctionParameterTypeHints = true;
                  includeInlayParameterNameHints = "all";
                  includeInlayParameterNameHintsWhenArgumentMatchesName = true;
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayVariableTypeHints = true;
                };
              };
            };
          };
          nil_ls = {
            enable = true;
            settings = {
              formatting = {
                command = [ "nixfmt" ];
              };
              nix = {
                flake = {
                  autoArchive = true;
                  autoEvalInputs = false;
                };
              };
            };
          };
          pyright = {
            enable = true;
            settings = {
              python = {
                analysis = {
                  typeCheckingMode = "basic";
                  inlayHints = {
                    variableTypes = true;
                    functionReturnTypes = true;
                  };
                };
              };
            };
          };
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

      # Gitsigns Navigation
      {
        mode = "n";
        key = "]c";
        action.__raw = ''
          function()
            if vim.wo.diff then
              vim.cmd.normal { ']c', bang = true }
            else
              require('gitsigns').nav_hunk 'next'
            end
          end
        '';
        options = {
          desc = "Jump to next git [c]hange";
        };
      }
      {
        mode = "n";
        key = "[c";
        action.__raw = ''
          function()
            if vim.wo.diff then
              vim.cmd.normal { '[c', bang = true }
            else
              require('gitsigns').nav_hunk 'prev'
            end
          end
        '';
        options = {
          desc = "Jump to previous git [c]hange";
        };
      }

      # Gitsigns Actions - visual mode
      {
        mode = "v";
        key = "<leader>hs";
        action.__raw = ''
          function()
            require('gitsigns').stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end
        '';
        options = {
          desc = "git [s]tage hunk";
        };
      }
      {
        mode = "v";
        key = "<leader>hr";
        action.__raw = ''
          function()
            require('gitsigns').reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end
        '';
        options = {
          desc = "git [r]eset hunk";
        };
      }

      # Gitsigns Actions - normal mode
      {
        mode = "n";
        key = "<leader>hs";
        action.__raw = ''
          function()
            require('gitsigns').stage_hunk()
          end
        '';
        options = {
          desc = "git [s]tage hunk";
        };
      }
      {
        mode = "n";
        key = "<leader>hr";
        action.__raw = ''
          function()
            require('gitsigns').reset_hunk()
          end
        '';
        options = {
          desc = "git [r]eset hunk";
        };
      }
      {
        mode = "n";
        key = "<leader>hS";
        action.__raw = ''
          function()
            require('gitsigns').stage_buffer()
          end
        '';
        options = {
          desc = "git [S]tage buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>hu";
        action.__raw = ''
          function()
            require('gitsigns').undo_stage_hunk()
          end
        '';
        options = {
          desc = "git [u]ndo stage hunk";
        };
      }
      {
        mode = "n";
        key = "<leader>hR";
        action.__raw = ''
          function()
            require('gitsigns').reset_buffer()
          end
        '';
        options = {
          desc = "git [R]eset buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>hp";
        action.__raw = ''
          function()
            require('gitsigns').preview_hunk()
          end
        '';
        options = {
          desc = "git [p]review hunk";
        };
      }
      {
        mode = "n";
        key = "<leader>hb";
        action.__raw = ''
          function()
            require('gitsigns').blame_line({ full = true })
          end
        '';
        options = {
          desc = "git [b]lame line";
        };
      }
      {
        mode = "n";
        key = "<leader>hd";
        action.__raw = ''
          function()
            require('gitsigns').diffthis()
          end
        '';
        options = {
          desc = "git [d]iff against index";
        };
      }
      {
        mode = "n";
        key = "<leader>hD";
        action.__raw = ''
          function()
            require('gitsigns').diffthis '@'
          end
        '';
        options = {
          desc = "git [D]iff against last commit";
        };
      }

      # Gitsigns Toggles
      {
        mode = "n";
        key = "<leader>tb";
        action.__raw = ''
          function()
            require('gitsigns').toggle_current_line_blame()
          end
        '';
        options = {
          desc = "[T]oggle git show [b]lame line";
        };
      }
      {
        mode = "n";
        key = "<leader>hi";
        action.__raw = ''
          function()
            require('gitsigns').preview_hunk_inline()
          end
        '';
        options = {
          desc = "git preview hunk [i]nline";
        };
      }

      # Toggle inlay hints
      {
        mode = "n";
        key = "<leader>th";
        action.__raw = ''
          function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end
        '';
        options = {
          desc = "[T]oggle inlay [h]ints";
        };
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
      # lspkind.nvim
      # rainbow-delimiters?
      # configure vim.diagnostics.config
      # configure
      # lsp highlighting bindings from kickstart
    };
  };
}
