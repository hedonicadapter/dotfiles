# zen-video-diag: find out why video stutters in Zen and A/B the fixes.
usage() {
  cat <<'USAGE'
zen-video-diag            environment + profile summary
zen-video-diag log [URL]  run Zen with decoder/compositor logging, then summarise
zen-video-diag ab VARIANT [+flag...]   throwaway profile for side-by-side testing

VARIANT: plain | css | userjs | all
  plain    stock Zen, nothing from dotfiles
  css      userChrome.css + userContent.css from the real profile
  userjs   user.js from the real profile
  all      css + userjs (what the real profile runs)
flags:
  +sw      software WebRender (gfx.webrender.software)   -> expect worse
  +layer   gfx.webrender.layer-compositor=true           (helped on NVIDIA/AMD, zen#11890)
  +forcehw media.hardware-video-decoding.force-enabled   (skips the VA-API blocklist)
  +60hz    layout.frame_rate=60                          (isolates the 240 Hz projector)
USAGE
}

set -euo pipefail

zen_bin() { command -v zen-beta || command -v zen || command -v zen-twilight; }

profile_dir() {
  local ini
  for ini in "$HOME/.zen/profiles.ini" "${XDG_CONFIG_HOME:-$HOME/.config}/zen/profiles.ini"; do
    [[ -f $ini ]] || continue
    local base path
    base=$(dirname "$ini")
    # Install section wins (dedicated profiles), else Profile with Default=1
    path=$(awk -F= '/^\[Install/{s=1;next} /^\[/{s=0} s&&$1=="Default"{print $2;exit}' "$ini")
    [[ -z $path ]] && path=$(awk -F= '/^\[Profile/{p="";d=0} $1=="Path"{p=$2} $1=="Default"&&$2=="1"{print p;exit}' "$ini")
    [[ -n $path ]] && { echo "$base/$path"; return; }
  done
  return 1
}

summary() {
  echo "== host"; echo "$(hostname)  $(uname -r)"
  echo "session: ${XDG_SESSION_TYPE:-?}  desktop: ${XDG_CURRENT_DESKTOP:-?}  niri: ${NIRI_SOCKET:+yes}  hyprland: ${HYPRLAND_INSTANCE_SIGNATURE:+yes}"
  echo "== gpu"; lspci -nn | grep -Ei 'vga|3d|display' || true
  echo "== env"; env | grep -E '^(MOZ_|LIBVA_|NVD_|LD_LIBRARY_PATH|__GLX|GBM_|NIXOS_OZONE_WL|XDG_SESSION_TYPE|WAYLAND_DISPLAY)' | sort || true
  echo "== vainfo (what Firefox's VA-API decoder will get)"
  if vainfo >/tmp/zen-video-diag.vainfo 2>&1; then
    grep -E 'vainfo: (VA-API version|Driver version)' /tmp/zen-video-diag.vainfo
    echo "decode profiles: $(grep -c VAEntrypointVLD /tmp/zen-video-diag.vainfo)  (AV1: $(grep -c 'AV1Profile0.*VLD' /tmp/zen-video-diag.vainfo), VP9: $(grep -c 'VP9Profile0.*VLD' /tmp/zen-video-diag.vainfo), H264: $(grep -c 'H264Main.*VLD' /tmp/zen-video-diag.vainfo))"
  else
    echo "vainfo FAILED -> no hardware decode in any browser:"; tail -5 /tmp/zen-video-diag.vainfo
  fi
  echo "== zen"
  local bin; bin=$(zen_bin) || { echo "zen not in PATH"; return; }
  echo "binary: $bin ($("$bin" --version 2>/dev/null || true))"
  echo "ffmpeg on wrapper LD_LIBRARY_PATH:"; grep -oE '/nix/store/[a-z0-9]+-ffmpeg[^/:'"'"']*' "$bin" | sort -u | sed 's/^/  /' || true
  local p; p=$(profile_dir) || { echo "profile: none found (looked in ~/.zen and ~/.config/zen)"; return; }
  echo "profile: $p"
  for f in user.js chrome/userChrome.css chrome/userContent.css; do
    printf '  %-24s %s\n' "$f" "$([[ -e $p/$f ]] && echo present || echo MISSING)"
  done
  if [[ -f $p/prefs.js ]]; then
    echo "  prefs.js overrides of interest:"
    grep -E '"(gfx\.webrender\.(all|software|layer-compositor)|layers\.acceleration\.(force-enabled|disabled)|media\.hardware-video-decoding\.[a-z-]+|media\.ffmpeg\.vaapi\.enabled|widget\.dmabuf\.force-enabled|layout\.frame_rate|browser\.sessionstore\.interval)"' "$p/prefs.js" | sed 's/^/    /' || echo "    (none)"
  fi
  [[ -e $p/chrome/userContent.css ]] && grep -q 'transition-property: all' "$p/chrome/userContent.css" && echo "  NOTE: userContent.css still has the global 'transition-property: all' rule"
  pgrep -f 'zen-bin|zen-beta' >/dev/null && echo "zen is running (quit it before 'log')"
  echo
  echo "Next: open about:support in Zen -> Graphics. Want: Compositing = WebRender (not Software),"
  echo "      HW Decode / VA-API = available, Window Protocol = wayland. Then 'zen-video-diag log'."
}

log_run() {
  local bin; bin=$(zen_bin)
  if pgrep -f 'zen-bin|zen-beta' >/dev/null; then
    echo "Quit Zen first; a second launch only opens a window in the running instance and the log env is ignored." >&2; exit 1
  fi
  local dir="/tmp/zen-video-diag-log"; rm -rf "$dir"; mkdir -p "$dir"
  echo "Starting Zen with decoder logging. Play a YouTube video for ~20 s, then quit Zen."
  MOZ_LOG="PlatformDecoderModule:4,MediaDecoder:3,Dmabuf:4,WebRender:3" MOZ_LOG_FILE="$dir/zen.log" "$bin" "${1:-https://www.youtube.com/watch?v=LXb3EKWsInQ}" >/dev/null 2>&1 || true
  echo "== decoders used"
  cat "$dir"/zen.log* 2>/dev/null | grep -oE '(FFmpegVideoDecoder|FFmpegDataDecoder|VAAPI|VA-API|hardware (de|ac)celerat[a-z]*|software decod[a-z]*|Using (hw|sw|VAAPI|dmabuf)[^,]*|ffvpx|AV1|VP9|H264)[^"]{0,60}' | sort | uniq -c | sort -rn | head -25
  echo "== errors"
  cat "$dir"/zen.log* 2>/dev/null | grep -iE 'fail|error|blocklist|disabled|unavailable' | sort | uniq -c | sort -rn | head -15
  echo "(full logs: $dir)"
}

ab_run() {
  local variant=${1:?variant}; shift || true
  local bin real tmp; bin=$(zen_bin); real=$(profile_dir || true)
  tmp=$(mktemp -d /tmp/zen-ab-XXXX); mkdir -p "$tmp/chrome"
  {
    echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
    echo 'user_pref("browser.shell.checkDefaultBrowser", false);'
    echo 'user_pref("zen.welcome-screen.seen", true);'
    echo 'user_pref("browser.startup.page", 0);'
  } > "$tmp/user.js"
  case $variant in
    plain) ;;
    css) cp "$real"/chrome/*.css "$tmp/chrome/";;
    userjs) cat "$real/user.js" >> "$tmp/user.js";;
    all) cp "$real"/chrome/*.css "$tmp/chrome/"; cat "$real/user.js" >> "$tmp/user.js";;
    *) echo "unknown variant $variant" >&2; exit 2;;
  esac
  local x
  for x in "$@"; do
    case $x in
      +sw) echo 'user_pref("gfx.webrender.software", true);' >> "$tmp/user.js";;
      +layer) echo 'user_pref("gfx.webrender.layer-compositor", true);' >> "$tmp/user.js";;
      +forcehw) echo 'user_pref("media.hardware-video-decoding.force-enabled", true);' >> "$tmp/user.js";;
      +60hz) echo 'user_pref("layout.frame_rate", 60);' >> "$tmp/user.js";;
      *) echo "unknown flag $x" >&2; exit 2;;
    esac
  done
  echo "profile: $tmp  variant: $variant $*"
  echo "In the player: right click -> Stats for nerds -> watch 'Dropped Frames'. Close the window when done."
  "$bin" --no-remote --profile "$tmp" "https://www.youtube.com/watch?v=LXb3EKWsInQ" >/dev/null 2>&1 || true
  echo "profile kept at $tmp (rm -rf it when finished)"
}

case ${1:-} in
  "") summary;;
  log) shift; log_run "$@";;
  ab) shift; ab_run "$@";;
  -h|--help|help) usage;;
  *) usage >&2; exit 2;;
esac
