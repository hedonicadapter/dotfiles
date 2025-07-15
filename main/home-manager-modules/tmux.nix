{
  pkgs,
  lib,
  ...
}: {
  programs.zsh.zsh-abbr.abbreviations = {
    "tm" = ''tmux new-session -A -s $(basename "$PWD")'';
  };
  # stylix.targets.tmux.enable = lib.mkForce false;
  programs.tmux = {
    enable = true;
    clock24 = true;
    baseIndex = 1;
    keyMode = "vi";
    prefix = "C-Space";
    terminal = "tmux-256color";

    extraConfig = ''
      set-option -ga terminal-overrides ",xterm-256color:Tc"
      set-option -a terminal-features 'kitty:RGB'
      set-option -g focus-events on

      set-option -g status-style bg=default
      set-window-option -g window-status-current-format ' #I (~‾⌣‾)> #W '
      set -g status-right ""

      set -g mouse on

      set -gq allow-passthrough on
      set -g visual-activity off

      set -s escape-time 0
      set-option -g allow-rename off

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
          set -g status-left '#{prefix_highlight} '
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          resurrect_dir="$HOME/.tmux/resurrect"
          set -g @resurrect-dir $resurrect_dir
          set -g @resurrect-hook-post-save-all 'target=$(readlink -f $resurrect_dir/last); sed "s| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g; s|/home/$USER/.nix-profile/bin/||g" $target | sponge $target'
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
