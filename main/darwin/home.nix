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
    (import ../home-manager-modules/kitty.nix {inherit outputs pkgs lib;})
    ../home-manager-modules/atuin.nix
    ../home-manager-modules/fzf.nix
    ../home-manager-modules/direnv.nix

    ../home-manager-modules/aerospace.nix
    (import ../home-manager-modules/git.nix {
      userName = "samherman";
      userEmail = "sam.herman@xenit.se";
      inherit pkgs;
    })

    (import ../home-manager-modules/spicetify.nix {inherit inputs outputs pkgs;})
    (import ../home-manager-modules/nixcord.nix {inherit outputs pkgs lib;})
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
