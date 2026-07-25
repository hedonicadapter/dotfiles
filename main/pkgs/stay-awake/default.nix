# Temporarily keep the mac awake/unlocked via a caffeinate power assertion.
# Auto-expires, so the lock always comes back even if the script dies.
# STAY_AWAKE_PIDFILE scopes an instance (e.g. Claude hooks hold their own
# lease without clobbering a manually started one).
{writeShellScriptBin}:
writeShellScriptBin "stay-awake" ''
  set -euo pipefail

  PIDFILE="''${STAY_AWAKE_PIDFILE:-''${TMPDIR:-/tmp}/stay-awake.pid}"

  usage() {
    echo "Usage: stay-awake [minutes] | toggle [minutes] | off | status" >&2
    exit 1
  }

  is_active() {
    [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
  }

  start() {
    local minutes="$1"
    [[ "$minutes" =~ ^[0-9]+$ ]] && ((minutes > 0)) || usage
    [[ -f "$PIDFILE" ]] && kill "$(cat "$PIDFILE")" 2>/dev/null || true
    # >/dev/null so a command substitution wrapping start() isn't held open for the full duration
    /usr/bin/caffeinate -d -i -u -t $((minutes * 60)) >/dev/null 2>&1 &
    echo $! >"$PIDFILE"
    echo "Screen lock paused for $minutes min, until $(date -v "+''${minutes}M" +%H:%M)."
  }

  stop() {
    if [[ -f "$PIDFILE" ]] && kill "$(cat "$PIDFILE")" 2>/dev/null; then
      echo "Auto-lock back to normal."
    else
      echo "stay-awake isn't running."
    fi
    rm -f "$PIDFILE"
  }

  notify() {
    /usr/bin/osascript -e "display notification \"$1\" with title \"stay-awake\"" >/dev/null
  }

  case "''${1:-}" in
    off | stop | cancel)
      stop
      ;;
    status)
      if is_active; then
        echo "Active (pid $(cat "$PIDFILE"))."
      else
        rm -f "$PIDFILE"
        echo "Not active."
      fi
      ;;
    toggle)
      if is_active; then
        msg="$(stop)"
      else
        msg="$(start "''${2:-20}")"
      fi
      echo "$msg"
      notify "$msg"
      ;;
    *)
      start "''${1:-20}"
      echo "Run 'stay-awake off' to undo."
      ;;
  esac
''
