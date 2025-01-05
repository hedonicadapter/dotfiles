import { bind, Variable } from "astal";
import { Gtk } from "astal/gtk3";
import Mpris from "gi://AstalMpris";
import { exec } from "astal/process";
import { fmtMSS } from "../../../util";

const { START, CENTER, END } = Gtk.Align;
const POSITION_BAR_WIDTH = 120;

const spotify = Mpris.Player.new("spotify");
// raise() bring up spotify
// <label label={bind(spotify, "title")} />

const PlayButton = () => (
  <button
    className={
      "play " +
      bind(spotify, "can_play").as((b) => (b ? "enabled" : "disabled"))
    }
    onClicked={() => spotify.get_can_play() && spotify.play()}
    valign={CENTER}
  >
    ⏵
  </button>
);

const PauseButton = () => (
  <button
    className={
      "pause " +
      bind(spotify, "can_pause").as((b) => (b ? "enabled" : "disabled"))
    }
    onClicked={() => spotify.get_can_pause() && spotify.pause()}
    valign={CENTER}
  >
    ⏸
  </button>
);

export default function () {
  const hovered = Variable(false);

  return (
    <eventbox
      onClick={() =>
        spotify.get_available() && spotify.get_can_raise()
          ? spotify.raise()
          : exec("bash -c 'spotify'")
      }
      onHover={() => hovered.set(true)}
      onHoverLost={() => hovered.set(false)}
    >
      {bind(spotify, "available").as(() => (
        <box className="bar-item media-player" vertical>
          <box className="main">
            <box>
              <box className="media-controls" valign={CENTER} halign={START}>
                <button
                  valign={CENTER}
                  className={bind(spotify, "can_go_previous").as((b) =>
                    b ? "enabled" : "disabled",
                  )}
                  onClicked={() =>
                    spotify.get_can_go_previous() && spotify.previous()
                  }
                >
                  ⏮
                </button>

                {bind(spotify, "playback-status").as((status) => {
                  switch (status) {
                    case 2:
                    case 1:
                      return <PlayButton />;
                    case 0:
                    default:
                      return <PauseButton />;
                  }
                })}

                <button
                  valign={CENTER}
                  className={bind(spotify, "can_go_next").as((b) =>
                    b ? "enabled" : "disabled",
                  )}
                  onClicked={() => spotify.get_can_go_next() && spotify.next()}
                >
                  ⏭
                </button>
              </box>

              {bind(spotify, "position").as((p) => {
                const length = spotify.get_length();
                const positionInPx = Math.round(
                  (p / length) * POSITION_BAR_WIDTH,
                );

                const positionMSS = fmtMSS(Math.round(p));
                const lengthMSS = fmtMSS(Math.round(length));
                const time = positionMSS + " / " + lengthMSS;

                return (
                  <box valign={CENTER} hexpand vexpand>
                    <box
                      className="position-bar"
                      valign={CENTER}
                      hexpand
                      vexpand
                      css={`
                        min-width: ${POSITION_BAR_WIDTH}px;
                      `}
                    >
                      <box
                        vexpand
                        valign={CENTER}
                        className="current-position"
                        css={`
                          min-width: ${positionInPx}px;
                        `}
                      />
                    </box>
                    <box valign={CENTER} className="position-and-length">
                      {time}
                    </box>
                  </box>
                );
              })}
            </box>
          </box>
          <box className="track-info" visible={bind(hovered)}>
            <box className="cover-art-container">
              <box
                className="cover-art"
                css={bind(spotify, "art_url").as(
                  (cover) =>
                    `background-image: url("${cover}"); background-size: contain; min-width: 50px; min-height: 50px;`,
                )}
              />
            </box>

            <box vertical>
              <label
                className="album-title"
                truncate
                label={bind(spotify, "album") || ""}
                halign={START}
              />
              <label
                className="artist-names"
                truncate
                label={bind(spotify, "artist") || ""}
                halign={START}
              />
              <label
                className="project-name"
                truncate
                label={bind(spotify, "title") || ""}
                halign={START}
              />
            </box>
          </box>
        </box>
      ))}
    </eventbox>
  );
}
