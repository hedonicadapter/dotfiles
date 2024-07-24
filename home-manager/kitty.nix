{
  outputs,
  pkgs,
  lib,
  ...
}: let
  removeHash = hex: builtins.substring 1 (builtins.stringLength hex - 1) hex;

  colorsRGB = builtins.mapAttrs (name: value: removeHash value) outputs.colors;
in {
  # stylix.targets.kitty.enable = false;
  programs.kitty = {
    enable = true;
    font.size = lib.mkForce 10;
    shellIntegration.enableZshIntegration = true;
    extraConfig = ''
      map kitty_mod+w
      map kitty_mod+q close_window
      map kitty_mod+H next_window
      map kitty_mod+L previous_window

      modify_font cell_height 135%
      modify_font cell_width 95%
    '';
    settings = {
      scrollback_indicator_opacity = "0.7";
      mouse_hide_wait = 0;
      show_hyperlink_targets = "yes";
      paste_actions = "quote-urls-at-prompt,filter,confirm-if-large";
      confirm_os_window_close = 0;
      strip_trailing_spaces = "always";
      input_delay = 0;
      sync_to_monitor = "yes";
      inactive_text_alpha = "0.4";
      window_padding_width = "6 12";
      hide_window_decorations = "yes";
      remember_window_size = "no";
      window_border_width = "0.8pt";

      # tab_bar_margin_height = "0.0 -10.0";
      # tab_bar_edge = "top";
      tab_title_template = "{fmt.fg.red}{bell_symbol}{fmt.fg.tab}{index}{title}{activity_symbol}";
      tab_activity_symbol = "";
      background_opacity = lib.mkForce "0.7";

      # modify_font cell_height -2px
      # modify_font baseline 3

      update_check_interval = 0; #disable
      notify_on_cmd_finish = "unfocused";
      linux_display_server = "wayland";
      wayland_enable_ime = "no";

      # foreground #dddddd
      # background #000000
      # active_border_color
      # inactive_border_color
      # bell_border_color
      # active_tab_foreground   #000
      # active_tab_background   #eee
      # active_tab_font_style   bold-italic
      # inactive_tab_foreground #444
      # inactive_tab_background #999
      # inactive_tab_font_style normal
    };
  };
}
