# Speed-read the primary (mouse) selection, in whatever terminal invokes it.
# dotool taps speedread's `]` a few times on start to bump the WPM up;
# it needs the xkb layout to find that key, hence xkbLayout.
{
  lib,
  writeShellApplication,
  coreutils,
  wl-clipboard,
  speedread,
  dotool,
  xkbLayout ? "us",
}:
writeShellApplication {
  name = "speed-read";

  runtimeInputs = [coreutils wl-clipboard speedread dotool];

  text = ''
    wpm="''${1:-150}"
    export DOTOOL_XKB_LAYOUT="''${DOTOOL_XKB_LAYOUT:-${xkbLayout}}"

    (
      for i in 1 2 3 4; do
        sleep "0.$i"
        echo key rightbrace | dotool
        echo key rightbrace | dotool
      done
    ) &

    wl-paste --no-newline --primary | speedread -w "$wpm" || true
    read -r -p 'Press [Enter] to close...' || true
  '';

  meta = {
    description = "Speed-read the primary selection in a terminal";
    mainProgram = "speed-read";
    platforms = lib.platforms.linux;
  };
}
