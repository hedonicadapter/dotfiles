import { GLib } from "ags";
import { Gtk, Astal } from "astal/gtk3";
import { type EventBox } from "ags/gtk3/widget";
import Notifd from "gi://AstalNotifd";
import { createBinding, type Accessor } from "ags";

const isIcon = (icon: string) => !!Astal.Icon.lookup_icon(icon);
const fileExists = (path: string) => GLib.file_test(path, GLib.FileTest.EXISTS);

const time = (time: number, format = "%H:%M") =>
  GLib.DateTime.new_from_unix_local(time).format(format)!;

const urgency = (n: Notifd.Notification) => {
  const { LOW, NORMAL, CRITICAL } = Notifd.Urgency;
  switch (n.urgency) {
    case LOW:
      return "low";
    case CRITICAL:
      return "high";
    case NORMAL:
    default:
      return "mid";
  }
};

function escapeHtml(unsafe) {
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

type Props = {
  notification: Notifd.Notification;
  hovered: Accessor<boolean>;
  visible: Accessor<boolean>;
  setup?: (self: EventBox) => void;
};

export default function NotificationComponent(props: Props) {
  const { notification: n, setup, hovered, visible } = props;
  const { START, CENTER, END } = Gtk.Align;

  return (
    <eventbox
      visible={createBinding(visible)}
      class={`${urgency(n)}`}
      $={setup}
    >
      <box vertical>
        <box class="header">
          <label
            class="app-name"
            halign={START}
            valign={CENTER}
            truncate
            label={(n.appName || "Unknown").toUpperCase() + ":"}
          />
          <label
            class="summary"
            halign={START}
            valign={CENTER}
            xalign={0}
            label={" " + n.summary + " "}
            truncate
          />
          <label
            class="time"
            hexpand
            halign={END}
            valign={CENTER}
            visible={createBinding(hovered)}
            label={time(n.time) + " "}
          />
          <button
            class="close-button"
            valign={CENTER}
            onClicked={() => n.dismiss()}
            visible={createBinding(hovered)}
          >
            <icon icon="window-close-symbolic" />
          </button>
        </box>
        <box visible={createBinding(hovered)} class="content">
          {n.image && fileExists(n.image) && (
            <box
              valign={START}
              class="image"
              css={`
                background-image: url("${n.image}");
              `}
            />
          )}
          {n.image && isIcon(n.image) && (
            <box expand={false} valign={START} class="icon-image">
              <icon icon={n.image} expand halign={CENTER} valign={CENTER} />
            </box>
          )}
          <box vertical>
            {n.body && (
              <label
                class="body"
                wrap
                useMarkup
                halign={START}
                xalign={0}
                justifyFill
                label={escapeHtml(n.body)}
              />
            )}
            <box class="actions">
              {n.get_actions().length > 0 &&
                n.get_actions().map((action) => (
                  <button onClicked={() => n.invoke(action.id)}>
                    <label label={action.label} />
                  </button>
                ))}
            </box>
          </box>
        </box>
      </box>
    </eventbox>
  );
}
