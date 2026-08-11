import Gdk from "gi://Gdk?version=3.0";

// stolen from https://stackoverflow.com/a/37770048 by GitaarLAB
export function fmtMSS(s: number) {
  return (s - (s %= 60)) / 60 + (9 < s ? ":" : ":0") + s;
}

// adapted from https://github.com/Aylur/ags/issues/534#issuecomment-2276879113 by Not-a-true-statement
// Connector name (eDP-1, HDMI-A-1) for a monitor — matches niri's output names
export function getMonitorPlugName(monitor: Gdk.Monitor) {
  const display = Gdk.Display.get_default();
  if (!display) return undefined;

  const screen = display.get_default_screen();
  for (let i = 0; i < display.get_n_monitors(); ++i) {
    if (display.get_monitor(i) === monitor)
      return screen.get_monitor_plug_name(i) ?? undefined;
  }
  return undefined;
}

export function escapeShellString(str: string) {
  return str.replace(/'/g, `'\\''`);
}
