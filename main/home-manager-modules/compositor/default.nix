# Compositor-agnostic session data, rendered by niri/config.kdl.nix and
# hyprland/hyprland.lua.nix. Fills in defaults so renderers needn't.
{
  lib,
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

  launcherBinds = map (bind:
    {
      mods = ["Mod"];
      locked = false;
    }
    // bind)
  (import ./launcher-binds.nix);
}
