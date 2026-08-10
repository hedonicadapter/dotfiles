import Wp from "gi://AstalWp";

export default function () {
  const audio = Wp.get_default()?.audio!;

  return <box vertical></box>;
}

// <For each={createBinding(audio, "speakers")}>
//   {(s) => (
//     <button onClicked={() => s.set_is_default(true)}>
//       <label
//         class={createBinding(s, "isDefault").as((b) => (b ? "active" : ""))}
//         label={s.description || ""}
//       />
//     </button>
//   )}
// </For>
