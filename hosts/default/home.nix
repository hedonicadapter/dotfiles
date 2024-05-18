{ inputs, outputs, pkgs, lib, config, ... }:

let
  unstable = import <nixos-unstable> { };
  spotify-wrap = pkgs.writeShellScriptBin "wrap-spotify"
    (builtins.readFile ../../wrappers/spotify.nix);
  armcord-wrap = pkgs.writeShellScriptBin "wrap-armcord"
    (builtins.readFile ../../wrappers/armcord.nix);
  edge-wrap = pkgs.writeShellScriptBin "wrap-edge"
    (builtins.readFile ../../wrappers/edge.nix);
  obsidian-wrap = pkgs.writeShellScriptBin "wrap-obsidian"
    (builtins.readFile ../../wrappers/obsidian.nix);
  teams-wrap = pkgs.writeShellScriptBin "wrap-teams"
    (builtins.readFile ../../wrappers/teams.nix);
  vscode-wrap = pkgs.writeShellScriptBin "wrap-vscode"
    (builtins.readFile ../../wrappers/vscode.nix);
  beeper-wrap = pkgs.writeShellScriptBin "wrap-beeper"
    (builtins.readFile ../../wrappers/beeper.nix);
  steam-wrap = pkgs.writeShellScriptBin "wrap-steam"
    (builtins.readFile ../../wrappers/steam.nix);

  tofi-power-menu = pkgs.writeShellScriptBin "tofi-power-menu"
    (builtins.readFile ../../modules/tofi/power-menu.sh);

