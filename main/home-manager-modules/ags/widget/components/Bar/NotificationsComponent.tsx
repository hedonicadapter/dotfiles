import Gtk from "gi://Gtk?version=3.0";
import Notifd, { type Notification } from "gi://AstalNotifd";
import NotificationComponent from "../NotificationComponent";
import {
  createComputed,
  createState,
  For,
  type Accessor,
  type Setter,
} from "ags";

const TIMEOUT_DELAY = 5000;
const BLACKLIST = ["Spotify"];

// Keeps notification widgets in a Map keyed by id so replacements can destroy
// the previous widget, while exposing the values as a reactive array
class NotificationMap {
  private map: Map<number, Gtk.Widget> = new Map();

  readonly list: Accessor<Array<Gtk.Widget>>;
  private setList: Setter<Array<Gtk.Widget>>;

  private latestNotification: Accessor<[Notification | null, number]>;
  private setLatestNotification: Setter<[Notification | null, number]>;

  // notify subscribers to rerender when state changes
  private notifiy() {
    this.setList([...this.map.values()].reverse());
  }

  constructor(hovered: Accessor<boolean>) {
    [this.list, this.setList] = createState<Array<Gtk.Widget>>([]);
    [this.latestNotification, this.setLatestNotification] = createState<
      [Notification | null, number]
    >([null, 0]);

    const notifd = Notifd.get_default();
    notifd.connect("notified", (_, id) => {
      const notification = notifd.get_notification(id)!;
      const name = notification.appName;
      if (BLACKLIST.includes(name)) return;
      const all = notifd.get_notifications();

      all.forEach((n: Notification) => {
        const time = n.get_time();

        if (this.latestNotification.peek()[1] < time) {
          this.setLatestNotification([n, time]);
        }
      });

      const visible = createComputed(
        [this.latestNotification, hovered],
        (l: [Notification | null, number], h) => h || id === l[0]?.get_id(),
      );

      this.set(
        id,
        NotificationComponent({
          notification,
          hovered,
          visible,
        }),
      );
    });

    notifd.connect("resolved", (_, id) => {
      this.delete(id);
    });
  }

  private set(key: number, value: Gtk.Widget) {
    this.map.get(key)?.destroy(); // in case of replacecment destroy previous widget
    this.map.set(key, value);
    this.notifiy();
  }

  private delete(key: number) {
    this.map.get(key)?.destroy();
    this.map.delete(key);
    this.notifiy();
  }
}

export default function NotificationsComponent() {
  const [hovered, setHovered] = createState(false);
  const notifs = new NotificationMap(hovered);

  return (
    <eventbox
      class="bar-item notifications"
      onHover={() => setHovered(true)}
      onHoverLost={() => setHovered(false)}
    >
      <box vertical class="panel ">
        <For each={notifs.list}>{(widget) => widget}</For>
      </box>
    </eventbox>
  );
}
