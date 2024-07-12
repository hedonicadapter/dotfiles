{pkgs, ...}: let
  tmuxResurrectPath = "~/.config/tmux/resurrect/";
in {
  programs.tmux = {
    enable = true;
    clock24 = true;
    baseIndex = 1;
    keyMode = "vi";
    prefix = "C-Space";
    terminal = "screen-256color";

    extraConfig = ''
      set-option -g status-style bg=default



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
