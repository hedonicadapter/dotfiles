import { createBinding } from "ags";
import { Gtk } from "ags/gtk3";
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
    // TODO:
    class={
      "play " +
      createBinding(playa, "can_play").as((b) => (b ? "enabled" : "disabled"))
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
    // TODO:
    class={
      "pause " +
      createBinding(playa, "can_pause").as((b) => (b ? "enabled" : "disabled"))
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
          // TODO:
          {createBinding(playa, "available").as(() => (
            <box class="main" valign={CENTER}>
              <box class="media-controls" valign={CENTER} halign={START}>
                <button
                  valign={CENTER}
                  halign={START}
                  // TODO:
                  class={createBinding(playa, "can_go_previous").as((b) =>
                    b ? "enabled" : "disabled",
                  )}
                  onClicked={() =>
                    playa.get_can_go_previous() && playa.previous()
                  }
                >
                  ⏮
                </button>
                // TODO:
                {createBinding(playa, "playback-status").as((status) => {
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
                  // TODO:
                  class={createBinding(playa, "can_go_next").as((b) =>
                    b ? "enabled" : "disabled",
                  )}
                  onClicked={() => playa.get_can_go_next() && playa.next()}
                >
                  ⏭
                </button>
              </box>

              <box halign={CENTER} valign={CENTER}>
                // TODO:
                {createBinding(playa, "position").as((p) => {
                  let positionInPx = 0;
                  if (p >= 0) {
                    const length = playa.get_length();
                    positionInPx = Math.round(
                      (p / length) * POSITION_BAR_WIDTH,
                    );
                  }

                  return (
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
                        css={`
                          min-width: ${positionInPx}px;
                        `}
                      />
                    </box>
                  );
                })}
              </box>

              <box halign={END} valign={CENTER}>
                // TODO:
                {createBinding(playa, "position").as((p) => {
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
                      class="position-and-length"
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
        <box class="panel ">
          <box
            class="cover-art"
            // TODO:
            css={createBinding(playa, "art_url").as(
              (cover) =>
                `background-image: url("${cover}"); background-size: contain; min-width: 50px; min-height: 50px;`,
            )}
          />

          <box class="track-info" vertical>
            <label
              class="album-title"
              truncate
              // TODO:
              label={createBinding(playa, "album").as((s) => s || "")}
              halign={START}
            />
            <label
              class="artist-names"
              truncate
              // TODO:
              label={createBinding(playa, "artist").as((s) => s || "")}
              halign={START}
            />
            <label
              class="project-name"
              truncate
              // TODO:
              label={createBinding(playa, "title").as((s) => s || "")}
              halign={START}
            />
          </box>
        </box>
      }
    />
  );
};
export default function () {
  // TODO:
  return createBinding(playa, "available").as(component);
}
