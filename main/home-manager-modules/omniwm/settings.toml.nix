# Port of home-manager-modules/niri/config.kdl.nix to OmniWM 0.7.x (macOS), schema v3.
# Mod = Command, matching the aerospace binds this replaces. Workspaces use the
# dwindle layout (Hyprland-style BSP); the niri section and niri-only binds stay so
# toggleWorkspaceLayout (Mod+Ctrl+Shift+L) still gives a usable scrolling layout.
#
# Schema v3 is strict: a missing required key, an unknown enum value, or a hotkeys
# array that doesn't list every assignable action exactly once rejects the WHOLE
# file, and OmniWM silently runs on defaults. Hence the generated hotkeys list below.
#
# Niri concepts that have no OmniWM equivalent, and are therefore dropped:
#   blur/noise/opacity window rules, shaders, tab-indicator + insert-hint styling,
#   xkb layout/repeat (macOS system prefs), spawn-at-startup,
#   move-workspace-up/down (reordering workspaces), keyboard-shortcuts-inhibit.
# closeFocusedWindow exists but stays unbound: Cmd+W must keep closing tabs.
# Launcher-ish binds (Mod+T, Mod+R/B/D/Q/U/S menus, screenshots) live in skhd.nix —
# OmniWM hotkeys can only run window-manager commands, never external processes.
{outputs, ...}: let
  p = outputs.palette;

  hexDigits = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
    "A" = 10;
    "B" = 11;
    "C" = 12;
    "D" = 13;
    "E" = 14;
    "F" = 15;
  };
  hexByte = s: 16 * hexDigits.${builtins.substring 0 1 s} + hexDigits.${builtins.substring 1 1 s};

  # Whole numbers must still serialize as TOML floats — the decoder wants Double.
  float = v: let
    s = toString v;
  in
    if builtins.match ".*\\..*" s == null
    then "${s}.0"
    else s;
  channel = hex: offset: float ((hexByte (builtins.substring offset 2 (builtins.substring 1 6 hex))) / 255.0);

  # OmniWM stores colors as float RGBA components, one key per channel.
  color = table: hex: alpha: ''
    [${table}]
    red = ${channel hex 0}
    green = ${channel hex 2}
    blue = ${channel hex 4}
    alpha = ${float alpha}
  '';

  # Every assignable action id in OmniWM 0.7.2 (ActionCatalog*.swift). Anything
  # not bound below is written as "Unassigned", which also kills OmniWM's built-in
  # defaults — Option+digit ones eat the Swedish layout's | [ ] \ { }.
  range = from: to: builtins.genList (i: from + i) (to - from + 1);
  indexed = prefix: from: to: map (i: "${prefix}.${toString i}") (range from to);
  directions = prefix: map (d: "${prefix}.${d}") ["left" "down" "up" "right"];
  actionIds =
    indexed "toggleScratchpad" 1 10
    ++ indexed "assignFocusedWindowToScratchpad" 1 10
    ++ indexed "switchWorkspace" 0 8
    ++ indexed "moveToWorkspace" 0 8
    ++ indexed "switchWorkspaceSlot" 1 9
    ++ indexed "moveToWorkspaceSlot" 1 9
    ++ indexed "moveColumnToWorkspace" 0 8
    ++ indexed "focusColumn" 0 8
    ++ indexed "focusWindowInColumn" 1 9
    ++ indexed "moveColumnToIndex" 1 9
    ++ directions "focus"
    ++ directions "move"
    ++ directions "moveColumn"
    ++ directions "moveWorkspaceToMonitor"
    ++ directions "moveWindowToMonitor"
    ++ directions "preselect"
    ++ [
      "workspaceBackAndForth"
      "switchWorkspace.next"
      "switchWorkspace.previous"
      "focusPrevious"
      "focusDownOrLeft"
      "focusUpOrRight"
      "focusWindowTop"
      "focusWindowBottom"
      "focusWindowDownOrTop"
      "focusWindowUpOrBottom"
      "focusWindowOrWorkspaceDown"
      "focusWindowOrWorkspaceUp"
      "centerColumn"
      "centerVisibleColumns"
      "moveWindowToWorkspaceUp"
      "moveWindowToWorkspaceDown"
      "moveColumnToWorkspaceUp"
      "moveColumnToWorkspaceDown"
      "moveWindowDown"
      "moveWindowUp"
      "moveWindowDownOrToWorkspaceDown"
      "moveWindowUpOrToWorkspaceUp"
      "consumeWindowIntoColumn"
      "expelWindowFromColumn"
      "focusMonitorNext"
      "focusMonitorPrevious"
      "focusMonitorLast"
      "toggleFullscreen"
      "toggleNativeFullscreen"
      "moveColumnToFirst"
      "moveColumnToLast"
      "toggleColumnTabbed"
      "focusColumnFirst"
      "focusColumnLast"
      "cycleSizeForward"
      "cycleSizeBackward"
      "cycleWindowPrimarySpanForward"
      "cycleWindowPrimarySpanBackward"
      "cycleWindowSecondarySpanForward"
      "cycleWindowSecondarySpanBackward"
      "toggleContainerFullPrimarySpan"
      "expandContainerToAvailablePrimarySpan"
      "resetWindowSecondarySpan"
      "setContainerPrimarySpan.decrease10Percent"
      "setContainerPrimarySpan.increase10Percent"
      "setWindowPrimarySpan.decrease10Percent"
      "setWindowPrimarySpan.increase10Percent"
      "setWindowSecondarySpan.decrease10Percent"
      "setWindowSecondarySpan.increase10Percent"
      "balanceSizes"
      "moveToRoot"
      "toggleSplit"
      "swapSplit"
      "resizeGrow.horizontal"
      "resizeGrow.vertical"
      "resizeShrink.horizontal"
      "resizeShrink.vertical"
      "resizeFocusedWindow.grow"
      "resizeFocusedWindow.shrink"
      "preselectClear"
      "openCommandPalette"
      "raiseAllFloatingWindows"
      "rescueOffscreenWindows"
      "toggleFocusedWindowFloating"
      "closeFocusedWindow"
      "openMenuAnywhere"
      "toggleWorkspaceBarVisibility"
      "toggleHiddenBarPanel"
      "toggleQuakeTerminal"
      "toggleWorkspaceLayout"
      "toggleOverview"
      "toggleSystemStats"
    ];

  hotkeyBinds = {
    # Focus / move (niri + Hyprland Mod+H/J/K/L). Shared by both layouts; in
    # dwindle, move swaps with the neighbor in that direction.
    "focus.left" = "Command+H";
    "focus.down" = "Command+J";
    "focus.up" = "Command+K";
    "focus.right" = "Command+L";
    "move.left" = "Command+Shift+H";
    "move.down" = "Command+Shift+J";
    "move.up" = "Command+Shift+K";
    "move.right" = "Command+Shift+L";
    # Were OmniWM defaults on 0.5.9, kept for parity (Option+Tab etc. type nothing).
    "focusPrevious" = "Option+Tab";
    "workspaceBackAndForth" = "Option+Control+Tab";

    # Dwindle (Hyprland binds). Mod+Ctrl+H/J/K/L resize like hyprland's
    # resizeactive; on niri workspaces these do nothing.
    "resizeShrink.horizontal" = "Command+Control+H";
    "resizeGrow.horizontal" = "Command+Control+L";
    "resizeShrink.vertical" = "Command+Control+K";
    "resizeGrow.vertical" = "Command+Control+J";
    "toggleSplit" = "Command+Control+T";
    "swapSplit" = "Command+Control+Shift+T";
    "moveToRoot" = "Command+Control+Return";
    "balanceSizes" = "Command+Control+E";

    # Workspaces. Only 1-4 get focus binds, like niri.
    "switchWorkspace.0" = "Command+1";
    "switchWorkspace.1" = "Command+2";
    "switchWorkspace.2" = "Command+3";
    "switchWorkspace.3" = "Command+4";
    "moveToWorkspace.0" = "Command+Shift+1";
    "moveToWorkspace.1" = "Command+Shift+2";
    "moveToWorkspace.2" = "Command+Shift+3";
    "moveToWorkspace.3" = "Command+Shift+4";
    "moveToWorkspace.4" = "Command+Shift+5";
    "moveToWorkspace.5" = "Command+Shift+6";
    # niri Mod+I / Mod+Page_Down. Page Up would be dead weight on the laptop.
    "switchWorkspace.previous" = "Command+I";
    "switchWorkspace.next" = "Command+Page Down";
    # niri move-column-to-workspace-up/down. The column actions are niri-only,
    # the window ones work in dwindle too.
    "moveWindowToWorkspaceUp" = "Command+Control+I";
    "moveWindowToWorkspaceDown" = "Command+Control+Page Down";

    # Monitors. OmniWM only walks the monitor list, so niri's Mod+Alt+J/K
    # (focus-monitor-down/up) have nowhere to go.
    "focusMonitorPrevious" = "Command+Option+H";
    "focusMonitorNext" = "Command+Option+L";
    "focusMonitorLast" = "Command+Option+Grave";
    # niri move-column-to-monitor-*; closest is moving the focused window.
    "moveWindowToMonitor.left" = "Command+Option+Shift+H";
    "moveWindowToMonitor.down" = "Command+Option+Shift+J";
    "moveWindowToMonitor.up" = "Command+Option+Shift+K";
    "moveWindowToMonitor.right" = "Command+Option+Shift+L";

    # Niri-only (no-ops on dwindle workspaces).
    "moveColumn.left" = "Command+Left Bracket";
    "moveColumn.right" = "Command+Right Bracket";
    "focusColumnFirst" = "Command+Home";
    "focusColumnLast" = "Command+End";
    "moveColumnToFirst" = "Command+Control+Home";
    "moveColumnToLast" = "Command+Control+End";
    "consumeWindowIntoColumn" = "Command+Comma";
    "expelWindowFromColumn" = "Command+Period";
    "toggleColumnTabbed" = "Command+Shift+W";
    # niri focus-column N; was the OmniWM default on 0.5.9.
    "focusColumn.0" = "Option+Control+1";
    "focusColumn.1" = "Option+Control+2";
    "focusColumn.2" = "Option+Control+3";
    "focusColumn.3" = "Option+Control+4";
    "focusColumn.4" = "Option+Control+5";
    "focusColumn.5" = "Option+Control+6";
    "focusColumn.6" = "Option+Control+7";
    "focusColumn.7" = "Option+Control+8";
    "focusColumn.8" = "Option+Control+9";
    # Sizing. Primary span = column width, secondary span = window height.
    # niri's ±30px binds become ±10% — OmniWM has no pixel-step action.
    "setContainerPrimarySpan.decrease10Percent" = "Command+Minus";
    "setContainerPrimarySpan.increase10Percent" = "Command+Equal";
    "setWindowSecondarySpan.decrease10Percent" = "Command+Shift+Minus";
    "setWindowSecondarySpan.increase10Percent" = "Command+Shift+Equal";
    "cycleWindowSecondarySpanForward" = "Command+Control+Shift+R";
    "resetWindowSecondarySpan" = "Command+Control+R";
    # Cmd+F (find) and Cmd+Ctrl+F (macOS native fullscreen) stay with apps, so
    # toggleContainerFullPrimarySpan / expandContainerToAvailablePrimarySpan are unbound.
    # niri Mod+C, moved off Command+C so copy keeps working.
    "centerColumn" = "Command+Control+C";
    "centerVisibleColumns" = "Command+Control+Shift+C";

    # Shared layout and window binds.
    "cycleSizeForward" = "Command+Control+W";
    "cycleSizeBackward" = "Command+Control+Shift+W";
    "toggleFullscreen" = "Command+M";
    "toggleNativeFullscreen" = "Command+Shift+M";
    "toggleFocusedWindowFloating" = "Command+Shift+F";
    "raiseAllFloatingWindows" = "Command+Control+Shift+F";
    "toggleOverview" = "Command+O";
    "toggleWorkspaceLayout" = "Command+Control+Shift+L";

    # OmniWM extras with no niri counterpart.
    "toggleQuakeTerminal" = "Command+Grave";
    "openCommandPalette" = "Command+Shift+Space";
    "openMenuAnywhere" = "Command+Control+M";
    "toggleWorkspaceBarVisibility" = "Command+Control+B";
    "toggleScratchpad.1" = "Command+Control+S";
    "assignFocusedWindowToScratchpad.1" = "Command+Control+Shift+S";
  };

  # Fail the build on a typo'd id or a chord bound twice, instead of OmniWM
  # rejecting the file (unknown id) or Carbon dropping one registration.
  unknownIds = builtins.filter (id: !(builtins.elem id actionIds)) (builtins.attrNames hotkeyBinds);
  chords = builtins.attrValues hotkeyBinds;
  duplicateChords = builtins.filter (c: builtins.length (builtins.filter (x: x == c) chords) > 1) chords;
  hotkeys =
    assert unknownIds == [] || throw "omniwm: unknown hotkey ids: ${toString unknownIds}";
    assert duplicateChords == [] || throw "omniwm: chords bound twice: ${toString duplicateChords}";
      builtins.listToAttrs (map (id: {
          name = id;
          value = "Unassigned";
        })
        actionIds)
      // hotkeyBinds;

  bind = id: keys: ''  { id = "${id}", binding = "${keys}" },'';
