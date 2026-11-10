# Animation timing shared by niri, Hyprland and AGS.
# curve: cubic-bezier control points [x1 y1 x2 y2], as in CSS; ms: duration.
# Set a role to null to leave each compositor's own default.
let
  easeOut = [0 0 0.58 1];
  easeOutQuart = [0.25 1 0.5 1];
in {
  windowOpen = {
    curve = easeOutQuart;
    ms = 350;
  };
  windowClose = {
    curve = easeOut;
    ms = 50;
  };
  workspaceSwitch = {
    curve = easeOutQuart;
    ms = 350;
  };
  # Hyprland fades and layer surfaces (bar, launcher); niri has no equivalent
  fade = {
    curve = easeOut;
    ms = 50;
  };
  # Edge glow fade-out, ags/widget/Outline.tsx
  edgeFlash = {
    curve = easeOut;
    ms = 220;
  };
}
