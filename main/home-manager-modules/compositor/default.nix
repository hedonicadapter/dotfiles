# Compositor-agnostic session data, rendered by niri/config.kdl.nix and
# hyprland/hyprland.lua.nix. Fills in defaults so renderers needn't.
{
  lib,
  pkgs,
  # Per-host outputs, from nixos/hosts/<host>/display.nix
  display,
}: {
  # mode/position null: compositor picks (preferred mode, auto placement)
  outputs =
    lib.mapAttrs (_: output:
      {
        mode = null;
        scale = 1;
        position = null;
        vrr = false;
        # niri only
        focusAtStartup = false;
      }
      // output)
    display;

  windowRules = map (rule:
    {
      # "niri" or "hyprland"; null = both
      only = null;
      float = null;
      focus = null;
      center = null;
      stayFocused = null;
      position = null;
      opacity = null;
    }
    // rule
    // {
      match =
        {
          appId = null;
          title = null;
          active = null;
          atStartup = null;
        }
        // rule.match or {};
      exclude = {appId = null;} // rule.exclude or {};
    })
  (import ./window-rules.nix);

  # Shell commands that play feedback sounds
  sounds = let
    play = file: "${pkgs.pipewire}/bin/pw-play --volume=0.5 ${file}";
  in {
    windowClose = play "${pkgs.kdePackages.oxygen-sounds}/share/sounds/oxygen/stereo/window-close.ogg";
  };

  animations = import ./animations.nix;

  # Inset of the AGS bar and frame from the screen edge. Also niri struts and
  # Hyprland outer gaps on the other sides, so windows sit as far inside the
  # frame as they sit below the bar
  screenGap = 20;
  # Above the bar; smaller since the bar adds its own height
  screenGapTop = 6;
  # Between windows, and between windows and the frame
  windowGap = 16;
  # Between the bar and the windows below it (niri: negative top strut)
  barSpacing = 4;
  # Window borders
  borderWidth = 1;

  # Directional focus has nowhere to go; append left/right/top/bottom.
  # Flashes that screen edge (ags/widget/Outline.tsx)
  edgeHitCmd = "ags request edge";

  launcherBinds = map (bind:
    {
      mods = ["Mod"];
      locked = false;
    }
    // bind)
  (import ./launcher-binds.nix);
}