in ''
  # Generated by nix — edits here are overwritten on the next home-manager switch.
  schemaVersion = 3

  hotkeys = [
  ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs bind hotkeys))}
  ]

  # Per-monitor overrides are set up interactively (Settings > Monitors), which
  # needs display UUIDs. Declared empty so the strict decode path succeeds.
  monitorBarOverrides = []
  monitorOrientationOverrides = []
  monitorNiriOverrides = []
  monitorDwindleOverrides = []
  monitorGapOverrides = []

  [general]
  hotkeysEnabled = true
  systemHyperTrigger = "None"
  hyperKeyModifiers = "Control+Option+Shift+Command"
  # Workspaces use layoutType = "default", so this picks the layout for all of them.
  defaultLayoutType = "dwindle"
  preventSleepEnabled = false
  updateChecksEnabled = false
  ipcEnabled = true
  animationsEnabled = true

  [focus]
  # focus-follows-mouse + warp-mouse-to-focus mode="center-xy"
  followsMouse = true
  # 0.5.9 always raised on hover focus; keep that.
  raiseOnMouseFocus = true
  lockModifier = "off"
  moveMouseToFocusedWindow = true
  followsWindowToMonitor = true
  # niri focus-column-or-monitor-left / move-column-left-or-to-monitor-left
  crossesMonitorAtEdge = true
  moveCrossesMonitorAtEdge = true

  [mouseWarp]
  enabled = true
  margin = 1
  constrainToArrangement = false

  [routing]
  mode = "macOS"
  arrangements = []

  [gaps]
  size = 16.0
  fullscreenUsesOuterGaps = false

  [gaps.outer]
  left = 16.0
  right = 16.0
  top = 16.0
  bottom = 16.0

  [niri]
  visibleContainerCount = 2
  infiniteLoop = false
  centerFocusedColumn = "onOverflow"
  alwaysCenterSingleColumn = true
  # Lone window keeps its column width instead of filling the screen, so
  # always-center-single-column is actually visible.
  singleWindowFit = "container_primary_span"
  containerPrimarySpanPresets = [0.33333, 0.5, 0.66667]
  defaultContainerPrimarySpan = 0.5

  [dwindle]
  smartSplit = false
  defaultSplitRatio = 1.0
  splitWidthMultiplier = 1.0
  singleWindowFit = "fill"
  useGlobalGaps = true
  moveToRootStable = true

  [borders]
  # services.jankyborders (darwin/configuration.nix) already draws these.
  enabled = false
  width = 1.0

  ${color "borders.color" p.base04 1.0}
  [overview]
  zoom = 1.0

  ${color "overview.backdrop" p.base00 1.0}
  ${color "overview.windowBorders.normal" p.base03 1.0}
  ${color "overview.windowBorders.hovered" p.base0D 1.0}
  ${color "overview.windowBorders.selected" p.base04 1.0}
  [workspaceBar]
  enabled = true
  showLabels = true
  showFloatingWindows = false
  windowLevel = "popup"
  position = "overlappingMenuBar"
  notchMode = "moveBelowMenuBar"
  notchActiveZoneWidth = 180.0
  systemStatsButton = false
  deduplicateAppIcons = true
  hideEmptyWorkspaces = false
  excludedBundleIDs = []
  reserveLayoutSpace = false
  revealModifier = "off"
  revealHoldMilliseconds = 200.0
  hideInNativeFullscreen = false
  height = 24.0
  backgroundOpacity = 0.1
  xOffset = 0.0
  yOffset = 0.0

  [workspaceBar.iconOverrides]

  ${color "workspaceBar.accentColor" p.base0D 1.0}
  ${color "workspaceBar.textColor" p.base05 1.0}
  [gestures]
  scrollEnabled = true
  scrollSensitivity = 5.0
  # Mod+WheelScroll column navigation, closest available modifier.
  scrollModifierKey = "optionShift"
  # niri/Hyprland Mod+drag = move; option stands in since Cmd-drag is taken by macOS.
  mouseMoveModifierKey = "option"
  mouseResizeModifierKey = "option"
  fingerCount = 3
  # niri touchpad { natural-scroll }
  invertDirection = true
  trackpadScrollStyle = "snap"
  workspaceSwipeEnabled = false
  workspaceSwipeFingerCount = 3
  workspaceSwipeAxis = "vertical"

  [statusBar]
  showWorkspaceName = true
  showAppNames = false
  useWorkspaceId = false

  [hiddenBar]
  enabled = false
  hiddenBundleIDs = []
  rehideIntervalSeconds = 5.0

  [clipboard]
  historyEnabled = false
  maxItems = 200
  maxItemBytes = 8388608
  maxTotalBytes = 67108864

  [quakeTerminal]
  # Not a niri feature; kitty via skhd (Command+T) is still the real terminal.
  enabled = true
  position = "top"
  widthPercent = 100.0
  heightPercent = 40.0
  animationDuration = 0.2
  autoHide = false
  opacity = 0.95
  backgroundEffect = "standardBlur"
  backgroundBlurRadius = 30
  monitorMode = "focusedWindow"

  [scratchpads.labels]

  [appearance]
  # stylix polarity = "light"
  mode = "light"

  # Workspaces need stable UUIDs, otherwise every switch reshuffles them.
  [[workspaces]]
  id = "9E1B4C10-0001-4A00-9C00-000000000001"
  name = "1"
  layoutType = "default"
  monitorAssignment = { type = "main" }

  [[workspaces]]
  id = "9E1B4C10-0001-4A00-9C00-000000000002"
  name = "2"
  layoutType = "default"
  monitorAssignment = { type = "main" }

  [[workspaces]]
  id = "9E1B4C10-0001-4A00-9C00-000000000003"
  name = "3"
  layoutType = "default"
  monitorAssignment = { type = "main" }

  [[workspaces]]
  id = "9E1B4C10-0001-4A00-9C00-000000000004"
  name = "4"
  layoutType = "default"
  monitorAssignment = { type = "main" }

  [[workspaces]]
  id = "9E1B4C10-0001-4A00-9C00-000000000005"
  name = "5"
  layoutType = "default"
  monitorAssignment = { type = "secondary" }

  [[workspaces]]
  id = "9E1B4C10-0001-4A00-9C00-000000000006"
  name = "6"
  layoutType = "default"
  monitorAssignment = { type = "secondary" }

  # niri window-rule match app-id="popup" → open-floating
  [[appRules]]
  id = "9E1B4C10-0002-4A00-9C00-000000000001"
  bundleId = ""
  axSubrole = "AXDialog"
  layout = "float"

  # niri window-rule match title="^Picture-in-Picture$" → open-floating
  [[appRules]]
  id = "9E1B4C10-0002-4A00-9C00-000000000002"
  bundleId = ""
  titleRegex = "^Picture-in-Picture$"
  layout = "float"

  [[appRules]]
  id = "9E1B4C10-0002-4A00-9C00-000000000003"
  bundleId = "com.apple.systempreferences"
  layout = "float"

  [[appRules]]
  id = "9E1B4C10-0002-4A00-9C00-000000000004"
  bundleId = "com.apple.calculator"
  layout = "float"

  # niri default-column-width { proportion 0.5; }
  [[appRules]]
  id = "9E1B4C10-0002-4A00-9C00-000000000005"
  bundleId = "net.kovidgoyal.kitty"
  initialContainerPrimarySpan = 0.5
  minWidth = 90.0
  minHeight = 48.0

  [[appRules]]
  id = "9E1B4C10-0002-4A00-9C00-000000000006"
  bundleId = "app.zen-browser.zen"
  minWidth = 500.0
  minHeight = 495.0

  [[appRules]]
  id = "9E1B4C10-0002-4A00-9C00-000000000007"
  bundleId = "com.google.Chrome"
  minWidth = 500.0
  minHeight = 375.0

  [[appRules]]
  id = "9E1B4C10-0002-4A00-9C00-000000000008"
  bundleId = "com.spotify.client"
  minWidth = 800.0
  minHeight = 600.0

  [[appRules]]
  id = "9E1B4C10-0002-4A00-9C00-000000000009"
  bundleId = "com.tinyspeck.slackmacgap"
  minWidth = 800.0
  minHeight = 500.0
''
