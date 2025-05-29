import { Gtk } from "astal/gtk3";
import { Variable, bind, type Binding } from "astal";
import Wp, { type Device, type Endpoint, type Stream } from "gi://AstalWp";
import { execAsync } from "astal/process";
import Hoverable from "../Hoverable";

const { START, CENTER } = Gtk.Align;

export default function () {
  const audio = Wp.get_default()?.audio!;

  return <box vertical></box>;
}
// {bind(audio, "speakers").as((ss) =>
//   ss.map((s) => (
//     <button onClick={() => s.set_is_default(true)}>
//       <label
//         className={bind(s, "isDefault").as((b) => (b ? "active" : ""))}
//         label={s.description || ""}
//       />
//     </button>
//   )),
// )}
