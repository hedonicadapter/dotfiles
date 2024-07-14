import { temperature } from "lib/variables";
import PanelButton from "../PanelButton";

export default () =>
  PanelButton({
    child: Widget.Label({
      class_name: temperature.bind().as((t) => {
        let className = "temperature ";
        switch (true) {
          case t < 40:
            className += "val-low";
          case t < 70:
            className += "val-mid";
          case t >= 70:
            className += "val-high";
        }
        return className;
      }),
      justification: "center",
      valign: "center",
      label: temperature.bind().as((t) => `${t}󰔄`),
    }),
  });
