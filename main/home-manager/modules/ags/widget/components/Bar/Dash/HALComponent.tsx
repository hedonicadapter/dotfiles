import { bind, Variable } from "astal";
import { Gtk } from "astal/gtk3";
import Textarea from "../../Textarea";
import { subprocess } from "astal/process";

export const toggleHAL = Variable(false);

const getCompletion = (msg: string) => `
    bash -c '
        export $(grep -v "^#" .env | xargs)

        curl --no-buffer "https://api.openai.com/v1/chat/completions" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $HAL_OPENAI" \
            -d "{
                \\"model\\": \\"gpt-4o-mini\\",
                \\"messages\\": [
                    {
                        \\"role\\": \\"system\\",
                        \\"content\\": \\"You are a helpful assistant.\\"
                    },
                    {
                        \\"role\\": \\"user\\",
                        \\"content\\": \\"${msg}\\"
                    }
                ],
                \\"stream\\": true
            }"
    '
`;

const HALResponses = Variable<string[]>([]);
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
    <box className="HAL" visible={bind(toggleHAL)}>
      <scrollable heightRequest={200} hscroll={Gtk.PolicyType.NEVER}>
        <box className="responses" orientation={1} vertical={true}>
          {bind(HALResponses).as((responses) =>
            responses.map((response) =>
              response.startsWith("USER: ") ? (
                <box className="response user" halign={Gtk.Align.START}>
                  <label
                    className="label"
                    label="USER: "
                    valign={Gtk.Align.START}
                  />
                  <label
                    className="text"
                    label={response.substring(6)}
                    wrap={true}
                    maxWidthChars={70}
                    halign={Gtk.Align.START}
                  />
                </box>
              ) : (
                <box className="response puter" halign={Gtk.Align.END}>
                  <label
                    className="text"
                    label={response.substring(7)}
                    wrap={true}
                    maxWidthChars={70}
                    halign={Gtk.Align.END}
                  />

                  <label
                    className="label"
                    label=" :PUTER"
                    valign={Gtk.Align.START}
                  />
                </box>
              ),
            ),
          )}
        </box>
      </scrollable>
      <Textarea
        className="textarea"
        onEnter={(str: string) => {
          const copy = JSON.parse(JSON.stringify(HALResponses.get()));
          copy.push("USER: " + str);
          HALResponses.set(copy);

          subprocess(getCompletion(str), processStdout);
        }}
      />
    </box>
  );
}
