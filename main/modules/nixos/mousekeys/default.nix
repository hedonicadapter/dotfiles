{pkgs, ...}: {
  environment.etc = {
    "X11/xkb/symbols/custom_mousekeys".text = ''
      xkb_symbols "basic" {
        key <AC06> { [ h, H, Pointer_Left ] };
        key <AC07> { [ j, J, Pointer_Down ] };
        key <AC08> { [ k, K, Pointer_Up ] };
        key <AC09> { [ l, L, Pointer_Right ] };
      };
    '';

    "xbindkeysrc".text = ''
      "xdotool mousemove_relative -- -10 0"
        Mod4 + Mod1 + h

      "xdotool mousemove_relative 0 10"
        Mod4 + Mod1 + j

      "xdotool mousemove_relative -- 0 -10"
        Mod4 + Mod1 + k

      "xdotool mousemove_relative 10 0"
        Mod4 + Mod1 + l
    '';

    "skel/.config/custom_keymap".text = ''
      xkb_keymap {
        xkb_keycodes  { include "evdev+aliases(qwerty)" };
        xkb_types     { include "complete" };
        xkb_compat    { include "complete" };
        xkb_symbols   { include "pc+us+custom_mousekeys(basic)" };
        xkb_geometry  { include "pc(pc105)" };
      };
    '';
  };

  services.xserver = {
    xkb.options = "custom_mousekeys";
    displayManager.sessionCommands = ''
      ${pkgs.xorg.xkbcomp}/bin/xkbcomp -I${pkgs.xorg.xkeyboardconfig}/share/X11/xkb ~/.config/custom_keymap $DISPLAY
      ${pkgs.xbindkeys}/bin/xbindkeys
    '';
  };

  environment.systemPackages = with pkgs; [
    xdotool
    xbindkeys
    xorg.xkbcomp
  ];
}
