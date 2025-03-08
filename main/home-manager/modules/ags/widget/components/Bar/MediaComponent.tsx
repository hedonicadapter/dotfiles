import { bind } from "astal";
import { Gtk } from "astal/gtk3";
import Mpris from "gi://AstalMpris";
import { exec } from "astal/process";
import { fmtMSS } from "../../../util";
import Hoverable from "../Hoverable";

const { START, CENTER, END } = Gtk.Align;
const POSITION_BAR_WIDTH = 110;

// var currentPlayer
// if zenable
//    spotify.stop()
//    currentPlayer = mpv
//    currentPlayer.play()
//    set colors

const playa = Mpris.Player.new("spotify");
// raise() bring up spotify

const PlayButton = () => (
  <button
    className={
      "play " + bind(playa, "can_play").as((b) => (b ? "enabled" : "disabled"))
    }
    onClicked={() => playa.get_can_play() && playa.play()}
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
      bind(playa, "can_pause").as((b) => (b ? "enabled" : "disabled"))
    }
    onClicked={() => playa.get_can_pause() && playa.pause()}
    valign={CENTER}
    halign={CENTER}
  >
    ⏸
  </button>
);

const component = (enabled: boolean) => {
  return (
    <Hoverable
      className="media-player"
      main={
        <eventbox
          onClick={() =>
            playa.get_available() && playa.get_can_raise()
              ? playa.raise()
              : exec("bash -c 'spotify'")
          }
          valign={CENTER}
        >
          {bind(playa, "available").as(() => (
            <box className="main" valign={CENTER}>
              <box className="media-controls" valign={CENTER} halign={START}>
                <button
                  valign={CENTER}
                  halign={START}
                  className={bind(playa, "can_go_previous").as((b) =>
                    b ? "enabled" : "disabled",
                  )}
                  onClicked={() =>
                    playa.get_can_go_previous() && playa.previous()
                  }
                >
                  ⏮
                </button>

                {bind(playa, "playback-status").as((status) => {
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
                  className={bind(playa, "can_go_next").as((b) =>
                    b ? "enabled" : "disabled",
                  )}
                  onClicked={() => playa.get_can_go_next() && playa.next()}
                >
                  ⏭
                </button>
              </box>

              <box halign={CENTER} valign={CENTER}>
                {bind(playa, "position").as((p) => {
                  let positionInPx = 0;
                  if (p >= 0) {
                    const length = playa.get_length();
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
                {bind(playa, "position").as((p) => {
                  let time;
                  if (p >= 0) {
                    const length = playa.get_length();
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
      enable={enabled}
      hoveredElement={
        <box className="panel ">
          <box
            className="cover-art"
            css={bind(playa, "art_url").as(
              (cover) =>
                `background-image: url("${cover}"); background-size: contain; min-width: 50px; min-height: 50px;`,
            )}
          />

          <box className="track-info" vertical>
            <label
              className="album-title"
              truncate
              label={bind(playa, "album").as((s) => s || "")}
              halign={START}
            />
            <label
              className="artist-names"
              truncate
              label={bind(playa, "artist").as((s) => s || "")}
              halign={START}
            />
            <label
              className="project-name"
              truncate
              label={bind(playa, "title").as((s) => s || "")}
              halign={START}
            />
          </box>
        </box>
      }
    />
  );
};
export default function () {
  return bind(playa, "available").as(component);
}
