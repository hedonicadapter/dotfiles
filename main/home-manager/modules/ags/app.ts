import { App } from "astal/gtk3";
import Bar from "./widget/Bar";
import { readFile, readFileAsync } from "astal/file";
import { execAsync } from "astal/process";

const monitors = App.get_monitors();

const style = await readFileAsync("style.scss");
const convertedToCss = await execAsync(
  `bash -c "echo '${style}' | sass --stdin"`,
);

App.start({
  css: convertedToCss,
  icons: `${SRC}/icons`,
  main() {
    monitors.map(Bar);
  },
});
