import Notifd, { type Notification } from "gi://AstalNotifd";
import NotificationComponent from "../NotificationComponent";
import { createComputed, createState, For } from "ags";

const BLACKLIST = ["Spotify"];

// rev forces a rebuild when a notification is replaced under the same id
type Entry = { id: number; rev: number; notification: Notification };

export default function NotificationsComponent() {
  const notifd = Notifd.get_default();
  const [hovered, setHovered] = createState(false);

  // newest first. <For> builds each child in its own scope, so the reactive
  // props inside NotificationComponent get disposed when it is removed
  const [entries, setEntries] = createState<Entry[]>([]);
  const [latestId, setLatestId] = createState(-1);
  let rev = 0;
  let latestTime = 0;

  notifd?.connect("notified", (_, id) => {
    const notification = notifd.get_notification(id);
    if (!notification || BLACKLIST.includes(notification.appName)) return;

    const time = notification.get_time();
    if (time >= latestTime) {
      latestTime = time;
      setLatestId(id);
    }

    setEntries((prev) => [
      { id, rev: ++rev, notification },
      ...prev.filter((e) => e.id !== id),
    ]);
  });

  notifd?.connect("resolved", (_, id) =>
    setEntries((prev) => prev.filter((e) => e.id !== id)),
  );

  return (
    <eventbox
      class="bar-item notifications"
      onHover={() => setHovered(true)}
      onHoverLost={() => setHovered(false)}
    >
      <box vertical class="panel ">
        <For each={entries} id={(e) => `${e.id}:${e.rev}`}>
          {(entry) => (
            <NotificationComponent
              notification={entry.notification}
              hovered={hovered}
              visible={createComputed(
                [latestId, hovered],
                (latest, isHovered) => isHovered || latest === entry.id,
              )}
            />
          )}
        </For>
      </box>
    </eventbox>
  );
}
