const mpris = await Service.import('mpris');
const players = mpris.bind('players');

const FALLBACK_ICON = 'audio-x-generic-symbolic';
const PLAY_ICON = 'media-playback-start-symbolic';
const PAUSE_ICON = 'media-playback-pause-symbolic';
const PREV_ICON = 'media-skip-backward-symbolic';
const NEXT_ICON = 'media-skip-forward-symbolic';

/** @param {number} length */
function lengthStr(length) {
  const min = Math.floor(length / 60);
  const sec = Math.floor(length % 60);
  const sec0 = sec < 10 ? '0' : '';
  return `${min}:${sec0}${sec}`;
}

/** @param {import('types/service/mpris').MprisPlayer} player */
function Player(player) {
  if (!player.name.includes('spotify')) return;

  const img = Widget.Box({
    class_name: 'img',
    vpack: 'center',
    css: player.bind('cover_path').transform(
      (p) => `
            background-image: url('${p}');
        `
    ),
  });

  const title = Widget.Label({
    class_name: 'title',
    hpack: 'start',
    label: player.bind('track_title'),
  });

  const artist = Widget.Label({
    class_name: 'artist',
    hpack: 'start',
    label: player.bind('track_artists').transform((a) => a.join(', ')),
  });

  const positionSlider = Widget.Slider({
    class_name: 'position',
    draw_value: false,
    on_change: ({ value }) => (player.position = value * player.length),
    visible: player.bind('length').as((l) => l > 0),
    setup: (self) => {
      function update() {
        const value = player.position / player.length;
        self.value = value > 0 ? value : 0;
      }
      self.hook(player, update);
      self.hook(player, update, 'position');
      self.poll(1000, update);
    },
  });

  const positionLabel = Widget.Label({
    class_name: 'position',
    hpack: 'start',
    setup: (self) => {
      const update = (_, time) => {
        self.label = lengthStr(time || player.position);
        self.visible = player.length > 0;
      };

      self.hook(player, update, 'position');
      self.poll(1000, update);
    },
  });

  const lengthLabel = Widget.Label({
    class_name: 'length',
    hpack: 'end',
    visible: player.bind('length').transform((l) => l > 0),
    label: player.bind('length').transform(lengthStr),
  });

  const playPause = Widget.Button({
    class_name: 'play-pause',
    on_clicked: () => player.playPause(),
    visible: player.bind('can_play'),
    child: Widget.Icon({
      icon: player.bind('play_back_status').transform((s) => {
        switch (s) {
          case 'Playing':
            return PAUSE_ICON;
          case 'Paused':
          case 'Stopped':
            return PLAY_ICON;
        }
      }),
    }),
  });

  const prev = Widget.Button({
    on_clicked: () => player.previous(),
    visible: player.bind('can_go_prev'),
    child: Widget.Icon(PREV_ICON),
  });

  const next = Widget.Button({
    on_clicked: () => player.next(),
    visible: player.bind('can_go_next'),
    child: Widget.Icon(NEXT_ICON),
  });

  const controls = Widget.Box(
    { vertical: true, vpack: 'center', class_name: 'controls', visible: false },
    positionSlider,
    Widget.CenterBox({
      vpack: 'center',
      start_widget: positionLabel,
      center_widget: Widget.Box([prev, playPause, next]),
      end_widget: lengthLabel,
    })
  );
  controls.hide();

  const trackInfo = Widget.Box({
    class_name: 'track-info',
    vertical: true,
    vpack: 'center',
    visible: false,
    children: [title, artist],
  });

  const mediaHover = () => {
    if (controls.visible) {
      controls.hide();
      trackInfo.show();
    } else {
      controls.show();
      trackInfo.hide();
    }
  };

  const mediaHoverLost = () => {
    controls.hide();
    trackInfo.show();
  };

  return Widget.Box(
    { vertical: true, spacing: 8 },
    Widget.Box(
      { class_name: 'player' },

      img,
      controls,
      Widget.EventBox({
        child: Widget.Box({ vertical: true, children: [trackInfo, controls] }),
        onHover: mediaHover,
        onHoverLost: mediaHoverLost,
      })
    )
  );
}

const icon = Widget.Icon({
  class_name: 'icon',
  hexpand: true,
  hpack: 'end',
  vpack: 'start',
  tooltip_text: 'Spotify',
  icon: 'Spotify-symbolic',
});

export function Media() {
  return Widget.Box({
    class_name: 'box media-box',
    setup: (self) =>
      self.hook(
        mpris,
        (self) => {
          const spotifyWindowExists =
            mpris.players.filter((p) => p.name === 'spotify').length > 0;
          if (!spotifyWindowExists) self.hide();
          else self.show();
        },
        'changed'
      ),
    children: [icon, ...players.as((p) => p.map(Player))],
  });
}
