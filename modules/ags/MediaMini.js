const mpris = await Service.import("mpris");
const players = mpris.bind("players");

const icon = Widget.Icon({
  class_name: "spotify-icon",
  hexpand: true,
  hpack: "end",
  vpack: "start",
  tooltip_text: "Spotify",
  icon: "Spotify-symbolic",
});

function Player(player) {
  if (!player.name.includes("spotify")) return;

  const artist = Widget.Label({
    class_name: "artist",
    hpack: "start",
    vpack: "center",
    label: player.bind("track_artists").transform((a) => a.join(", ")),
  });
  const title = Widget.Label({
    class_name: "title",
    hpack: "start",
    vpack: "center",
    label: player.bind("track_title"),
  });

return Widget.Box({
    class_name: "track-info",
    vpack: "center",
    spacing: 8,
    children: [icon, artist, title],
  });

}

export function MediaMini() {
   

  return Widget.Box(
    {
      class_name: "box media-mini-box",
      setup: (self) =>
        self.hook(
          mpris,
          (self) => {
            const spotifyWindowExists =
              mpris.players.filter((p) => p.name === "spotify").length > 0;
            if (!spotifyWindowExists) self.hide();
            else self.show();
          },
          "changed"
        ),
      children: players.as(p=>p.map(Player))
    },
  );
}
