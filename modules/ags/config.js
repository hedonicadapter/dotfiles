const hyprland = await Service.import('hyprland');
const notifications = await Service.import('notifications');
const audio = await Service.import('audio');
const network = await Service.import('network')
const systemtray = await Service.import('systemtray');
import { NotificationPopups } from './Notification.js';
import { AppLauncher } from './AppLauncher.js';
import { Dock } from './Dock.js';

const date = Variable('', {
  poll: [1000, 'date "+%H:%M:%S %b %e"'],
});

function Workspaces() {
  const activeId = hyprland.active.workspace.bind('id');
  const workspaces = hyprland.bind('workspaces').as((ws) =>
    ws.map(({ id }) =>
      Widget.Button({
        on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
        child: Widget.Label(`${id}`),
        class_name: activeId.as(
          (i) => `${i === id ? 'focused' : ''} workspace`
        ),
      })
    )
  );

  return Widget.Box({
    class_name: 'workspaces box',
    children: workspaces,
  });
}

function ClientTitle() {
  return Widget.Label({
    class_name: 'client-title ',
    label: hyprland.active.client.bind('title'),
    setup: (list) =>
      list.hook(
        hyprland,
        (list) => {
          const titleExists = hyprland.active.client.title !== '';
          if (!titleExists) list.hide();
          else list.show();
        },
        'changed'
      ),
  });
}

function Clock() {
  return Widget.Label({
    class_name: 'clock box',
    label: date.bind(),
  });
}


const WifiIndicator = () => Widget.Box({
    children: [
        Widget.Icon({
            icon: network.wifi.bind('icon_name'),
        }),
        Widget.Label({
            label: network.wifi.bind('ssid')
                .as(ssid => ssid || 'Unknown'),
        }),
    ],
})

const WiredIndicator = () => Widget.Icon({
    icon: network.wired.bind('icon_name'),
})

const NetworkIndicator = () => Widget.Stack({
    children: {
        wifi: WifiIndicator(),
        wired: WiredIndicator(),
    },
    shown: network.bind('primary').as(p => p || 'wifi'),
})

function SysTray() {
  const items = systemtray.bind('items').as((items) =>
    items.map(
      (item) =>
        item &&
        Widget.Button({
          child: Widget.Icon({ icon: item.bind('icon') }),
          on_primary_click: (_, event) => item.activate(event),
          on_secondary_click: (_, event) => item.openMenu(event),
          tooltip_markup: item.bind('tooltip_markup'),
        })
    )
  );

  return Widget.Box({
    class_name: 'systray box',
    children: items,
    setup: (list) =>
      list.hook(
        systemtray,
        (list) => {
          const systrayPopulated = systemtray.items.length > 0;
          if (!systrayPopulated) list.hide();
          else list.show();
        },
        'changed'
      ),
  });
}

function Bar(monitor = 0) {
  function Left() {
    return Widget.Box({
      spacing: 8,
      children: [Workspaces()],
    });
  }

  function Center() {
    return Widget.Box({
      spacing: 8,
      children: [ClientTitle()],
    });
  }

  function Right() {
    return Widget.Box({
      hpack: 'end',
      spacing: 8,
      children: [SysTray(),NetworkIndicator(), Clock()],
    });
  }

  return Widget.Window({
    name: `bar-${monitor}`, // name has to be unique
    class_name: 'bar',
    monitor,
    anchor: ['top', 'right', 'left'],
    exclusivity: 'exclusive',
    margins: [8, 14, -2, 14],
    child: Widget.CenterBox({
      spacing: 8,
      start_widget: Left(),
      center_widget: Center(),
      end_widget: Right(),
    }),
  });
}

App.config({
  style: `${App.configDir}/style.css`,
  gtkTheme: 'Orchis-Green-Dark-Compact',
  iconTheme: 'Fluent',

  windows: [Bar(),
    //Dock(), 
    NotificationPopups(), AppLauncher],
});

export {};
