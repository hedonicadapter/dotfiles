{pkgs, ...}: {
  home.packages = with pkgs; [
    lsd
    bat
  ];

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    shellAliases = {
      "ls" = "lsd -latr";
      "lst" = "lsd --tree";
      "cat" = "bat"; # c*ts are terrible people, this config doesn't condone c*t use
      "grep" = "grep --color=auto";
      "git log" = "git log --all --graph --decorate --oneline --pretty=format:'%C(auto)%h %C(bold blue)%an %C(green)(%ar)%C(reset) %s'";
    };
    zsh-abbr = {
      enable = true;
      abbreviations = {
        "gs" = "git status --short";
        "ga" = "git add ";
        "gap" = "git add --patch";
        "gc" = "git commit ";
        "gp" = "git push";
        "gu" = "git pull";
        "gl" = "git log";
        "gb" = "git branch";
        "gi" = "git init ";
        "gco" = "git checkout ";
        "gcl" = "git clone --recurse-submodules ";
        "gsu" = "git submodule foreach git pull origin main";

        "dcd" = "docker-compose down";
        "dcu" = "docker-compose up";

        "ns" = "nix-shell --run zsh ";
      };
    };
    autosuggestion = {enable = true;};
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
    initExtra = ''
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

      nix-refresh() {
        sudo nixos-rebuild switch --flake "$@" --show-trace --impure && nvd diff /run/current-system result
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

        export XDG_RUNTIME_DIR=/run/user/$(id -u)
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
}
