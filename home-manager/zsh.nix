{
  programs.zsh = {
    enable = true;
    shellAliases = {
      "refresh" = ''
        sudo nixos-rebuild switch --flake /etc/nixos#default --show-trace --impure && tmux source ~/.config/tmux/tmux.conf
      '';
    };
    initExtra = "neofetch";
    autosuggestion = {enable = true;};
    syntaxHighlighting = {enable = true;};
    historySubstringSearch = {
      enable = true;
      searchDownKey = "^n";
      searchUpKey = "^p";
    };

    oh-my-zsh = {
      enable = true;
      extraConfig = ''
        eval "$(zoxide init zsh)"
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
