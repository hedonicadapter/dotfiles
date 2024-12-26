{
  inputs,
  outputs,
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  #   unstable = import <nixos-unstable> {};
  discord_css = import ./modules/discord/custom.css.nix {inherit outputs;};

  removeHash = hex: builtins.substring 1 (builtins.stringLength hex - 1) hex;
  colorsRGB = builtins.mapAttrs (name: value: removeHash value) outputs.colors;
in {
  # You can import other home-manager modules here
  imports = [
    inputs.ags.homeManagerModules.default
    # ../cachix.nix
    inputs.matugen.nixosModules.default
    inputs.spicetify-nix.homeManagerModules.default

    ./firefox.nix
    # ./tmux.nix
    # ./zellij.nix
    (import ./zsh.nix {inherit pkgs;})
    # (import ./foot.nix {inherit outputs;})
    (import ./kitty.nix {inherit outputs pkgs lib;})
    # (import ./yazi.nix {inherit pkgs;})
    (import ./tofi.nix {inherit config lib outputs pkgs;})
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

    periods = {
      dawn = 4000.0;
      first_light = 4000.0;
      night = 2500.0;
      solar_noon = 7000.0;
      sunrise = 5500.0;
      sunset = 3500.0;
    };
    crt-effect = {
      glowStrength = 0.3;
      glowRadius = 0.0018;
      scanlineFrequency = 1800.0;
      scanlineIntensity = 0.04;
      curvatureStrength = 0.04;
    };
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

      inputs.nur.overlay
    ];

    config = {
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "google-chrome"
          "spotify"
          "steam-unwrapped"
          "steam-original"
          "steam-run"
          "steam"
          "sf-pro"
          "copilot.vim"
          "ticktick"
          "betterttv"
        ];
    };
  };

  home.username = "hedonicadapter";
  home.homeDirectory = "/home/hedonicadapter";

  programs.neovim = {
    enable = true;
    package = inputs.neovim-config.neovimConfig.package;
    extraLuaConfig = inputs.neovim-config.neovimConfig.extraLuaConfig;
    plugins = inputs.neovim-config.neovimConfig.plugins;
  };

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
    extraPackages = with inputs.ags.packages.${pkgs.system}; [
      io
      apps
      battery
      hyprland
      wireplumber
      bluetooth
      network
      notifd
      tray
      mpris
      powerprofiles

      pkgs.gtksourceview
      pkgs.webkitgtk
      pkgs.accountsservice
    ];
    # configDir = ./modules/ags;
  };

  # programs.spicetify = {
  #   enable = true;
  #   colorScheme = "custom";
  #
  #   customColorScheme = {
  #     text = colorsRGB.blush;
  #     subtext = colorsRGB.white;
  #     sidebar-text = colorsRGB.vanilla_pear;
  #     main = "#00000005";
  #     sidebar = colorsRGB.grey;
  #     player = colorsRGB.black;
  #     card = colorsRGB.orange;
  #     shadow = colorsRGB.burgundy;
  #     selected-row = colorsRGB.blue;
  #     button = colorsRGB.cyan;
  #     button-active = colorsRGB.blue;
  #     button-disabled = colorsRGB.grey;
  #     tab-active = colorsRGB.blush;
  #     notification = colorsRGB.green;
  #     notification-error = colorsRGB.red;
  #     misc = colorsRGB.white_dim;
  #   };
  #
  #   enabledCustomApps = with spicePkgs.apps; [marketplace];
  #   enabledExtensions = with spicePkgs.extensions; [
  #   ];
  # };
  stylix.targets.spicetify.enable = false;
  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      keyboardShortcut
      groupSession
      powerBar
      #     shuffle # shuffle+
      beautifulLyrics
      skipStats
      songStats
      autoVolume
      adblock
      autoSkipVideo
    ];
    enabledCustomApps = with spicePkgs.apps; [marketplace];
    theme = spicePkgs.themes.text;
    colorScheme = "custom";

    customColorScheme = {
      text = colorsRGB.base08;
      subtext = colorsRGB.base00;
      sidebar-text = colorsRGB.base0F;
      main = "#00000005";
      sidebar = colorsRGB.base01;
      player = colorsRGB.base00;
      card = colorsRGB.base09;
      shadow = colorsRGB.base08;
      selected-row = colorsRGB.base0D;
      button = colorsRGB.base0C;
      button-active = colorsRGB.base0D;
      button-disabled = colorsRGB.base01;
      tab-active = colorsRGB.base08;
      notification = colorsRGB.base0B;
      notification-error = colorsRGB.base08;
      misc = colorsRGB.base00;
    };
  };

  programs.spotify-player = {
    enable = true;
  };

  home.packages = with pkgs;
    [
      google-chrome
      gimp-with-plugins
      webcord
      neovide
      transmission
      hyprpicker
      speedread
      bottles
      lutris
      mpv
      streamlink
      twitch-tui
      resources

      google-cloud-sdk
      firebase-tools

      ncdu
      alsa-utils
      grim
      slurp
      jq
      gh
      libGLU
      docker-compose
      lazydocker
      socat # for listening to unix socket events
      dotool # for speed-reader.sh
      inputs.ags.packages.${pkgs.system}.io # expose ags cli
      rofimoji
    ]
    # Languages
    ++ [
      go
      dart-sass
      sassc
      typescript
      bun
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
      nil
      dockerfile-language-server-nodejs
      htmx-lsp
      sqls
      vim-language-server
    ]
    # Formatters & linters
    ++ [
      nodePackages.prettier
      prettierd
      alejandra
      stylua
      sqlfluff
    ]
    # Fonts
    ++ [
      nerd-fonts.symbols-only
      maple-mono-NF
      # cartograph-cf DMCA'd
      ultimate-oldschool-pc-font-pack
      glasstty-ttf
      material-symbols
    ]
    # AGS
    ++ [
      inputs.ags.packages.${pkgs.system}.notifd
      meson
      vala
      gdk-pixbuf
      json-glib
      gobject-introspection
    ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.default;
    systemd.enable = true;
    systemd.variables = ["--all"];
    extraConfig = import ./modules/hyprland/hyprland.conf.nix {inherit outputs lib;};
    plugins = [inputs.split-monitor-workspaces.packages.${pkgs.system}.default];
    xwayland.enable = true;
  };

  # null wallpaper workaround stylix #200
  services.hyprpaper.enable = lib.mkForce false;
  stylix.targets.hyprpaper.enable = lib.mkForce false;

  home.file = {
    ".config/ags" = {
      source = ./modules/ags;
      recursive = true;
    };
    ".config/ags/style.scss".text = import ./modules/ags/style.scss.nix {inherit outputs;};
    ".config/hypr" = {
      source = ./modules/hyprland;
      recursive = true;
    };
    ".config/hypr/speed-read.sh".source = "${pkgs.writeShellScript "speed-reader" ''
      #!/usr/bin/env bash

      (
        for i in {1..4}; do
          sleep "0.$i"
          echo key rightbrace | DOTOOL_XKB_LAYOUT=${osConfig.services.xserver.xkb.layout} dotool
          echo key rightbrace | DOTOOL_XKB_LAYOUT=${osConfig.services.xserver.xkb.layout} dotool
        done
      ) &

      wl-paste --no-newline --primary | speedread -w 150
      read -p 'Press [Enter] to close...'
    ''}";
    ".config/tofi/emoji-list.txt" = {
      source = ./modules/emoji/list.txt;
    };
    "${config.home.homeDirectory}/Documents/notes/Braing/.obsidian/snippets/global.css".text = import ./modules/obsidian/global.css.nix {inherit outputs;};
    ".config/BetterDiscord" = {
      source = ./modules/discord;
      recursive = true;
    };
    ".config/BetterDiscord/data/canary/custom.css".text = discord_css;
    ".config/Vencord/settings/quickCss.css".text = discord_css;
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
