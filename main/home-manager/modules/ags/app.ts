import { App } from "astal/gtk3";
import Bar from "./widget/Bar";
import { readFileAsync } from "astal/file";

const monitors = App.get_monitors();
const style = await readFileAsync("style.scss");

App.start({
  css: style,
  main() {
    monitors.map(Bar);
  },
});
