{
  programs.zellij = {
    enable = true;

    enableZshIntegration = true;
    attachExistingSession = true;
    exitShellOnExit = true;

    settings = {
      copy_command = "wl-copy";
      pane_viewport_serialization = true;
      scrollback_lines_to_serialize = 0; # means all
    };
  };
}
