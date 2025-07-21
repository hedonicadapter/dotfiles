{
  inputs,
  outputs,
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: {
  # You can import other home-manager modules here
  imports = with inputs; [
    ags.homeManagerModules.default
    # ../cachix.nix
    matugen.nixosModules.default
    spicetify-nix.homeManagerModules.default
    nixcord.homeModules.nixcord
    neovim-flake.homeModules.default

    (import ../home-manager-modules/tmux.nix {inherit pkgs lib;})
    (import ../home-manager-modules/zsh.nix {inherit pkgs lib;})
    (import ../home-manager-modules/kitty.nix {inherit outputs pkgs lib config;})
    (import ../home-manager-modules/tofi.nix {inherit config lib outputs pkgs;})
    ../home-manager-modules/atuin.nix
    ../home-manager-modules/fzf.nix
    ../home-manager-modules/direnv.nix
    (import ../home-manager-modules/nh.nix {flakeDir = "/etc/nixos/main";})
    (import ../home-manager-modules/git.nix {
      userName = "hedonicadapter";
      userEmail = "mailservice.samherman@gmail.com";
      inherit pkgs;
    })

    (import ../home-manager-modules/anti-sleep-neglector/service.nix {inherit outputs inputs config lib pkgs;})
    (import ../home-manager-modules/fastfetch/default.nix {inherit outputs;})

    (import ../home-manager-modules/spicetify.nix {inherit inputs outputs pkgs;})
    (import ../home-manager-modules/nixcord.nix {inherit outputs pkgs lib config;})
    ../home-manager-modules/firefox.nix
  ];

  home.username = "hedonicadapter";
  home.homeDirectory = "/home/hedonicadapter";

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      inputs.nur.overlays.default
    ];
    config.allowUnfree = true;
  };

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
      night = 3500.0;
      solar_noon = 7000.0;
      sunrise = 5500.0;
      sunset = 5000.0;
    };
    crt-effect = {
      glowStrength = 0.52;
      glowRadius = 0.001;
      scanlineFrequency = 1500.0;
      scanlineIntensity = 0.03;
      curvatureStrength = 0.06;
      brightness = 0.0;
      contrast = 1.00;
    };
  };
  services.anti-sleep-neglector-wallpaper = {
    enable = true;
    wallpapersDir = "${config.home.homeDirectory}/Pictures/wallpapers";
  };

  programs.matugen.enable = true;

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
      pkgs.libnotify
      tray
      mpris
      powerprofiles

      pkgs.gtksourceview
      pkgs.webkitgtk
      pkgs.accountsservice
    ];
    # configDir = ../home-manager-modules/ags;
  };

  home.packages = with pkgs;
    [
      (callPackage ../home-manager-modules/hints/hints-derivation.nix {})
      inputs.zen-browser.packages."${system}".beta
      google-chrome
      webcord
      neovide
      transmission
      hyprpicker
      speedread
      lutris
      (mpv.override {scripts = [mpvScripts.mpris];})
      streamlink
      twitch-tui
      pipe-viewer # youtube cli
      yt-dlp # youtube to mp3
      resources

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
      blender
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
      maple-mono.NF
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

  nvim = let
    inherit (inputs.neovim-flake) utils;
    basePackage = inputs.neovim-flake.packageDefinitions.nvim or ({...}: {});
  in {
    enable = true;
    packageDefinitions = {
      merge.nvim = utils.mergeCatDefs basePackage ({pkgs, ...}: {
        extra.palette = outputs.palette;
        extra.font = config.stylix.fonts.monospace.name;
      });
    };
  };

  stylix.targets.hyprland.enable = lib.mkForce false; # INFO: stylix configures a deprecated shadow attribute
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.default;
    systemd.enable = true;
    systemd.variables = ["--all"];
    extraConfig = import ../home-manager-modules/hyprland/hyprland.conf.nix {inherit outputs lib;};
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
      #  TODO: marked broken
      # pkgs.hyprlandPlugins.hyprfocus
    ];
    xwayland.enable = true;
  };

  # TODO: null wallpaper workaround stylix #200
  services.hyprpaper.enable = lib.mkForce false;
  stylix.targets.hyprpaper.enable = lib.mkForce false;

  home.file = {
    ".config/ags" = {
      source = ../home-manager-modules/ags;
      recursive = true;
    };
    ".config/ags/style.scss".text = import ../home-manager-modules/ags/style.scss.nix {inherit outputs;};
    ".config/hypr" = {
      source = ../home-manager-modules/hyprland;
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
      source = ../home-manager-modules/emoji/list.txt;
    };
    "${config.home.homeDirectory}/Documents/notes/Braing/.obsidian/snippets/global.css".text = import ../home-manager-modules/obsidian/global.css.nix {inherit outputs;};
    ".oh-my-zsh/custom/themes" = {
      source = ../home-manager-modules/oh-my-zsh/themes;
      recursive = true;
    };
    ".config/fastfetch/logo.txt" = {
      source = ../home-manager-modules/fastfetch/logo.txt;
    };

    ".config/streamlink/config".source = ../home-manager-modules/streamlink/config;

    ".config/hints/config.json".text = import ../home-manager-modules/hints/config.json.nix {inherit outputs config;};

    "${config.home.homeDirectory}/.zen/wx2n5f38.default/chrome/userChrome.css".text = import ../home-manager-modules/zen-browser/userChrome.css.nix {inherit outputs;};
    "${config.home.homeDirectory}/.zen/wx2n5f38.default/chrome/userContent.css".text = import ../home-manager-modules/zen-browser/userContent.css.nix {inherit outputs;};
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch"; # Nicely reload system units when changing configs

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    # iconTheme.package = pkgs.fluent-icon-theme;
    # iconTheme.name = "Fluent";
    # cursorTheme.package = pkgs.callPackage ../home-manager-modules/oxygen-neon-cursors.nix {};
    # cursorTheme.name = "Oxygen-Neon";
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
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";

    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    XDG_RUNTIME_DIR = "/run/user/$UID";
    # WINIT_X11_SCALE_FACTOR = 0.75;
  };

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11";
}
