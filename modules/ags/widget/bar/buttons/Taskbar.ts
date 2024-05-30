import { launchApp, icon } from "lib/utils";
import icons from "lib/icons";
import options from "options";
import PanelButton from "../PanelButton";

const hyprland = await Service.import("hyprland");
const apps = await Service.import("applications");
const { monochrome, exclusive, iconSize } = options.bar.taskbar;
const { position } = options.bar;

export default () =>
  Widget.Box({
    class_name: "taskbar",
  });
