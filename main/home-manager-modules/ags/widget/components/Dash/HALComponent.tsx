import Gtk from "gi://Gtk?version=3.0";
import Textarea from "../Textarea";
import { subprocess } from "ags/process";
import { createState, createBinding } from "ags";

export const [toggleHAL, setToggleHAL] = createState(false);

const getCompletionScript = (msg: string) => {
  const payload = JSON.stringify({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: msg },
    ],
    stream: true,
  });

  const escapedPayload = payload.replace(/\\/g, "\\\\").replace(/"/g, '\\"');

  return `
        export $(grep -v "^#" .env | xargs)

        curl --no-buffer "https://api.openai.com/v1/chat/completions" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $HAL_OPENAI" \
            -d "${escapedPayload}"
    `;
};

const HALResponses = createState<string[]>([]);
let accumulatedResponse = " :PUTER";
const processStdout = (stdout: string) => {
  const chunk = stdout.toString().trim();

  if (!chunk) return;
  if (chunk === "data: [DONE]") {
    accumulatedResponse = " :PUTER";
    return;
  }
  if (!chunk.startsWith("data: ")) return;

  try {
    const jsonStr = chunk.slice(6);
    const json = JSON.parse(jsonStr);

    if (json.choices[0].delta?.content) {
      const res = json.choices[0].delta.content;
      const copy = JSON.parse(JSON.stringify(HALResponses.get()));

      if (accumulatedResponse === " :PUTER") copy.push(res);
      else copy[Math.max(copy.length - 1, 0)] = accumulatedResponse;

      accumulatedResponse += res;
      HALResponses.set(copy);
    }
  } catch (e) {
    console.error("Error processing stdout chunk:", e);
  }
};

export default function () {
  return (
    <box vertical class="HAL" visible={createBinding(toggleHAL)}>
      <box class="panel">
        <scrollable heightRequest={800} hscroll={Gtk.PolicyType.NEVER}>
          <box class="responses" orientation={1} vertical={true}>
            {HALResponses((responses) =>
              responses.map((response) =>
                response.startsWith("USER: ") ? (
                  <box class="response user" halign={Gtk.Align.START}>
                    <label
                      class="label"
                      label="USER: "
                      valign={Gtk.Align.START}
                    />
                    <label
                      class="text"
                      label={response.substring(6)}
                      wrap={true}
                      maxWidthChars={70}
                      halign={Gtk.Align.START}
                    />
                  </box>
                ) : (
                  <box class="response puter" halign={Gtk.Align.END}>
                    <label
                      class="text"
                      label={response.substring(7)}
                      wrap={true}
                      maxWidthChars={70}
                      halign={Gtk.Align.END}
                    />

                    <label
                      class="label"
                      label=" :PUTER"
                      valign={Gtk.Align.START}
                    />
                  </box>
                ),
              ),
            )}
          </box>
        </scrollable>
      </box>
      <Textarea
        class="textarea"
        vexpand
        hexpand
        onEnter={(str: string) => {
          const copy = JSON.parse(JSON.stringify(HALResponses.get()));
          copy.push("USER: " + str);
          HALResponses.set(copy);

          subprocess(["bash", "-c", getCompletionScript(str)], processStdout);
        }}
      />
    </box>
  );
}
