// stolen from https://stackoverflow.com/a/37770048 by GitaarLAB
export function fmtMSS(s: number) {
  return (s - (s %= 60)) / 60 + (9 < s ? ":" : ":0") + s;
}
