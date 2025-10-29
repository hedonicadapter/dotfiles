{...}: let
  barikConfig = ''
    # yabai.path = "/run/current-system/sw/bin/yabai"
    aerospace.path = "/etc/profiles/per-user/samherman1/bin/aerospace"

    theme = "system" # system, light, dark

    [widgets]
    displayed = [ # widgets on menu bar
        "default.spaces",
        "spacer",
        "default.network",
        "default.battery",
        "divider",
        # { "default.time" = { time-zone = "America/Los_Angeles", format = "E d, hh:mm" } },
        "default.time"
    ]

    [widgets.default.spaces]
    space.show-key = true        # show space number (or character, if you use AeroSpace)
    window.show-title = true
    window.title.max-length = 50

    [widgets.default.battery]
    show-percentage = true
    warning-level = 30
    critical-level = 10

    [widgets.default.time]
    format = "E d, J:mm"
    calendar.format = "J:mm"

    calendar.show-events = true
    # calendar.allow-list = ["Home", "Personal"] # show only these calendars
    # calendar.deny-list = ["Work", "Boss"] # show all calendars except these

    [popup.default.time]
    view-variant = "box"

    [background]
    enabled = true
  '';
in {
  home.file.".barik-config.toml".text = barikConfig;
}
