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
