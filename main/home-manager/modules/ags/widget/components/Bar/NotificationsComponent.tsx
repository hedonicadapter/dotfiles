import { Gtk } from "astal/gtk3";
import Notifd, { type Notification } from "gi://AstalNotifd";
import NotificationComponent from "../NotificationComponent";
import { type Subscribable } from "astal/binding";
import { Variable, Binding, bind, timeout } from "astal";

const TIMEOUT_DELAY = 5000;
const BLACKLIST = ["Spotify"];

// The purpose if this class is to replace Variable<Array<Widget>>
// with a Map<number, Widget> type in order to track notification widgets
// by their id, while making it conviniently bindable as an array
class NotificationMap implements Subscribable {
  // the underlying map to keep track of id widget pairs
  private map: Map<number, Gtk.Widget> = new Map();

  // it makes sense to use a Variable under the hood and use its
  // reactivity implementation instead of keeping track of subscribers ourselves
  private var: Variable<Array<Gtk.Widget>> = Variable([]);

  private latestNotification: Variable<[Notification | null, number]> =
    Variable([null, 0]);

  // notify subscribers to rerender when state changes
  private notifiy() {
    this.var.set([...this.map.values()].reverse());
  }

  constructor(hovered: Variable<boolean>) {
    const notifd = Notifd.get_default();
    notifd.connect("notified", (_, id) => {
      const notification = notifd.get_notification(id)!;
      const name = notification.appName;
      if (BLACKLIST.includes(name)) return;
      const all = notifd.get_notifications();

      all.forEach((n: Notification) => {
        const time = n.get_time();

        if (this.latestNotification.get()[1] < time) {
          this.latestNotification.set([n, time]);
        }
      });

      const visible = Variable.derive(
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

  get() {
    return this.var.get();
  }

  subscribe(callback: (list: Array<Gtk.Widget>) => void) {
    return this.var.subscribe(callback);
  }
}

export default function NotificationsComponent() {
  const hovered = Variable(false);
  const notifs = new NotificationMap(hovered);

  return (
    <eventbox
      className="bar-item notifications"
      onHover={() => hovered.set(true)}
      onHoverLost={() => hovered.set(false)}
    >
      <box vertical className="panel ">
        {bind(notifs)}
      </box>
    </eventbox>
  );
}
