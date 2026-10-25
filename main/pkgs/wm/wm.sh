usage() {
  cat >&2 <<'USAGE'
usage: wm outputs                    JSON: [{name, focused, scale, mode, modes, current}]
       wm focused-output             name of the focused output
       wm set-mode OUTPUT WxH[@R]    e.g. wm set-mode HDMI-A-1 1920x1080@240
       wm set-scale OUTPUT SCALE

Modes are {width, height, refresh} with refresh in Hz; current indexes modes.
USAGE
  exit 2
}

backend() {
  if [[ -S "${NIRI_SOCKET:-}" ]]; then
    echo niri
  elif [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    echo hyprland
  else
    echo "wm: neither niri nor Hyprland is running" >&2
    return 1
  fi
}

outputs() {
  local wm
  wm=$(backend)

  case $wm in
  niri)
    local focused
    focused=$(niri msg --json focused-output | jq -r '.name')
    niri msg --json outputs | jq --arg focused "$focused" '
      [.[] | select(.current_mode != null)
       | (.modes | map({width, height, refresh: (.refresh_rate / 1000)})) as $modes
       | {name, focused: (.name == $focused), scale: .logical.scale,
          mode: $modes[.current_mode], modes: $modes, current: .current_mode}]'
    ;;
  hyprland)
    # availableModes are "WxH@R.RRHz" strings; current is the closest one
    hyprctl -j monitors | jq '
      [.[] | . as $m
       | [.availableModes[]
          | capture("(?<w>[0-9]+)x(?<h>[0-9]+)@(?<r>[0-9.]+)Hz")
          | {width: (.w | tonumber), height: (.h | tonumber), refresh: (.r | tonumber)}] as $modes
       | {name, focused, scale,
          mode: {width, height, refresh: .refreshRate}, modes: $modes,
          current: ($modes | to_entries
            | map(select(.value.width == $m.width and .value.height == $m.height))
            | min_by((.value.refresh - $m.refreshRate) | fabs) | .key)}]'
    ;;
  esac
}

# Values end up in Lua source on Hyprland, so only accept plain tokens
check() {
  [[ $2 =~ $3 ]] || {
    echo "wm: invalid $1: $2" >&2
    exit 2
  }
}

hypr_eval() {
  local result
  result=$(hyprctl eval "$1")
  [[ $result == ok ]] || {
    echo "wm: hyprctl eval: $result" >&2
    return 1
  }
}

set_mode() {
  check output "$1" '^[A-Za-z0-9-]+$'
  check mode "$2" '^[0-9]+x[0-9]+(@[0-9.]+)?$'

  local wm
  wm=$(backend)
  case $wm in
  niri) niri msg output "$1" mode "$2" ;;
  # Runtime monitor rule; merges into the configured one for this output
  hyprland) hypr_eval "hl.monitor({ output = \"$1\", mode = \"$2\" })" ;;
  esac
}

set_scale() {
  check output "$1" '^[A-Za-z0-9-]+$'
  check scale "$2" '^[0-9]+(\.[0-9]+)?$'

  local wm
  wm=$(backend)
  case $wm in
  niri) niri msg output "$1" scale "$2" ;;
  hyprland) hypr_eval "hl.monitor({ output = \"$1\", scale = $2 })" ;;
  esac
}

case ${1:-} in
outputs) outputs ;;
focused-output) outputs | jq -er '.[] | select(.focused) | .name' ;;
set-mode)
  [[ $# -eq 3 ]] || usage
  set_mode "$2" "$3"
  ;;
set-scale)
  [[ $# -eq 3 ]] || usage
  set_scale "$2" "$3"
  ;;
*) usage ;;
esac
