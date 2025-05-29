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
  removeHash = hex: builtins.substring 1 (builtins.stringLength hex - 1) hex;
  colorsRGB = builtins.mapAttrs (name: value: removeHash value) outputs.colors;

  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # You can import other home-manager modules here
  imports =
    [
      inputs.ags.homeManagerModules.default
      # ../cachix.nix
      inputs.matugen.nixosModules.default
      inputs.spicetify-nix.homeManagerModules.default

      inputs.nixcord.homeManagerModules.nixcord

      ./firefox.nix
      # ./tmux.nix
      # ./zellij.nix
      (import ./zsh.nix {inherit pkgs lib;})
      (import ./kitty.nix {inherit outputs pkgs lib;})
      # (import ./yazi.nix {inherit pkgs;})
    ]
    ++ lib.optionals isLinux [
      (import ./tofi.nix {inherit config lib outputs pkgs;})
      (import ./modules/anti-sleep-neglector/service.nix {inherit outputs inputs config lib pkgs;})
      (import ./modules/fastfetch/default.nix {inherit outputs;})
    ]
    ++ lib.optionals isDarwin [
      ./stuff/aerospace.nix
    ];

  home.username =
    if isDarwin
    then "samherman1"
    else "hedonicadapter";
  home.homeDirectory =
    if isDarwin
    then "/Users/samherman1"
    else "/home/hedonicadapter";

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
    enable = isLinux;
  };
  services.anti-sleep-neglector-monitor = {
    enable = isLinux;
  };
  services.anti-sleep-neglector-gamma = {
    enable = isLinux;

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
    enable = isLinux;
    wallpapersDir = "${config.home.homeDirectory}/Pictures/wallpapers";
  };

  programs.matugen.enable = true;

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
      init.defaultBranch = "main";
      credential.helper = "${
        pkgs.git.override {withLibsecret = true;}
      }/bin/git-credential-libsecret";

      color.ui = "auto";

      delta = {
        navigate = true;
      };
      merge = {
        conflictstyle = "zdiff3";
      };

      push = {
        autoSetupRemote = true;
      };
    };
    delta .enable = true;
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
      pkgs.libnotify
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
      text = colorsRGB.base0A;
      subtext = colorsRGB.base04;
      sidebar-text = colorsRGB.base05;
      main = colorsRGB.base00;
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

  programs.gh-dash.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.nixcord = {
    enable = true;
    discord = {
      package = pkgs.discord;
      vencord.unstable = true;
    };
    vesktop.enable = true;
    # programs.nixcord.userPlugins
    #     # enable custom user plugins from github
    #     # type: attrsOf (coercedTo (strMatching regex))
    # disable the minimum size for the discord window   #     # regex matches the form "github:user/repo/commitHash"
    quickCss =
      ''
        :root {
          --txt-pad: 5px;
          --bg-0: ${outputs.colors.base00}; /* main background color */
          --bg-1: ${outputs.colors.base01}; /* background color for secondary elements */
          --bg-2: ${outputs.colors.base02}; /* color of neutral buttons */
          --bg-3: ${outputs.colors.base03}; /* color of neutral buttons when hovered */

          --hover: hsla(0, 0%, 40%, 0.1); /* keeping original as it's an opacity value */
          --active: hsla(0, 0%, 40%, 0.2); /* keeping original as it's an opacity value */
          --selected: var(--active);

          --txt-dark: ${outputs.colors.base00};
          --txt-link: ${outputs.colors.base0C};
          --txt-0: ${outputs.colors.base07};
          --txt-1: ${outputs.colors.base05};
          --txt-2: ${outputs.colors.base04};
          --txt-3: ${outputs.colors.base03};

          --acc-0: ${outputs.colors.base0A};
          --acc-1: color-mix(in oklch, ${outputs.colors.base0A}, white 10%);
          --acc-2: color-mix(in oklch, ${outputs.colors.base0A}, black 10%);

          --border-width: 1px;
          --border-color: ${outputs.colors.base03};
          --border-hover-color: ${outputs.colors.base0A};
          --border-transition: 0.2s ease;

          --online-dot: ${outputs.colors.base0B};
          --dnd-dot: ${outputs.colors.base08};
          --idle-dot: ${outputs.colors.base0A};
          --streaming-dot: ${outputs.colors.base0E};

          --mention-txt: ${outputs.colors.base0C};
          --mention-bg: color-mix(in oklch, ${outputs.colors.base0C}, transparent 90%);
          --mention-overlay: color-mix(in oklch, ${outputs.colors.base0C}, transparent 90%);
          --mention-hover-overlay: color-mix(in oklch, ${outputs.colors.base0C}, transparent 95%);
          --reply-overlay: var(--active);
          --reply-hover-overlay: var(--hover);

          --pink: ${outputs.colors.base08};
          --pink-1: color-mix(in oklch, ${outputs.colors.base08}, black 10%);
          --pink-2: color-mix(in oklch, ${outputs.colors.base08}, black 20%);
          --purple: ${outputs.colors.base0E};
          --purple-1: color-mix(in oklch, ${outputs.colors.base0E}, black 10%);
          --purple-2: color-mix(in oklch, ${outputs.colors.base0E}, black 20%);
          --cyan: ${outputs.colors.base0C};
          --yellow: ${outputs.colors.base0A};
          --green: ${outputs.colors.base0B};
          --green-1: color-mix(in oklch, ${outputs.colors.base0B}, black 10%);
          --green-2: color-mix(in oklch, ${outputs.colors.base0B}, black 20%);
        }

        * {
            font-family: 'Mx437 DOS/V re. JPN30'!important;
        }
      ''
      + import ./modules/discord/custom.css.nix {inherit outputs;};
    config = {
      useQuickCss = true;
      themeLinks = [
        "https://refact0r.github.io/system24/theme/system24.theme.css"
      ];
      frameless = true;

      plugins = {
        alwaysAnimate.enable = true;
        alwaysTrust.enable = true;
        betterSettings = {
          enable = true;
          eagerLoad = false;
        };
        betterGifPicker.enable = true;
        betterUploadButton.enable = true;
        clearURLs.enable = true;
        consoleJanitor.enable = true;
        copyFileContents.enable = true;
        experiments.enable = true;
        fakeNitro.enable = true;
        favoriteEmojiFirst.enable = true;
        favoriteGifSearch.enable = true;
        fixSpotifyEmbeds.enable = true;
        fixYoutubeEmbeds.enable = true;
        forceOwnerCrown.enable = true;
        friendsSince.enable = true;
        messageLogger.enable = true;
        moreKaomoji.enable = true;
        noOnboardingDelay.enable = true;
        noRPC.enable = true;
        relationshipNotifier.enable = true;
        reverseImageSearch.enable = true;
        reviewDB.enable = true;
        secretRingToneEnabler.enable = true;
        showHiddenThings.enable = true;
        showMeYourName.enable = true;
        silentTyping.enable = true;
        silentMessageToggle.enable = true;
        spotifyShareCommands.enable = true;
        streamerModeOnStream.enable = true;
        unindent.enable = true;
        voiceChatDoubleClick.enable = true;
        vcNarrator .enable = true;
        volumeBooster.enable = true;
        whoReacted.enable = true;
        youtubeAdblock.enable = true;
        webScreenShareFixes.enable = true;
        imageZoom = {
          enable = true;
          saveZoomValues = false;
        };
      };

      disableMinSize = true;
    };
    extraConfig = {};
  };

  home.packages = with pkgs; let
    # Core packages available on all platforms
    commonPackages = [
      jq
      gh
      socat
      speedread
      streamlink
      twitch-tui
      pipe-viewer
      yt-dlp
    ];

    # Development tools and languages
    devPackages = [
      # Languages
      go
      dart-sass
      sassc
      typescript
      bun
      cargo
      rustc

      # Language servers
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

      # Formatters & linters
      nodePackages.prettier
      prettierd
      alejandra
      stylua
      sqlfluff
    ];

    # Fonts
    fontPackages = [
      nerd-fonts.symbols-only
      maple-mono-NF
      ultimate-oldschool-pc-font-pack
      glasstty-ttf
      material-symbols
    ];

    linuxPackages = [
      # Browsers
      inputs.zen-browser.packages."${system}".beta
      google-chrome
      webcord

      # Media & graphics
      blender
      neovide
      hyprpicker
      (mpv.override {scripts = [mpvScripts.mpris];})

      # System utilities
      dotool
      resources
      ncdu
      alsa-utils
      grim
      slurp
      libGLU
      lazydocker
      rofimoji
      (callPackage ./modules/hints/hints-derivation.nix {})

      # G*ming
      lutris

      #AGS
      inputs.ags.packages.${pkgs.system}.notifd
      inputs.ags.packages.${pkgs.system}.io
      meson
      vala
      gdk-pixbuf
      json-glib
      gobject-introspection
    ];

    darwinPackages = [
      appcleaner
      slack
      autoraise
    ];
  in
    commonPackages
    ++ devPackages
    ++ fontPackages
    ++ lib.optionals isLinux linuxPackages
    ++ lib.optionals isDarwin darwinPackages;

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.default;
    systemd.enable = true;
    systemd.variables = ["--all"];
    extraConfig = import ./modules/hyprland/hyprland.conf.nix {inherit outputs lib;};
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.default
      #  TODO: marked broken
      # pkgs.hyprlandPlugins.hyprfocus
    ];
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
    ".oh-my-zsh/custom/themes" = {
      source = ./modules/oh-my-zsh/themes;
      recursive = true;
    };
    ".config/fastfetch/logo.txt" = {
      source = ./modules/fastfetch/logo.txt;
    };

    ".config/streamlink/config".source = ./modules/streamlink/config;

    ".config/hints/config.json".text = import ./modules/hints/config.json.nix {inherit outputs;};

    "${config.home.homeDirectory}/.zen/wx2n5f38.default/chrome/userChrome.css".text = import ./modules/zen-browser/userChrome.css.nix {inherit outputs;};
    "${config.home.homeDirectory}/.zen/wx2n5f38.default/chrome/userContent.css".text = import ./modules/zen-browser/userContent.css.nix {inherit outputs;};
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = lib.mkIf isLinux "sd-switch"; # Nicely reload system units when changing configs

  fonts.fontconfig.enable = lib.mkIf isLinux true;

  gtk = {
    enable = isLinux;
    # iconTheme.package = pkgs.fluent-icon-theme;
    # iconTheme.name = "Fluent";
    # cursorTheme.package = pkgs.callPackage ./oxygen-neon-cursors.nix {};
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
    XDG_RUNTIME_DIR =
      if pkgs.stdenv.isDarwin
      then "/tmp"
      else "/run/user/$UID";
    # WINIT_X11_SCALE_FACTOR = 0.75;
  };

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11";
}
