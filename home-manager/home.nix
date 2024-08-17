{
  inputs,
  outputs,
  pkgs,
  lib,
  config,
  ...
}: let
  unstable = import <nixos-unstable> {};
in {
  # You can import other home-manager modules here
  imports = [
    inputs.ags.homeManagerModules.default
    # ../cachix.nix
    inputs.matugen.nixosModules.default

    ./firefox.nix
    # ./tmux.nix
    # ./zellij.nix
    ./zsh.nix
    ./bat.nix
    # (import ./foot.nix {inherit outputs;})
    (import ./kitty.nix {inherit outputs pkgs lib;})
    (import ./yazi.nix {inherit pkgs;})
    (import ./tofi.nix {inherit config lib outputs pkgs;})
    (import ./nvim.nix {inherit inputs outputs pkgs config;})
    (import ./modules/anti-sleep-neglector/service.nix {inherit inputs config lib pkgs;})
    (import ./modules/fastfetch/default.nix {inherit outputs;})
  ];

  services.anti-sleep-neglector = {
    enable = true;
  };
  services.anti-sleep-neglector-monitor = {
    enable = true;
  };
  services.anti-sleep-neglector-gamma = {
    enable = true;
  };
  services.anti-sleep-neglector-wallpaper = {
    enable = true;
    wallpapersDir = "${config.home.homeDirectory}/Pictures/wallpapers";
  };

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      inputs.neovim-nightly-overlay.overlays.default
      inputs.nur.overlay
      inputs.awesome-neovim-plugins.overlays.default
      inputs.nixneovimplugins.overlays.default
      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
    ];

    config = {
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "beeper"
          "terraform"
          "steamcmd"
          "steam-original"
          "steam-run"
          "steam"
          "rider"
          "sf-pro"
          "warp-terminal-0.2024.02.20.08.01.stable_01"
          "warp-terminal"
          "copilot.vim"
          "ticktick"
          "betterttv"
        ];
    };
  };

  home.username = "hedonicadapter";
  home.homeDirectory = "/home/hedonicadapter";

  programs.matugen = {enable = true;};

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      dialect = "uk";
      update_check = false;
      sync_frequency = 0;
      filter_mode = "directory";
      style = "compact";
      enter_accept = true;
      keymap_mode = "vim-insert";

      # sync_address = "https://api.atuin.xyz";
      # sync.records = true;
      # daemon.enabled = true;
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "hedonicadapter";
    userEmail = "mailservice.samherman@gmail.com";
    extraConfig = {
      credential.helper = "${
        pkgs.git.override {withLibsecret = true;}
      }/bin/git-credential-libsecret";
    };
  };

  programs.ags = {
    enable = true;
    extraPackages = with pkgs; [gtksourceview webkitgtk accountsservice];
  };

  home.packages = with pkgs;
    [
      gimp-with-plugins
      webcord
      neovide
      transmission
      beeper
      hyprpicker
      speedread
      steamcmd
      bottles
      lutris
      mpv
      streamlink
      twitch-tui

      azure-functions-core-tools
      google-cloud-sdk
      firebase-tools
      docker-compose
      azure-cli

      grim
      slurp
      jq
      bicep
      gh
      libGLU
      lazydocker
      socat # for listening to unix socket events
    ]
    # Languages
    ++ [
      go
      terraform
      dart-sass
      sassc
      typescript
      bun
      mono # for sniprun c#
      (with dotnetCorePackages; combinePackages [sdk_6_0 sdk_7_0 sdk_8_0])
      cargo
      rustc
    ]
    # Language servers
    ++ [
      nodePackages.bash-language-server
      lua-language-server
      tailwindcss-language-server
      nodePackages.typescript-language-server
      nodePackages."@astrojs/language-server"
      vscode-langservers-extracted
      yaml-language-server
      terraform-ls
      terraform-lsp
      nil
      dockerfile-language-server-nodejs
      htmx-lsp
      sqls
      vim-language-server
    ]
    # Formatters
    ++ [
      nodePackages.prettier
      prettierd
      csharpier
      alejandra
      stylua
      sqlfluff
    ]
    # Fonts
    ++ [
      nerdfonts
      maple-mono-NF
      cartograph-cf
      material-symbols
    ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.default;
    systemd.enable = true;
    systemd.variables = ["--all"];
    extraConfig = "${builtins.readFile ./modules/hyprland/hyprlant.conf}";
    plugins = [inputs.split-monitor-workspaces.packages.${pkgs.system}.default];
    xwayland.enable = true;
  };

  home.file = {
    ".config/hypr" = {
      source = ./modules/hyprland;
      recursive = true;
    };
    ".config/nvim/lua" = {
      source = ./modules/nvim/lua;
      recursive = true;
    };
    ".config/nvim/lua/reactive/presets" = {
      source = ./modules/nvim/plugins/reactive;
      recursive = true;
    };
    ".config/ags" = {
      source = ./modules/ags;
      recursive = true;
    };
    ".config/tofi/emoji-list.txt" = {
      source = ./modules/emoji/list.txt;
    };
    ".config/ags/colors.json" = {
      text = builtins.toJSON outputs.colors;
    };
    "${config.home.homeDirectory}/Documents/notes/Braing/.obsidian/snippets/global.css".source = ./modules/obsidian/global.css;
    ".config/BetterDiscord" = {
      source = ./modules/discord;
      recursive = true;
    };
    ".oh-my-zsh/custom/themes" = {
      source = ./modules/oh-my-zsh/themes;
      recursive = true;
    };
    ".config/fastfetch/logo.txt" = {
      source = ./modules/fastfetch/logo.txt;
    };

    ".config/streamlink/config".source = ./modules/streamlink/config;
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch"; # Nicely reload system units when changing configs

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    iconTheme.package = pkgs.fluent-icon-theme;
    iconTheme.name = "Fluent";
    cursorTheme.package = pkgs.bibata-cursors-translucent;
    cursorTheme.name = "Bibata_Ghost";
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = "edge.desktop";
    "application/pdf" = "edge.desktop";
    "x-scheme-handler/http" = "edge.desktop";
    "x-scheme-handler/https" = "edge.desktop";
    "text/plain" = "neovide.desktop";
  };

  home.sessionVariables = {
    EDITOR = "neovide";
    NIXOS_OZONE_WL = "1";
    ZSH_CUSTOM = "${config.home.homeDirectory}/.oh-my-zsh/custom";

    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    XDG_RUNTIME_DIR = "/run/user/$UID";
    # WINIT_X11_SCALE_FACTOR = 0.75;
  };

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11";
}
