{inputs, ...}: {
  imports = [
    inputs.paneru.homeModules.paneru
  ];

  services.paneru = {
    enable = true;
    settings = {
      options = {
        focus_follows_mouse = true;
        mouse_follows_focus = true;
        preset_column_widths = [0.25 0.33 0.5 0.66 0.75];
      };
      bindings = {
        window_focus_west = "cmd - h";
        window_focus_east = "cmd - l";
        window_resize = "cmd + shift - l";
        quit = "ctrl + alt - q";
      };
    };
  };
}
