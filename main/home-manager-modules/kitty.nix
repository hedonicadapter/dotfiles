{
  outputs,
  lib,
  config,
  ...
}: {
  # stylix.targets.kitty.enable = false;
  programs.kitty = {
    enable = true;
    font.size = lib.mkForce 14;
    font.name = lib.mkForce config.stylix.fonts.monospace.name;
    font.package = lib.mkForce config.stylix.fonts.monospace.package;
    shellIntegration.enableZshIntegration = true;
    extraConfig = ''
      map kitty_mod+w
      map kitty_mod+q close_window
      map kitty_mod+H next_window
      map kitty_mod+L previous_window

      modify_font cell_height 180%
      modify_font cell_width 95%

      modify_font underline_position 2px
      modify_font underline_thickness 125%
    '';
    settings = {
      scrollback_indicator_opacity = "0.7";
      mouse_hide_wait = -1;
      focus_follows_mouse = true;
      show_hyperlink_targets = "yes";
      paste_actions = "quote-urls-at-prompt,filter,confirm-if-large";
      confirm_os_window_close = 0;
      strip_trailing_spaces = "always";

      repaint_delay = 6;
      input_delay = 0;
      sync_to_monitor = "yes";

      window_padding_width = "4 10";
      hide_window_decorations = "yes";
      remember_window_size = "no";
      window_border_width = "0.0pt";

      tab_title_template = "{fmt.fg.red}{bell_symbol}{fmt.fg.tab}{index}{title}{activity_symbol}";
      macos_show_window_title_in = "menubar";

      update_check_interval = 0; #disable
      notify_on_cmd_finish = "unfocused";
      linux_display_server = "wayland";
      wayland_enable_ime = "no";

      cursor_trail = 1;
      cursor_trail_decay = "0.1 0.4";
    };
    # darwinLaunchOptions = ["--single-instance"];
  };
}
