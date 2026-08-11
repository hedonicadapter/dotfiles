import { createBinding, With } from "ags";
import Gtk from "gi://Gtk?version=3.0";
import Mpris from "gi://AstalMpris";
import { exec } from "ags/process";
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
    class={createBinding(playa, "can_play").as(
      (b) => "play " + (b ? "enabled" : "disabled"),
    )}
    onClicked={() => playa.get_can_play() && playa.play()}
    valign={CENTER}
    halign={CENTER}
  >
    ⏵
  </button>
);

const PauseButton = () => (
  <button
    class={createBinding(playa, "can_pause").as(
      (b) => "pause " + (b ? "enabled" : "disabled"),
    )}
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
      class="media-player"
      main={
        <eventbox
          onClick={() =>
            playa.get_available() && playa.get_can_raise()
              ? playa.raise()
              : exec("bash -c 'spotify'")
          }
          valign={CENTER}
        >
          <box class="main" valign={CENTER}>
            <box class="media-controls" valign={CENTER} halign={START}>
              <button
                valign={CENTER}
                halign={START}
                class={createBinding(playa, "can_go_previous").as((b) =>
                  b ? "enabled" : "disabled",
                )}
                onClicked={() => playa.get_can_go_previous() && playa.previous()}
              >
                ⏮
              </button>

              <With value={createBinding(playa, "playback-status")}>
                {(status) => {
                  switch (status) {
                    case 2:
                    case 1:
                      return <PlayButton />;
                    case 0:
                    default:
                      return <PauseButton />;
                  }
                }}
              </With>

              <button
                valign={CENTER}
                halign={END}
                class={createBinding(playa, "can_go_next").as((b) =>
                  b ? "enabled" : "disabled",
                )}
                onClicked={() => playa.get_can_go_next() && playa.next()}
              >
                ⏭
              </button>
            </box>

            <box halign={CENTER} valign={CENTER}>
              <box
                class="position-bar"
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
                  class="current-position"
                  css={createBinding(playa, "position").as((p) => {
                    const length = playa.get_length();
                    const positionInPx =
                      p >= 0 && length > 0
                        ? Math.round((p / length) * POSITION_BAR_WIDTH)
                        : 0;

                    return `min-width: ${positionInPx}px;`;
                  })}
                />
              </box>
            </box>

            <box halign={END} valign={CENTER}>
              <box valign={CENTER} halign={CENTER} class="position-and-length">
                <label
                  label={createBinding(playa, "position").as((p) => {
                    if (p < 0) return "--:-- / --:--";

                    const length = playa.get_length();
                    return (
                      fmtMSS(Math.round(p)) + " / " + fmtMSS(Math.round(length))
                    );
                  })}
                />
              </box>
            </box>
          </box>
        </eventbox>
      }
      enable={enabled}
      hoveredElement={
        <box class="panel ">
          <box
            class="cover-art"
            css={createBinding(playa, "art_url").as(
              (cover) =>
                `background-image: url("${cover}"); background-size: contain; min-width: 50px; min-height: 50px;`,
            )}
          />

          <box class="track-info" vertical>
            <label
              class="album-title"
              truncate
              label={createBinding(playa, "album").as((s) => s || "")}
              halign={START}
            />
            <label
              class="artist-names"
              truncate
              label={createBinding(playa, "artist").as((s) => s || "")}
              halign={START}
            />
            <label
              class="project-name"
              truncate
              label={createBinding(playa, "title").as((s) => s || "")}
              halign={START}
            />
          </box>
        </box>
      }
    />
  );
};

export default function MediaComponent() {
  return (
    <With value={createBinding(playa, "available")}>
      {(available) => component(available)}
    </With>
  );
}
