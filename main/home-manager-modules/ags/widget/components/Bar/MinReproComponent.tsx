import Gtk from "gi://Gtk?version=3.0";
import Wp, { type Device, type Endpoint, type Stream } from "gi://AstalWp";
import { execAsync } from "ags/process";
import Hoverable from "../Hoverable";

const { START, CENTER } = Gtk.Align;

export default function () {
  const audio = Wp.get_default()?.audio!;

  return <box vertical></box>;
}
// {createBinding(audio, "speakers").as((ss) =>
//   ss.map((s) => (
//     <button onClick={() => s.set_is_default(true)}>
//       <label
//         class={createBinding(s, "isDefault").as((b) => (b ? "active" : ""))}
//         label={s.description || ""}
//       />
//     </button>
//   )),
// )}
