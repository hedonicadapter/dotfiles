import { bind } from "astal";
import { Gtk } from "astal/gtk3";
import Mpris from "gi://AstalMpris";
import { exec } from "astal/process";
import { fmtMSS } from "../../../util";
import Hoverable from "../Hoverable";

const { START, CENTER, END } = Gtk.Align;
const POSITION_BAR_WIDTH = 110;

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
    halign={CENTER}
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
    halign={CENTER}
  >
    ⏸
  </button>
);

export default function () {
  return (
    <Hoverable
      className="media-player"
      main={
        <eventbox
          onClick={() =>
            spotify.get_available() && spotify.get_can_raise()
              ? spotify.raise()
              : exec("bash -c 'spotify'")
          }
          valign={CENTER}
        >
          {bind(spotify, "available").as(() => (
            <box className="main" valign={CENTER}>
              <box className="media-controls" valign={CENTER} halign={START}>
                <button
                  valign={CENTER}
                  halign={START}
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
                  halign={END}
                  className={bind(spotify, "can_go_next").as((b) =>
                    b ? "enabled" : "disabled",
                  )}
                  onClicked={() => spotify.get_can_go_next() && spotify.next()}
                >
                  ⏭
                </button>
              </box>

              <box halign={CENTER} valign={CENTER}>
                {bind(spotify, "position").as((p) => {
                  let positionInPx = 0;
                  if (p >= 0) {
                    const length = spotify.get_length();
                    positionInPx = Math.round(
                      (p / length) * POSITION_BAR_WIDTH,
                    );
                  }

                  return (
                    <box
                      className="position-bar"
                      valign={CENTER}
                      halign={CENTER}
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
                  );
                })}
              </box>

              <box halign={END} valign={CENTER}>
                {bind(spotify, "position").as((p) => {
                  let time;
                  if (p >= 0) {
                    const length = spotify.get_length();
                    const positionMSS = fmtMSS(Math.round(p));
                    const lengthMSS = fmtMSS(Math.round(length));

                    time = positionMSS + " / " + lengthMSS;
                  } else time = "--:-- / --:--";

                  return (
                    <box
                      valign={CENTER}
                      halign={CENTER}
                      className="position-and-length"
                    >
                      {time}
                    </box>
                  );
                })}
              </box>
            </box>
          ))}
        </eventbox>
      }
      hoveredElement={
        <box className="panel ">
          <box
            className="cover-art"
            css={bind(spotify, "art_url").as(
              (cover) =>
                `background-image: url("${cover}"); background-size: contain; min-width: 50px; min-height: 50px;`,
            )}
          />

          <box className="track-info" vertical>
            <label
              className="album-title"
              truncate
              label={bind(spotify, "album").as((s) => s || "")}
              halign={START}
            />
            <label
              className="artist-names"
              truncate
              label={bind(spotify, "artist").as((s) => s || "")}
              halign={START}
            />
            <label
              className="project-name"
              truncate
              label={bind(spotify, "title").as((s) => s || "")}
              halign={START}
            />
          </box>
        </box>
      }
    />
  );
}
