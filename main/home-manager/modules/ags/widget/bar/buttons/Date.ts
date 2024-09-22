import { clock } from "lib/variables";
import PanelButton from "../PanelButton";
import options from "options";

const { format: formatDate, action: actionDate } = options.bar.date;
const { format: formatClock, action: actionClock } = options.bar.clock;
const date = Utils.derive([clock, formatDate], (c, f) => c.format(f) || "");
const time = Utils.derive([clock, formatClock], (c, f) => c.format(f) || "");

function toSubscript(number) {
  const subscriptMap = {
    "0": "\u2080",
    "1": "\u2081",
    "2": "\u2082",
    "3": "\u2083",
    "4": "\u2084",
    "5": "\u2085",
    "6": "\u2086",
    "7": "\u2087",
    "8": "\u2088",
    "9": "\u2089",
  };

  return number
    .toString()
    .split("")
    .map((digit) => subscriptMap[digit] || digit)
    .join("");
}

export default () =>
  PanelButton({
    window: "datemenu",
    on_clicked: actionDate.bind(),
    children: [
      Widget.Label({
        class_name: "datelabel",
        justification: "center",
        label: date.bind().as((t) => t?.toUpperCase()),
      }),
      Widget.Label({
        class_name: "clocklabel",
        justification: "center",
        label: time.bind().as((t) => {
          const lastTwo = t.substring(t.length - 2, t.length);
          const subscript = toSubscript(lastTwo);
          return t.substring(0, t.length - 2) + subscript;
        }),
      }),
    ],
  });
