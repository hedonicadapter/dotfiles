import { Gdk } from "astal/gtk3";

// stolen from https://stackoverflow.com/a/37770048 by GitaarLAB
export function fmtMSS(s: number) {
  return (s - (s %= 60)) / 60 + (9 < s ? ":" : ":0") + s;
}

// stolen from https://github.com/Aylur/ags/issues/534#issuecomment-2276879113 by Not-a-true-statement
export function getGdkMonitorFromName(name: string) {
  const display = Gdk.Display.get_default();
  if (!display) return undefined;

  const screen = display.get_default_screen();
  for (let i = 0; i < display.get_n_monitors(); ++i) {
    if (screen.get_monitor_plug_name(i) === name) {
      return display.get_monitor(i);
    }
  }
  return undefined;
}
export function escapeShellString(str: string) {
  return str.replace(/'/g, `'\\''`);
}
