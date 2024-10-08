import { opt, mkOptions } from "lib/option";
import { icon } from "lib/utils";
import icons from "lib/icons";

const colorsJson = Utils.readFile(`${App.configDir}/colors.json`);
const colors = colorsJson ? JSON.parse(colorsJson) : null;

const options = mkOptions(OPTIONS, {
  autotheme: opt(true),

  system: {
    fetchInterval: opt(1000),
    // temperature: opt("/sys/class/thermal/thermal_zone*/temp"),
  },

  wallpaper: {
    resolution: opt<import("service/wallpaper").Resolution>(1920),
    market: opt<import("service/wallpaper").Market>("random"),
  },

  theme: {
    common: colors,
    dark: {
      primary: {
        bg: opt(colors?.beige ?? "#FFEFC2"),
        fg: opt(colors?.black ?? "#141414"),
      },
      error: {
        bg: opt(colors?.red ?? "#d47766"),
        fg: opt(colors?.black ?? "#141414"),
      },
      bg: opt(colors?.grey ?? "#171717"),
      fg: opt(colors?.beige ?? "#FFEFC2"),
      widget: opt(colors?.beige ?? "#FFEFC2"),
      border: opt(colors?.beige ?? "#FFEFC2"),
    },
    light: {
      primary: {
        bg: opt(colors?.blue ?? "#426ede"),
        fg: opt(colors?.white ?? "#eeeeee"),
      },
      error: {
        bg: opt(colors?.red ?? "#d47766"),
        fg: opt(colors?.white ?? "#eeeeee"),
      },
      bg: opt(colors?.beige ?? "#fffffa"),
      fg: opt(colors?.black ?? "#080808"),
      widget: opt(colors?.black ?? "#080808"),
      border: opt(colors?.black ?? "#080808"),
    },

    blur: opt(14),
    scheme: opt<"dark" | "light">("dark"),
    widget: { opacity: opt(94) },
    border: {
      width: opt(1),
      opacity: opt(96),
    },

    shadows: opt(false),
    padding: opt(5),
    spacing: opt(12),
    radius: opt(13),
  },

  transition: opt(150),

  font: {
    size: opt(9),
    name: opt("Public Sans"),
  },

  bar: {
    flatButtons: opt(true),
    position: opt<"top" | "bottom">("top"),
    corners: opt(false),
    transparent: opt(true),
    layout: {
      start: opt<Array<import("widget/bar/Bar").BarWidget>>([
        "workspaces",
        "media",
        "systray",
        "taskbar",
        // "dividerLeft",
      ]),
      center: opt<Array<import("widget/bar/Bar").BarWidget>>([
        // "dividerRight",
        "clienttitle",
        // "dividerLeft",
      ]),
      end: opt<Array<import("widget/bar/Bar").BarWidget>>([
        "expander",
        // "dividerRight",
        "screenrecord",
        "system",
        "battery",
        "temp",
        "date",
        // "powermenu",
      ]),
    },
    clock: {
      format: opt("%H %M %S"),
      action: opt(() => App.toggleWindow("datemenu")),
    },
    date: {
      format: opt("%a %d %b"),
      action: opt(() => App.toggleWindow("datemenu")),
    },
    battery: {
      bar: opt<"hidden" | "regular" | "whole">("regular"),
      charging: opt(colors?.green ?? "#00D787"),
      percentage: opt(true),
      blocks: opt(7),
      width: opt(50),
      low: opt(30),
    },
    workspaces: {
      workspaces: opt(4),
    },
    taskbar: {
      iconSize: opt(0),
      monochrome: opt(false),
      exclusive: opt(false),
    },
    messages: {
      action: opt(() => App.toggleWindow("datemenu")),
    },
    systray: {
      ignore: opt(["KDE Connect Indicator", "spotify-client"]),
    },
    media: {
      monochrome: opt(false),
      preferred: opt("spotify"),
      direction: opt<"left" | "right">("right"),
      format: opt("{artists} - {title}"),
      length: opt(40),
    },
    powermenu: {
      monochrome: opt(false),
      action: opt(() => App.toggleWindow("powermenu")),
    },
  },

  overview: {
    scale: opt(10),
    workspaces: opt(4),
    monochromeIcon: opt(false),
  },

  powermenu: {
    sleep: opt("systemctl suspend"),
    reboot: opt("systemctl reboot"),
    logout: opt("pkill Hyprland"),
    shutdown: opt("shutdown now"),
    layout: opt<"line" | "box">("line"),
    labels: opt(true),
  },

  quicksettings: {
    avatar: {
      image: opt(`/var/lib/AccountsService/icons/${Utils.USER}`),
      size: opt(70),
    },
    width: opt(380),
    position: opt<"left" | "center" | "right">("right"),
    networkSettings: opt("gtk-launch gnome-control-center"),
    media: {
      monochromeIcon: opt(false),
      coverSize: opt(100),
    },
  },

  datemenu: {
    position: opt<"left" | "center" | "right">("right"),
    weather: {
      interval: opt(60_000),
      unit: opt<"metric" | "imperial" | "standard">("metric"),
      key: opt<string>(
        JSON.parse(Utils.readFile(`${App.configDir}/.weather`) || "{}")?.key ||
          "",
      ),
      cities: opt<Array<number>>(
        JSON.parse(Utils.readFile(`${App.configDir}/.weather`) || "{}")
          ?.cities || [],
      ),
    },
  },

  osd: {
    progress: {
      vertical: opt(true),
      pack: {
        h: opt<"start" | "center" | "end">("center"),
        v: opt<"start" | "center" | "end">("end"),
      },
    },
    microphone: {
      pack: {
        h: opt<"start" | "center" | "end">("center"),
        v: opt<"start" | "center" | "end">("end"),
      },
    },
  },

  notifications: {
    position: opt<Array<"top" | "bottom" | "left" | "right">>(["top", "right"]),
    blacklist: opt(["Spotify"]),
    width: opt(440),
  },

  hyprland: {
    gaps: opt(1.175),
    inactiveBorder: opt("#282828"),
    gapsWhenOnly: opt(false),
  },
});

globalThis["options"] = options;
export default options;
