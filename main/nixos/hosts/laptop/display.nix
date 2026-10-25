# Outputs for niri and Hyprland; see home-manager-modules/compositor
{
  "eDP-1" = {
    mode = "2150x1440@144";
    scale = 1;
    position = {
      x = 0;
      y = 0;
    };
  };

  # External monitor
  "HDMI-A-1" = {
    mode = "2560x1440@119.998";
    scale = 2.0;
    vrr = true;
    focusAtStartup = true;
  };
}
