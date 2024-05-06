import { MediaMini } from './MediaMini.js';
const { query } = await Service.import('applications');

/** @param {import('resource:///com/github/Aylur/ags/service/applications.js').Application} app */
const AppItem = (app) =>
  Widget.Button({
    on_clicked: () => {
      App.closeWindow('dock');
      app.launch();
    },
    attribute: { app },
    child: Widget.Box({
      vertical: true,
      class_name: 'app-item',
      children: [
        Widget.Icon({
          class_name: 'app-icon',
          icon: app.icon_name || '',
        }),
      ],
    }),
  });

export function Dock(monitor = 0) {
  let applications = query('').map(AppItem).slice(0, 8);

  const list = Widget.Box({
    children: applications
  });

  const eventbox = Widget.EventBox({
    class_name: 'dock-box',
    hpack: 'center',
    child: list,
  });

  eventbox.connect('enter-notify-event', () => {
    eventbox.toggleClassName('dock-hidden', false);
  });

  eventbox.connect('leave-notify-event', () => {
    eventbox.toggleClassName('dock-hidden', true);
  });

  return Widget.Window({
    name: `dock-${monitor}`,
    class_name: 'dock',
    monitor,
    anchor: ['bottom'],
    exclusivity: 'normal',
    layer: 'top',
    sensitive: true,
    margins: [8, 14, 4, 14],

    child: Widget.Box({children:[MediaMini(), eventbox]}),
  });
}
