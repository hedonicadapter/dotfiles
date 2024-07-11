{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      default_shell = "zsh";
      copy_command = "wl-copy";
      ui = {
        pane_frames = {
          rounded_corners = true;
        };
      };
      pane_viewport_serialization = true;
      scrollback_lines_to_serialize = 0; # means all
    };
  };
}
