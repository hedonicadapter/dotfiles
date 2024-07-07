{
  programs.tmux = {
    enable = true;
    clock24 = true;
    baseIndex = 1;
    keyMode = "vi";
    prefix = "C-Space";
    terminal = "screen-256color";

    extraConfig = ''
      set-option -g status-style bg=default

      run-shell "if [ ! -d ${tmuxResurrectPath} ]; then tmux new-session -d -s init-resurrect; ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh; fi"
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      bind-key -n C-h resize-pane -L
      bind-key -n C-j resize-pane -D
      bind-key -n C-k resize-pane -U
      bind-key -n C-l resize-pane -R

      bind Tab next-window
      bind C-Tab previous-window
    '';
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = prefix-highlight;
        extraConfig = ''
          set -g status-left '#{prefix_highlight}'
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-dir ${tmuxResurrectPath}
          set -g @resurrect-hook-post-save-all 'sed -i -E "s|(pane.nvim\s:)[^;]+;.*\s([^ ]+)$|\1nvim \2|" ${tmuxResurrectPath}/last'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10' 
          set -g @continuum-boot 'on'
        '';
      }
    ];
  };
}