in {
  imports = [ inputs.ags.homeManagerModules.default ../../cachix.nix ];

  home.username = "hedonicadapter";
  home.homeDirectory = "/home/hedonicadapter";

  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlay
    inputs.nixneovimplugins.overlays.default
  ];

  fonts.fontconfig.enable = true;

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11";

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "beeper"
      "terraform"
      "steamcmd"
      "steam-original"
      "steam-run"
      "steam"
      "rider"
    ];

  home.packages = with pkgs; [
    public-sans
    work-sans
    merriweather
    (nerdfonts.override { fonts = [ "ProggyClean" ]; })

    grim
    slurp
    lf
    jq
    cargo
    rustc
    azure-cli
    bicep
    gh
    nodePackages.pnpm
    libGLU
    wine

    nwg-look
    neovide
    jetbrains.rider
    transmission
    beeper
    #(callPackage ./neovide.nix { })
    (iosevka.override {
      privateBuildPlan =
        builtins.readFile ../../modules/Iosevka/build-plans.toml;
      set = "Term";
    })
    material-symbols
    font-awesome

    spotify-wrap
    armcord-wrap
    edge-wrap
    obsidian-wrap
    teams-wrap
    vscode-wrap
    beeper-wrap
    steam-wrap
    steamcmd
    # cachix
    bottles
    lutris

    tofi-power-menu

    nodePackages.prettier
    prettierd
    sassc
    typescript
    nodePackages.typescript-language-server
    (with dotnetCorePackages; combinePackages [ sdk_6_0 sdk_7_0 sdk_8_0 ])
    csharp-ls
    azure-functions-core-tools
    csharpier
    sqlfluff
    go
    terraform
    stylua
    nixfmt
    tailwindcss-language-server
  ];

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "neovide";
    NIXOS_OZONE_WL = "1";
    GTK_THEME = "Orchis-Yellow-Dark-Compact";
    ZSH_CUSTOM = "${config.home.homeDirectory}/.oh-my-zsh/custom";

    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    XDG_RUNTIME_DIR = "/run/user/$UID";
    # WINIT_X11_SCALE_FACTOR = 0.75;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # programs.starship = {
  #   enable = true;
  #   settings = pkgs.lib.importTOML ../../modules/starship/powerline.toml;
  # };

  # programs.bash = {
  #   enable = true;
  #   historyControl = [ "erasedups" ];
  #  bashrcExtra = "eval \"$(zoxide init bash)\"";
  # };

  programs.tofi = {
    enable = true;
    settings = {
      width = "100%";
      height = "100%";
      border-width = 0;
      outline-width = 0;
      padding-left = "35%";
      padding-top = "35%";
      result-spacing = 25;
      num-results = 5;
      font = "Work Sans";
      font-size = 24;
      background-color = "#000A";
      prompt-color = "#ECE1D7";
      selection-color = "#273142";
      selection-match-color = "#233524";

      history-file = "${config.home.homeDirectory}/.config/tofi/history";
    };
  };
  home.file.".config/obsidian/global.css".source =
    ../../modules/obsidian/global.css;

  home.file.".oh-my-zsh/custom/themes/headline/headline.zsh-theme".source =
    ../../modules/oh-my-zsh/themes/headline/headline.zsh-theme;
  programs.zsh = {
    enable = true;

    autosuggestion = { enable = true; };

    oh-my-zsh = {
      enable = true;
      extraConfig = ''
        eval "$(zoxide init zsh)"
        export XDG_RUNTIME_DIR=/run/user/$(id -u)
      '';
      theme = "headline/headline";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";

        shell = "zsh";
        # font = "Iosevka Term:size=8";
        font = "ProggyClean Nerd Font Mono:size=13";
        dpi-aware = "yes";
        pad = "40x0";
        font-size-adjustment = 0.9;
        line-height = 15;
      };
      colors = {
        foreground = "ECE1D7";
        background = "292522";
        selection-background = "403A36";
        selection-foreground = "ECE1D7";
        regular0 = "34302C";
        regular1 = "BD8183";
        regular2 = "78997A";
        regular3 = "E49B5D";
        regular4 = "7F91B2";
        regular5 = "B380B0";
        regular6 = "7B9695";
        regular7 = "C1A78E";
        bright0 = "867462";
        bright1 = "D47766";
        bright2 = "85B695";
        bright3 = "EBC06D";
        bright4 = "A3A9CE";
        bright5 = "CF9BC2";
        bright6 = "89B3B6";
        bright7 = "ECE1D7";
      };
      cursor = { blink = "yes"; };
    };
  };

  programs.git = {
    enable = true;
    userName = "hedonicadapter";
    userEmail = "mailservice.samherman@gmail.com";
    extraConfig = {
      credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    systemd.variables = [ "--all" ];
    extraConfig = "${builtins.readFile ../../modules/hyprland/hyprland.conf}";
  };
  home.file.".config/hypr/auto-start.sh".source =
    ../../modules/hyprland/auto-start.sh;
  home.file.".config/hypr/wallpaper-cycler.sh".source =
    ../../modules/hyprland/wallpaper-cycler.sh;

  home.file.".config/nvim/lua" = {
    source = ../../modules/nvim/lua;
    recursive = true;
  };
  home.file.".config/nvim/lua/reactive/presets" = {
    source = ../../modules/nvim/plugins/reactive;
    recursive = true;
  };

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
  in {
    package = pkgs.neovim-nightly;
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins;
      [
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

        {
          plugin = gitsigns-nvim;
          config = toLua ''
            require('gitsigns').setup()
          '';
        }

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

        {
          plugin = nvim-lspconfig;
          config = toLuaFile ../../modules/nvim/plugins/lsp.lua;
        }

        nvim-web-devicons

        telescope-fzf-native-nvim
        plenary-nvim
        nvim-ts-autotag
        vim-visual-multi
        vim-wakatime
        nvim-ts-context-commentstring
        sqlite-lua

        {
          plugin = nvim-treesitter-context;
          config = toLua ''
            require("treesitter-context").setup({
              enable = true,
              max_lines = 3,
            })

            vim.api.nvim_exec([[
              autocmd BufEnter * hi TreesitterContextBottom gui=italic guisp=NONE
            ]], false)
          '';
        }

        copilot-vim
        # {
        #   plugin = copilotchat-nvim;
        #   config = toLua ''
        #     require('CopilotChat').setup()
        #   '';
        # }

        neodev-nvim
        {
          plugin = nvim-cmp;
          config = toLuaFile ../../modules/nvim/plugins/cmp.lua;
        }
        cmp-nvim-lsp

        {
          plugin = dressing-nvim;
          config = toLua ''
            require('dressing').setup()
          '';
        }

        {
          plugin = conform-nvim;
          config = toLua ''
            require('conform').setup({
             formatters_by_ft = {
             lua = { "stylua" },
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
              nix = { "nixfmt"},
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

        {
          plugin = oil-nvim;
          config = toLua ''
            require('oil').setup()
            vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
          '';
        }

        {
          plugin = telescope-nvim;
          config = toLuaFile ../../modules/nvim/plugins/telescope.lua;
        }

        telescope-undo-nvim

        {
          plugin = nvim-neoclip-lua;
          config = toLua ''
            require('neoclip').setup()
          '';
        }

        {
          plugin = (nvim-treesitter.withPlugins (p: [
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
          ]));
          config = toLuaFile ../../modules/nvim/plugins/treesitter.lua;
        }

        {
          plugin = zoxide-vim;
          config = toLua ''
            vim.cmd [[command! -bang -nargs=* -complete=customlist,zoxide#complete Z zoxide#vim_cd <args>]]
          '';
        }

        {
          plugin = nvim-colorizer-lua;
          config = toLuaFile ../../modules/nvim/plugins/colorizer.lua;
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
          plugin = indent-blankline-nvim;
          config = toLua ''
            require("ibl").setup {}
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
          config = toLuaFile ../../modules/nvim/plugins/toggleterm.lua;
        }

        {
          plugin = nvim-cokeline;
          config = toLuaFile ../../modules/nvim/plugins/cokeline/cokeline.lua;
        }

        {
          plugin = unstable.vimPlugins.staline-nvim;
          config = toLuaFile ../../modules/nvim/plugins/staline.lua;
        }

        {
          plugin = mini-nvim;
          config = toLuaFile ../../modules/nvim/plugins/mini.lua;
        }

        {
          plugin = satellite-nvim;
          config = toLua ''
            require('satellite').setup()
          '';
        }

        {
          plugin = twilight-nvim;
          config = toLuaFile ../../modules/nvim/plugins/twilight.lua;
        }

        {
          plugin = melange-nvim;
          config = "colorscheme melange";
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
      ] ++ [ ];

    extraLuaConfig = ''
      ${builtins.readFile ../../modules/nvim/init.lua}
    '';
  };

  programs.ags = {
    enable = true;

    # null or path, leave as null if you don't want hm to manage the config
    # configDir = ../../modules/ags;

    # additional packages to add to gjs's runtime
    extraPackages = with pkgs; [ gtksourceview webkitgtk accountsservice ];
  };
  home.file.".config/ags" = {
    source = ../../modules/ags;
    recursive = true;
  };

  gtk.enable = true;

  gtk.iconTheme.package = pkgs.fluent-icon-theme;
  gtk.iconTheme.name = "Fluent";

  gtk.font.name = "Noto Sans";
  gtk.font.package = pkgs.noto-fonts;

  gtk.cursorTheme.package = pkgs.bibata-cursors-translucent;
  gtk.cursorTheme.name = "Bibata_Ghost";

  gtk.theme.package = pkgs.orchis-theme;
  gtk.theme.name = "Orchis-Yellow-Dark-Compact";

  xdg.mimeApps.defaultApplications = {
    "text/html" = "edge.desktop";
    "application/pdf" = "edge.desktop";
    "x-scheme-handler/http" = "edge.desktop";
    "x-scheme-handler/https" = "edge.desktop";
    "text/plain" = "neovide.desktop";
  };

  xdg.configFile = {
    "gtk-4.0/assets".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };
}

