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
    # Directional focus has nowhere to go
    edge = play "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/audio-volume-change.oga";
    windowClose = play "${pkgs.kdePackages.oxygen-sounds}/share/sounds/oxygen/stereo/window-close.ogg";
  };

  launcherBinds = map (bind:
    {
      mods = ["Mod"];
      locked = false;
    }
    // bind)
  (import ./launcher-binds.nix);
}
