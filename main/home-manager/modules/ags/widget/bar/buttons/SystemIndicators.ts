import PanelButton from "../PanelButton";
import icons from "lib/icons";
import { zenable } from "lib/variables";

import asusctl from "service/asusctl";
import brightness from "service/brightness";
const notifications = await Service.import("notifications");
const bluetooth = await Service.import("bluetooth");
const audio = await Service.import("audio");
const network = await Service.import("network");
const powerprof = await Service.import("powerprofiles");

const ProfileIndicator = () => {
  const visible = asusctl.available
    ? asusctl.bind("profile").as((p) => p !== "Balanced")
    : powerprof.bind("active_profile").as((p) => p !== "balanced");

  const icon = asusctl.available
    ? asusctl.bind("profile").as((p) => icons.asusctl.profile[p])
    : powerprof.bind("active_profile").as((p) => icons.powerprofile[p]);

  return Widget.Icon({
    class_name: "sys-icon",
    visible,
    icon,
  });
};

const ZenIndicator = () =>
  Widget.Label({
    label: zenable.bind().as((bool) => {
      console.log("ZenIndicator update:", bool);
      return bool ? "val-high" : "val-low";
    }),
  });

const ModeIndicator = () => {
  if (!asusctl.available) {
    return Widget.Icon({
      class_name: "sys-icon",
      setup(self) {
        Utils.idle(() => (self.visible = false));
      },
    });
  }

  return Widget.Icon({
    class_name: "sys-icon",
    visible: asusctl.bind("mode").as((m) => m !== "Hybrid"),
    icon: asusctl.bind("mode").as((m) => icons.asusctl.mode[m]),
  });
};

const MicrophoneIndicator = () =>
  Widget.Icon({
    class_name: "sys-icon",
  }).hook(audio.microphone, (self) => {
    const vol = audio.microphone.is_muted ? 0 : audio.microphone.volume;
    const { muted, low, medium, high } = icons.audio.mic;
    const cons = [
      [67, high],
      [34, medium],
      [1, low],
      [0, muted],
    ] as const;
    self.icon = cons.find(([n]) => n <= vol * 100)?.[1] || "";
  });

const DNDIndicator = () =>
  Widget.Icon({
    class_name: "sys-icon",
    visible: notifications.bind("dnd"),
    icon: icons.notifications.silent,
  });

const BluetoothIndicator = () =>
  Widget.Overlay({
    class_name: "bluetooth",
    passThrough: true,
    visible: bluetooth.bind("enabled"),
    child: Widget.Icon({
      class_name: "sys-icon",
      icon: icons.bluetooth.enabled,
    }),
    overlay: Widget.Label({
      hpack: "end",
      vpack: "start",
      label: bluetooth.bind("connected_devices").as((c) => `${c.length}`),
      visible: bluetooth.bind("connected_devices").as((c) => c.length > 0),
    }),
  });

const NetworkIndicator = () =>
  Widget.Icon({
    class_name: "sys-icon",
  }).hook(network, (self) => {
    const icon = network[network.primary || "wifi"]?.icon_name;
    self.icon = icon || "";
    self.visible = !!icon;
  });

const VolumeIndicator = () =>
  Widget.Icon({
    class_name: Utils.merge(
      [audio["speaker"].bind("volume"), audio["speaker"].bind("is_muted")],
      (vol, m) => {
        let className = m ? "sys-icon muted " : "sys-icon ";
        if (vol < 0.34) className += "val-low";
        else if (vol < 0.67) className += "val-mid";
        else className += "val-high";

        return className;
      },
    ),
  }).hook(audio.speaker, (self) => {
    const vol = audio.speaker.is_muted ? 0 : audio.speaker.volume;
    const { muted, low, medium, high, overamplified } = icons.audio.volume;
    const cons = [
      [101, overamplified],
      [67, high],
      [34, medium],
      [1, low],
      [0, muted],
    ] as const;
    self.icon = cons.find(([n]) => n <= vol * 100)?.[1] || "";
  });

const BrightnessIndicator = () =>
  Widget.CircularProgress({
    class_name: brightness.bind().as((screen, m) => {
      let className = "sys-icon ";
      if (screen < 0.34) className += "val-low";
      else if (screen < 0.67) className += "val-mid";
      else className += "val-high";

      return className;
    }),

    css:
      "min-width: 9px;" + // its size is min(min-height, min-width)
      "min-height: 9px;" +
      "font-size: 1px;", // to set its thickness set font-size on it
    rounded: false,
    inverted: false,
    value: brightness.bind("screen"),
  });

export default () =>
  PanelButton({
    window: "quicksettings",
    on_clicked: () => App.toggleWindow("quicksettings"),
    on_scroll_up: () => (audio.speaker.volume += 0.02),
    on_scroll_down: () => (audio.speaker.volume -= 0.02),
    children: [
      Widget.Box({
        spacing: 4,
        children: [
          // ProfileIndicator(),
          ZenIndicator(),
          ModeIndicator(),
          DNDIndicator(),
          BluetoothIndicator(),
          NetworkIndicator(),
          BrightnessIndicator(),
          VolumeIndicator(),
          MicrophoneIndicator(),
        ],
      }),
    ],
  });
