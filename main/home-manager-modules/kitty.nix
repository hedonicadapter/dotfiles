{
  outputs,
  lib,
  ...
}: {
  # stylix.targets.kitty.enable = false;
  programs.kitty = {
    enable = true;
    font.size = lib.mkForce 14;
    shellIntegration.enableZshIntegration = true;
    extraConfig = ''
      map kitty_mod+w
      map kitty_mod+q close_window
      map kitty_mod+H next_window
      map kitty_mod+L previous_window

      modify_font cell_height 140%
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
      input_delay = 0;
      sync_to_monitor = "yes";
      inactive_text_alpha = "0.4";
      window_padding_width = "4 10";
      hide_window_decorations = "yes";
      remember_window_size = "no";
      window_border_width = "0.8pt";

      tab_title_template = "{fmt.fg.red}{bell_symbol}{fmt.fg.tab}{index}{title}{activity_symbol}";
      tab_activity_symbol = "";

      update_check_interval = 0; #disable
      notify_on_cmd_finish = "unfocused";
      linux_display_server = "wayland";
      wayland_enable_ime = "no";

      cursor_trail = 1;
      cursor_trail_decay = "0.1 0.4";
    };
  };
}
