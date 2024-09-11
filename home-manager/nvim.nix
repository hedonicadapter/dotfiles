{
  inputs,
  outputs,
  pkgs,
  config,
  ...
}: {
  programs.neovim = let
    toLua = str: ''
      lua << EOF
      ${str}
      EOF
    '';
    toLuaFile = file: ''
      lua << EOF
      ${builtins.readFile file}
      EOF
    '';
    luaColors = builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: value: "vim.g['colors_${name}'] = ${builtins.toJSON value}") outputs.colors));
    luaColorsOpaque = builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: value: "vim.g['colors_${name}_opaque'] = ${builtins.toJSON value}") outputs.colors_opaque));
  in {
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = "";

    plugins = with pkgs.vimPlugins; [
      roslyn-nvim
      {
        plugin = auto-session;
        config = toLua ''
          require('auto-session').setup({
            auto_session_suppress_dirs = { "${config.home.homeDirectory}", "~/", "~/Documents/coding", "~/Downloads", "/"},
            log_level = "error",
            auto_restore_enabled = false,
            auto_save_enabled = true,
            auto_session_root_dir = vim.fn.stdpath('data').."/sessions/",
          })
        '';
      }

      {
        plugin = coq_nvim;
        config = toLua ''
          vim.g.coq_settings = {
            display = {
              preview = {
                border = "rounded",
              },
            },
          }
        '';
      }

      {
        plugin = git-conflict-nvim;
        config = toLua ''
          require('git-conflict').setup()
        '';
      }

      {
        plugin = pkgs.awesomeNeovimPlugins.ts-error-translator-nvim;
        config = toLua ''
          require("ts-error-translator").setup()
        '';
      }

      omnisharp-extended-lsp-nvim
      {
        plugin = lsp_signature-nvim;
        config = toLua ''
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local bufnr = args.buf
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if vim.tbl_contains({ 'null-ls' }, client.name) then  -- blacklist lsp
                return
              end
              require("lsp_signature").on_attach({
                bind = true,
                handler_opts = {
                  border = "rounded"
                }
              }, bufnr)
            end,
          })
        '';
      }

      promise-async
      {
        plugin = nvim-ufo;
        config = toLua ''
          vim.o.foldcolumn = '0'
          vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
          vim.o.foldlevelstart = 99
          vim.o.foldenable = true

          vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
          vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
        '';
      }
      {
        plugin = nvim-lspconfig;
        config = toLuaFile ./modules/nvim/plugins/lsp.lua;
      }
      {
        plugin = pkgs.awesomeNeovimPlugins.garbage-day-nvim;
        config = toLua ''
          require("garbage-day").setup({})
        '';
      }

      {
        plugin = pkgs.awesomeNeovimPlugins.hawtkeys-nvim;
        config = toLua ''
          require("hawtkeys").setup({})
        '';
      }

      {
        plugin = sniprun;
        config = toLua ''
          require'sniprun'.setup({})
        '';
      }

      telescope-fzf-native-nvim
      plenary-nvim
      nvim-ts-autotag
      vim-visual-multi
      vim-wakatime
      nvim-ts-context-commentstring
      sqlite-lua

      {
        plugin = nvim-spider;
        config = toLua ''
          require('spider').setup({
            skipInsignificantPunctuation = false,
          })

          vim.keymap.set(
          	{ "n", "o", "x" },
          	"w",
          	"<cmd>lua require('spider').motion('w')<CR>",
          	{ desc = "Spider-w" }
          )
          vim.keymap.set(
          	{ "n", "o", "x" },
          	"e",
          	"<cmd>lua require('spider').motion('e')<CR>",
          	{ desc = "Spider-e" }
          )
          vim.keymap.set(
          	{ "n", "o", "x" },
          	"b",
          	"<cmd>lua require('spider').motion('b')<CR>",
          	{ desc = "Spider-b" }
          )
        '';
      }

      {
        plugin = flash-nvim;
        config = toLua ''
          require('flash').setup({
              prompt = {
                  enabled = true,
                  prefix = { { "   ", "FlashPromptIcon" } },
              },
              label = {
                uppercase = false,
                rainbow = {
                    enabled = true,
                    shade = 6,
                },
              },
          })
        '';
      }

      {
        plugin = nvim-treesitter-context;
        config = toLua ''
          require("treesitter-context").setup({
            enable = true,
            max_lines = 3,
          })

        '';
      }

      # copilot-vim
      {
        plugin = CopilotChat-nvim;
        config = toLua ''
          require('CopilotChat').setup({
            show_help = false,
            separator = "_",
            context = "buffers",
            answer_header = "## (~‾⌣‾)> "
          })
        '';
      }

      cmp-cmdline
      cmp-nvim-lsp
      cmp-async-path
      cmp-buffer
      {
        plugin = nvim-cmp;
        config = toLuaFile ./modules/nvim/plugins/cmp.lua;
      }

      nui-nvim

      {
        plugin = conform-nvim;
        config = toLua ''
          require('conform').setup({
           formatters_by_ft = {
            lua = { "stylua" },
            nix = { "alejandra" },
            javascript = { { "prettierd", "prettier" } },
            typescript = { { "prettierd", "prettier" } },
            javascriptreact = { { "prettierd", "prettier" } },
            typescriptreact = { { "prettierd", "prettier" } },
            json = { "prettierd" },
            html = { "prettierd" },
            css = { "prettierd" },
            scss = { "prettierd" },
            sass = { "prettierd" },
            astro = { "prettierd" },
            nix = { "alejandra"},
            bicep = { "bicep" },
            cs = {"csharpier"},
            go = {"gofmt"},
            sql = {"sqlfluff"},
            tf = {"terraform_fmt"},
          },
          format_on_save = {
              -- These options will be passed to conform.format()
              timeout_ms = 1000,
              lsp_fallback = true,
            },
          })
        '';
      }

      diffview-nvim

      {
        plugin = oil-nvim;
        config = toLua ''
          require('oil').setup({
            delete_to_trash = true,
            show_hidden = true,
            natural_order = true,
            is_always_hidden = function(name,_)
              return name == '..' or name == '.git'
            end,
          })
          vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        '';
      }

      {
        plugin = telescope-nvim;
        config = toLuaFile ./modules/nvim/plugins/telescope.lua;
      }

      telescope-undo-nvim

      {
        plugin = nvim-neoclip-lua;
        config = toLua ''
          require('neoclip').setup()
        '';
      }

      {
        plugin = nvim-treesitter.withPlugins (p: [
          p.tree-sitter-nix
          p.tree-sitter-vim
          p.tree-sitter-vimdoc
          p.tree-sitter-luadoc
          p.tree-sitter-markdown
          p.tree-sitter-markdown-inline
          p.tree-sitter-bash
          p.tree-sitter-lua
          p.tree-sitter-json
          p.tree-sitter-astro
          p.tree-sitter-bicep
          p.tree-sitter-c-sharp
          p.tree-sitter-dockerfile
          p.tree-sitter-go
          p.tree-sitter-html
          p.tree-sitter-javascript
          p.tree-sitter-jsdoc
          p.tree-sitter-scss
          p.tree-sitter-sql
          p.tree-sitter-typescript
          p.tree-sitter-tsx
          p.tree-sitter-terraform
        ]);
        config = toLuaFile ./modules/nvim/plugins/treesitter.lua;
      }

      {
        plugin = nvim-treesitter-textobjects;
        config = toLuaFile ./modules/nvim/plugins/treesitter-textobjects.lua;
      }

      {
        plugin = zoxide-vim;
        config = toLua ''
          vim.cmd [[command! -bang -nargs=* -complete=customlist,zoxide#complete Z zoxide#vim_cd <args>]]
        '';
      }

      {
        plugin = nvim-colorizer-lua;
        config = toLuaFile ./modules/nvim/plugins/colorizer.lua;
      }

      {
        plugin = guess-indent-nvim;
        config = toLua ''
          require('guess-indent').setup()

          vim.api.nvim_exec([[
            autocmd BufEnter * silent! :GuessIndent
          ]], false)
        '';
      }

      {
        plugin = comment-nvim;
        config = toLua "require('Comment').setup()";
      }

      {
        plugin = nvim-surround;
        config = toLua "require('nvim-surround').setup{}";
      }

      {
        plugin = eyeliner-nvim;
        config = toLua ''
          require('eyeliner').setup {
            highlight_on_key = true,
            dim = true
          }
        '';
      }

      {
        plugin = toggleterm-nvim;
        config = toLuaFile ./modules/nvim/plugins/toggleterm.lua;
      }

      {
        plugin = nvim-cokeline;
        config = toLuaFile ./modules/nvim/plugins/cokeline/cokeline.lua;
      }

      {
        plugin = staline-nvim;
        # config = toLuaFile ./modules/nvim/plugins/staline.lua;
        config = toLua ''
          require("staline").setup({
            sections = {
              left = { "mode" },
              mid = {},
              right = { "", "cwd", "branch" },
            },
            mode_colors = {
              i = "${outputs.colors_opaque.green}",
              n = "${outputs.colors_opaque.beige}",
              c = "${outputs.colors_opaque.orange}",
              v = "${outputs.colors_opaque.blue}",
              V = "${outputs.colors_opaque.blue}",
            },
            mode_icons = {
              n = " ",
              i = " ",
              c = " ",
              v = " ",
              V = " ",
            },
            defaults = {
              true_colors = true,
              branch_symbol = " ",
            },
          })

        '';
      }

      {
        plugin = mini-nvim;
        config = toLuaFile ./modules/nvim/plugins/mini.lua;
      }

      {
        plugin = gitsigns-nvim;
        config = toLua ''
          require('gitsigns').setup()
        '';
      }
      diffview-nvim

      {
        plugin = nvim-scrollbar;
        config = toLua ''
          require("scrollbar").setup({
            hide_if_all_visible = true,
            handle = {
              blend = 40,
            },
          })
          require("scrollbar.handlers.gitsigns").setup()
        '';
      }

      {
        plugin = pkgs.awesomeNeovimPlugins.hlchunk-nvim;
        config = toLua ''
          require("hlchunk").setup({
            chunk = {
              enable = true,
              style = { "${outputs.colors_opaque.yellow}" },
              delay = 100,
            },
          })
        '';
      }

      {
        plugin = twilight-nvim;
        config = toLuaFile ./modules/nvim/plugins/twilight.lua;
      }

      nvim-web-devicons
      {
        plugin = pkgs.awesomeNeovimPlugins.tiny-devicons-auto-colors-nvim;
        config = toLua ''
          require('tiny-devicons-auto-colors').setup({
              colors = {
                  "${outputs.colors_opaque.orange_dim}",
                  "${outputs.colors_opaque.beige}",
                  "${outputs.colors_opaque.orange}",
                  "${outputs.colors_opaque.blush}",
                  "${outputs.colors_opaque.orange_bright}",
                  "${outputs.colors_opaque.red}",
                  "${outputs.colors_opaque.burgundy}",
                  "${outputs.colors_opaque.cyan}",
                  "${outputs.colors_opaque.green}",
                  "${outputs.colors_opaque.vanilla_pear}",
                  "${outputs.colors_opaque.yellow}",
              },
          })
        '';
      }

      {
        plugin = transparent-nvim;
        config = toLua ''
          require("transparent").setup()
        '';
      }

      {
        plugin = pkgs.vimExtraPlugins.reactive-nvim;
        config = toLua ''
          require('reactive').setup({
            configs = {
              name = "customCursorLine",
              init = function()
                  vim.opt.cursorline = true
                end,
              modes = {
                no = {
                  operators = {
                    [{ "gu", "gU", "g~", "~" }] = {
                      winhl = {
                        CursorLine = { bg = "${outputs.colors_opaque.black}" },
                        CursorLineNr = { fg = "#867462", bg = "${outputs.colors_opaque.black}" },
                      },
                    },
                    c = {
                      winhl = {
                        CursorLine = { bg = "${outputs.colors_opaque.yellow}" },
                        CursorLineNr = { fg = "${outputs.colors_opaque.yellow}", bg = "${outputs.colors_opaque.yellow}" },
                      },
                    },
                    -- yank
                    y = {
                      winhl = {
                        CursorLine = { bg = "${outputs.colors_opaque.burgundy}" },
                        CursorLineNr = { fg = "${outputs.colors_opaque.burgundy}", bg = "${outputs.colors_opaque.burgundy}" },
                      },
                    },
                  },
                },
                i = {
                  winhl = {
                    CursorLine = { bg = "${outputs.colors_opaque.green}" },
                    CursorLineNr = { fg = "${outputs.colors_opaque.green}", bg = "${outputs.colors_opaque.green}" },
                  },
                  hl = {
                    Cursor = { bg = "${outputs.colors_opaque.green}" },
                  },
                },
                c = {
                  winhl = {
                    CursorLine = { bg = "${outputs.colors_opaque.orange}" },
                    CursorLineNr = { fg = "${outputs.colors_opaque.orange}", bg = "${outputs.colors_opaque.orange}" },
                  },
                },
                n = {
                  winhl = {
                    CursorLine = { bg = "${outputs.colors_opaque.beige}" },
                    CursorLineNr = { fg = "${outputs.colors_opaque.beige}", bg = "${outputs.colors_opaque.beige}" },
                  },
                  hl = {
                    Cursor = { bg = "${outputs.colors_opaque.beige}" },
                  },
                },
                [{ "v", "V", "\x16" }] = {
                  winhl = {
                    CursorLineNr = { fg = "${outputs.colors_opaque.blue}" },
                    Visual = { bg = "${outputs.colors_opaque.blue}" },
                  },
                  hl = {
                    Cursor = { bg = "${outputs.colors_opaque.cyan}" },
                  },
                },
                [{ "s", "S", "\x13" }] = {
                  winhl = {
                    CursorLineNr = { fg = "${outputs.colors_opaque.blue}" },
                    Visual = { bg = "${outputs.colors_opaque.blue}" },
                  },
                },
                R = {
                  winhl = {
                    CursorLine = { bg = "${outputs.colors_opaque.red}" },
                    CursorLineNr = { fg = "${outputs.colors_opaque.red}", bg = "${outputs.colors_opaque.red}" },
                  },
                },
              },
            }
          })
        '';
      }

      {
        plugin = dropbar-nvim;
        config = toLua ''
          require('dropbar').setup()
          vim.o.winbar = "%{%v:lua.dropbar.get_dropbar_str()%}"
        '';
      }

      {
        plugin = dial-nvim;
        config = toLua ''
          vim.keymap.set("n", "<C-a>", function()
              require("dial.map").manipulate("increment", "normal")
          end)
          vim.keymap.set("n", "<C-x>", function()
              require("dial.map").manipulate("decrement", "normal")
          end)
          vim.keymap.set("n", "g<C-a>", function()
              require("dial.map").manipulate("increment", "gnormal")
          end)
          vim.keymap.set("n", "g<C-x>", function()
              require("dial.map").manipulate("decrement", "gnormal")
          end)
          vim.keymap.set("v", "<C-a>", function()
              require("dial.map").manipulate("increment", "visual")
          end)
          vim.keymap.set("v", "<C-x>", function()
              require("dial.map").manipulate("decrement", "visual")
          end)
          vim.keymap.set("v", "g<C-a>", function()
              require("dial.map").manipulate("increment", "gvisual")
          end)
          vim.keymap.set("v", "g<C-x>", function()
              require("dial.map").manipulate("decrement", "gvisual")
          end)
        '';
      }

      {
        plugin = pkgs.awesomeNeovimPlugins.render-markdown-nvim;
        config = toLua ''
          require('render-markdown').setup({})
        '';
      }
    ];

    extraLuaConfig = ''

      ${luaColors}
      ${luaColorsOpaque}
      ${builtins.readFile ./modules/nvim/init.lua}
    '';
  };
}
