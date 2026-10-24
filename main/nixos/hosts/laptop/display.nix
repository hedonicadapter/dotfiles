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

  # Xenit office
  "DP-1" = {};
  "DP-3".position = {
    x = 2560;
    y = -1440;
  };
  "DP-4".position = {
    x = 5120;
    y = -1440;
  };
}
