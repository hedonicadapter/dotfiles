{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    bat
  ];

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    shellAliases = {
      "cat" = "bat"; # c*ts are terrible people, this config doesn't condone c*t use
      "grep" = "grep --color=auto";

      "git log" = "git log --all --graph --decorate --oneline --pretty=format:'%C(auto)%h %C(bold blue)%an %C(green)(%ar)%C(reset) %s'";

      "debug-flake" = "nix --extra-experimental-features repl-flake repl";
    };
    zsh-abbr = {
      enable = true;
      abbreviations = {
        "ls" = "eza -s=modified -la";

        "gs" = "git status --short";
        "ga" = "git add";
        "gr" = "git reset";
        "gap" = "git add --patch";
        "gc" = "git commit";
        "gd" = "git diff";
        "gp" = "git push";
        "gu" = "git pull";
        "gl" = "git log";
        "gb" = "git branch";
        "gi" = "git init";
        "gco" = "git checkout";
        "gcl" = "git clone --recurse-submodules";
        "gsu" = "git submodule foreach git pull origin main";

        "dcd" = "docker-compose down";
        "dcu" = "docker-compose up";

        "kc" = "kubectl";

        "ns" = "nix-shell --run zsh";
        "nr" =
          if pkgs.stdenv.isDarwin
          then "sudo nh darwin switch .#default"
          else "sudo nh os switch .#default";
        "df" = "debug-flake";
        "nu" = "sudo nix flake update";
      };
    };
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = ["main" "brackets" "pattern" "regexp" "cursor" "root" "line"];
    };
    historySubstringSearch = {
      enable = true;
      searchDownKey = "^n";
      searchUpKey = "^p";
    };
    enableCompletion = true;
    initContent = lib.mkOrder 1000 ''
      # Load fzf-tab after `compinit`, but before plugins that wrap widgets
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.zsh
      function git() {
          if [[ "$1" == "clone" ]]; then
              command git "$@"
              local repo_name="''${@: -1}"
              repo_name="''${repo_name##*/}"
              repo_name="''${repo_name%.git}"
              cd "$repo_name"
          else
              command git "$@"
          fi
      }

      cheat() {
          curl "cheat.sh/$*"
      }
    '';
    plugins = with pkgs; [
      {
        name = "fzf-tab";
        src = zsh-fzf-tab;
        file = "fzf-tab.zsh";
      }
    ];

    oh-my-zsh = {
      enable = true;
      extraConfig = ''
        eval "$(zoxide init zsh)"
        eval "$(direnv hook zsh)"

        setopt HIST_EXPIRE_DUPS_FIRST
        setopt HIST_IGNORE_DUPS
        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_IGNORE_SPACE
        setopt HIST_FIND_NO_DUPS
        setopt HIST_SAVE_NO_DUPS
      '';
      theme = "headline/headline";
    };
  };

  home.file.".hushlogin" = {
    enable = pkgs.stdenv.isDarwin;
    text = "";
  };
}
