import icons from "lib/icons"
import PanelButton from "../PanelButton"
import options from "options"


export default () => PanelButton({
    window: "powermenu",
    child: Widget.Icon(icons.powermenu.shutdown),
    setup: self => self.hook(monochrome, () => {
        self.toggleClassName("colored", !monochrome.value)
        self.toggleClassName("box")
    }),
})

const progress = Widget.CircularProgress({
  css:
    "min-width: 50px;" + // its size is min(min-height, min-width)
    "min-height: 50px;" +
    "font-size: 6px;" + // to set its thickness set font-size on it
    "margin: 4px;" + // you can set margin on it
  rounded: false,
  inverted: false,
  startAt: 0.75,
  value: battery.bind("percent").as((p) => p / 100),
  child: Widget.Icon({
    icon: battery.bind("icon-name"),
  }),
});
