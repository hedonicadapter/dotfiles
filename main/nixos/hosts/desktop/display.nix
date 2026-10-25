# Outputs for niri and Hyprland; see home-manager-modules/compositor
{
  # Hisense M2 Pro projector
  "HDMI-A-1" = {
    mode = "1920x1080@240";
    scale = 1;
    # HDMI VRR is unfinished in amdgpu until kernel 7.4; with FRL forced on it blanks the link
    vrr = false;
    focusAtStartup = true;
  };
}
