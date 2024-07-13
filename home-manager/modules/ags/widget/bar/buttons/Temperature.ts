import { temperature } from "lib/variables";
import PanelButton from "../PanelButton";

export default () =>
  PanelButton({
    child: Widget.Label({
      class_name: temperature.bind().as((t) => {
        switch (true) {
          case t < 40:
            return "val-low";
          case t < 70:
            return "val-mid";
          case t >= 70:
            return "val-high";
        }
      }),
      justification: "center",
      valign: "center",
      label: temperature.bind().as((t) => `${t}󰔄`),
    }),
  });
