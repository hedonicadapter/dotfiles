import { GLib, Variable, Binding, bind } from "astal";
import { Gtk, Astal } from "astal/gtk3";
import { type EventBox } from "astal/gtk3/widget";
import Notifd from "gi://AstalNotifd";

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

type Props = {
  notification: Notifd.Notification;
  hovered: Variable<boolean>;
  visible: Variable<boolean>;
  setup?: (self: EventBox) => void;
};

export default function NotificationComponent(props: Props) {
  const { notification: n, setup, hovered, visible } = props;
  const { START, CENTER, END } = Gtk.Align;

  return (
    <eventbox visible={bind(visible)} className={`${urgency(n)}`} setup={setup}>
      <box vertical>
        <box className="header">
          <label
            className="app-name"
            halign={START}
            valign={CENTER}
            truncate
            label={(n.appName || "Unknown").toUpperCase() + ":"}
          />
          <label
            className="summary"
            halign={START}
            valign={CENTER}
            xalign={0}
            label={" " + n.summary + " "}
            truncate
          />
          <label
            className="time"
            hexpand
            halign={END}
            valign={CENTER}
            visible={bind(hovered)}
            label={time(n.time) + " "}
          />
          <button
            className="close-button"
            valign={CENTER}
            onClicked={() => n.dismiss()}
            visible={bind(hovered)}
          >
            <icon icon="window-close-symbolic" />
          </button>
        </box>
        <box visible={bind(hovered)} className="content">
          {n.image && fileExists(n.image) && (
            <box
              valign={START}
              className="image"
              css={`
                background-image: url("${n.image}");
              `}
            />
          )}
          {n.image && isIcon(n.image) && (
            <box expand={false} valign={START} className="icon-image">
              <icon icon={n.image} expand halign={CENTER} valign={CENTER} />
            </box>
          )}
          <box vertical>
            {n.body && (
              <label
                className="body"
                wrap
                useMarkup
                halign={START}
                xalign={0}
                justifyFill
                label={n.body}
              />
            )}
            <box className="actions">
              {n.get_actions().length > 0 &&
                n.get_actions().map(({ label, id }) => (
                  <button onClicked={() => n.invoke(id)}>
                    <label label={label} />
                  </button>
                ))}
            </box>
          </box>
        </box>
      </box>
    </eventbox>
  );
}
