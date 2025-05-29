{
  inputs,
  outputs,
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  removeHash = hex: builtins.substring 1 (builtins.stringLength hex - 1) hex;
  colorsRGB = builtins.mapAttrs (name: value: removeHash value) outputs.palette;
in {
  programs.home-manager.enable = true;

  # You can import other home-manager modules here
  imports = [
    inputs.spicetify-nix.homeManagerModules.default

    inputs.nixcord.homeManagerModules.nixcord

    (import ../home-manager-modules/zsh.nix {inherit pkgs lib;})
    (import ../home-manager-modules/kitty.nix {inherit outputs pkgs lib;})
    ../home-manager-modules/aerospace.nix
  ];

  home.username = "samherman1";
  home.homeDirectory = "/Users/samherman1";

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
    userName = "samherman";
    userEmail = "sam.herman@xenit.se";
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

  programs.gpg.enable = true;
  services.gpg-agent.enable = true;

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
          --bg-0: ${outputs.palette.base00}; /* main background color */
          --bg-1: ${outputs.palette.base01}; /* background color for secondary elements */
          --bg-2: ${outputs.palette.base02}; /* color of neutral buttons */
          --bg-3: ${outputs.palette.base03}; /* color of neutral buttons when hovered */

          --hover: hsla(0, 0%, 40%, 0.1); /* keeping original as it's an opacity value */
          --active: hsla(0, 0%, 40%, 0.2); /* keeping original as it's an opacity value */
          --selected: var(--active);

          --txt-dark: ${outputs.palette.base00};
          --txt-link: ${outputs.palette.base0C};
          --txt-0: ${outputs.palette.base07};
          --txt-1: ${outputs.palette.base05};
          --txt-2: ${outputs.palette.base04};
          --txt-3: ${outputs.palette.base03};

          --acc-0: ${outputs.palette.base0A};
          --acc-1: color-mix(in oklch, ${outputs.palette.base0A}, white 10%);
          --acc-2: color-mix(in oklch, ${outputs.palette.base0A}, black 10%);

          --border-width: 1px;
          --border-color: ${outputs.palette.base03};
          --border-hover-color: ${outputs.palette.base0A};
          --border-transition: 0.2s ease;

          --online-dot: ${outputs.palette.base0B};
          --dnd-dot: ${outputs.palette.base08};
          --idle-dot: ${outputs.palette.base0A};
          --streaming-dot: ${outputs.palette.base0E};

          --mention-txt: ${outputs.palette.base0C};
          --mention-bg: color-mix(in oklch, ${outputs.palette.base0C}, transparent 90%);
          --mention-overlay: color-mix(in oklch, ${outputs.palette.base0C}, transparent 90%);
          --mention-hover-overlay: color-mix(in oklch, ${outputs.palette.base0C}, transparent 95%);
          --reply-overlay: var(--active);
          --reply-hover-overlay: var(--hover);

          --pink: ${outputs.palette.base08};
          --pink-1: color-mix(in oklch, ${outputs.palette.base08}, black 10%);
          --pink-2: color-mix(in oklch, ${outputs.palette.base08}, black 20%);
          --purple: ${outputs.palette.base0E};
          --purple-1: color-mix(in oklch, ${outputs.palette.base0E}, black 10%);
          --purple-2: color-mix(in oklch, ${outputs.palette.base0E}, black 20%);
          --cyan: ${outputs.palette.base0C};
          --yellow: ${outputs.palette.base0A};
          --green: ${outputs.palette.base0B};
          --green-1: color-mix(in oklch, ${outputs.palette.base0B}, black 10%);
          --green-2: color-mix(in oklch, ${outputs.palette.base0B}, black 20%);
        }

        * {
            font-family: 'Mx437 DOS/V re. JPN30'!important;
        }
      ''
      + import ../home-manager-modules/discord/custom.css.nix {inherit outputs;};
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

  home.packages = with pkgs;
    [
      # inputs.zen-browser.packages."${system}".beta
      webcord
      streamlink
      twitch-tui

      ncdu
      jq
      gh

      appcleaner
      zoxide
      raycast
      slack
      autoraise
    ]
    # Languages
    ++ []
    # Language servers
    ++ []
    # Formatters & linters
    ++ []
    # Fonts
    ++ [
      nerd-fonts.symbols-only
      maple-mono-NF
      # cartograph-cf DMCA'd
      ultimate-oldschool-pc-font-pack
      glasstty-ttf
      material-symbols
    ];

  home.file = {
    ".config/BetterDiscord" = {
      source = ../home-manager-modules/discord;
      recursive = true;
    };
    ".oh-my-zsh/custom/themes" = {
      source = ../home-manager-modules/oh-my-zsh/themes;
      recursive = true;
    };

    ".config/streamlink/config".source = ../home-manager-modules/streamlink/config;
  };

  home.sessionVariables = {
    ZSH_CUSTOM = "${config.home.homeDirectory}/.oh-my-zsh/custom";

    TERMINAL = "kitty";
  };

  home.stateVersion = "24.11";
}
