{
  inputs,
  outputs,
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: {
  programs.home-manager.enable = true;

  # You can import other home-manager modules here
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
    inputs.nixcord.homeModules.nixcord

    (import ../home-manager-modules/tmux.nix {inherit pkgs lib;})
    # ../home-manager-modules/zellij.nix

    (import ../home-manager-modules/zsh.nix {inherit pkgs lib;})
    (import ../home-manager-modules/kitty.nix {inherit outputs pkgs lib config;})

    ../home-manager-modules/atuin.nix
    ../home-manager-modules/fzf.nix
    ../home-manager-modules/direnv.nix
    # ../home-manager-modules/ls-colors.nix
    # ../home-manager-modules/lsd.nix
    ../home-manager-modules/eza.nix

    ../home-manager-modules/aerospace.nix
    (import ../home-manager-modules/git.nix {
      userName = "samherman";
      userEmail = "sam.herman@xenit.se";
      inherit pkgs;
    })

    (import ../home-manager-modules/spicetify.nix {inherit inputs outputs pkgs;})
    (import ../home-manager-modules/nixcord.nix {inherit outputs pkgs lib config;})
    (import ../home-manager-modules/nh.nix {
      flakeDir = "${config.home.homeDirectory}/Documents/projects/dotfiles/main";
    })
  ];

  home.username = "samherman1";
  home.homeDirectory = "/Users/samherman1";

  programs.gpg.enable = true;
  services.gpg-agent.enable = true;

  home.packages = with pkgs;
    [
      # inputs.zen-browser.packages."${system}".beta
      streamlink
      twitch-tui

      ncdu
      jq
      gh
      zoxide

      appcleaner
      raycast
      slack
      autoraise
      google-chrome
      keycastr
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
      maple-mono.NF
      # cartograph-cf DMCA'd
      ultimate-oldschool-pc-font-pack
      glasstty-ttf
      material-symbols
    ];

  nvim = let
    inherit (inputs.neovim-flake) utils;
    basePackage = inputs.neovim-flake.packageDefinitions.nvim or ({...}: {});
  in {
    enable = true;
    packageDefinitions = {
      merge.nvim = utils.mergeCatDefs basePackage ({pkgs, ...}: {
        extra.font = config.stylix.fonts.monospace.name;
        extra.palette = outputs.palette;
        extra.palette_opaque = outputs.paletteOpaque;
        extra.contrast =
          if outputs.isDarkColor outputs.palette.base00
          then 0.6
          else -0.8;

        extra.modeColors = {
          n = outputs.paletteOpaque.base03;
          i = outputs.paletteOpaque.base0F;

          c = outputs.paletteOpaque.base0E;
          C = outputs.paletteOpaque.base0E;

          v = outputs.paletteOpaque.base0C;
          V = outputs.paletteOpaque.base0C;

          r = outputs.paletteOpaque.base0E;
          R = outputs.paletteOpaque.base0E;

          s = outputs.paletteOpaque.base0E;
          S = outputs.paletteOpaque.base0E;

          y = outputs.paletteOpaque.base0D;
        };
      });
    };
  };

  home.file = {
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
