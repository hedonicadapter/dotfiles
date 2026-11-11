import { fillingOutputs } from "./compositor";

// Gap between the screen edge and the bar/outline frame
export const SCREEN_GAP = 10;

// The frame hugs the screen edge while the active window fills the output
export const screenGap = (monitorName: string | undefined) =>
  fillingOutputs.as((outputs) =>
    monitorName && outputs.includes(monitorName) ? 0 : SCREEN_GAP,
  );
