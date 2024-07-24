{
  outputs,
  pkgs,
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
  in {
    # package = pkgs.neovim-nightly;
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
            auto_session_suppress_dirs = { "~/", "~/Documents/coding", "~/Downloads", "/"},
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

      # nvim-navbuddy
      {
        plugin = symbols-outline-nvim;
        config = toLua ''
          require("symbols-outline").setup()
        '';
      }

      {
        plugin = git-conflict-nvim;
        config = toLua ''
          require('git-conflict').setup()
        '';
      }

      omnisharp-extended-lsp-nvim

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
        plugin = sniprun;
        config = toLua ''
          require'sniprun'.setup({
          })
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
                  prefix = { { "   FLASH", "FlashPromptIcon" } },
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
            separator = "჻჻჻",
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

      ultimate-autopair-nvim

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
        plugin = indent-blankline-nvim;
        config = toLua ''
          require("ibl").setup {}
        '';
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
        config = toLuaFile ./modules/nvim/plugins/staline.lua;
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
        plugin = twilight-nvim;
        config = toLuaFile ./modules/nvim/plugins/twilight.lua;
      }

      melange-nvim
      {
        plugin = gruvbox-nvim;
        config = toLua ''
          require("gruvbox").setup()
        '';
      }
      {
        plugin = pkgs.awesomeNeovimPlugins.mellifluous-nvim;
        config = toLua ''
          require("mellifluous").setup({color_set = "alduin"})
        '';
      }

      nvim-web-devicons
      {
        plugin = pkgs.awesomeNeovimPlugins.tiny-devicons-auto-colors-nvim;
        config = toLua ''
          require('tiny-devicons-auto-colors').setup({
              colors = {
                  "${outputs.colors.orange_dim}",
                  "${outputs.colors.beige}",
                  "${outputs.colors.orange}",
                  "${outputs.colors.blush}",
                  "${outputs.colors.orange_bright}",
                  "${outputs.colors.red}",
                  "${outputs.colors.burgundy}",
                  "${outputs.colors.cyan}",
                  "${outputs.colors.green}",
                  "${outputs.colors.vanilla_pear}",
                  "${outputs.colors.yellow}",
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
          require('reactive').setup {
            load = 'customCursor'
          }
        '';
      }

      {
        plugin = dropbar-nvim;
        config = toLua ''
          require('dropbar').setup()
          vim.o.winbar = "%{%v:lua.dropbar.get_dropbar_str()%}"
        '';
      }
    ];

    extraLuaConfig = ''
      ${luaColors}
      ${builtins.readFile ./modules/nvim/init.lua}
    '';
  };
}
