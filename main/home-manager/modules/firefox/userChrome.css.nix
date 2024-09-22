{outputs, ...}: let
  css = ''
    #navigator-toolbox {
      background: rgba(0, 0, 0, 0) !important;
    }
    /* Firefox Alpha v 1.1.0 */
    /* Source: https://github.com/Tagggar/Firefox-Alpha/ */
    html > * {
      background-color: ${outputs.transparentize outputs.colors.black 0.4};
    }
    html {
      background: rgba(0, 0, 0, 0);
    }
    #browser > #appcontent {
      margin: 6px;
      border-radius: 7px;
    }
    :root {
      --6: 4px;
      --8: 8px;
      --tab-min-height: 25px !important;
      --tab-min-width: 25px !important;
      --toolbarbutton-border-radius: var(--6) !important;
      --tab-border-radius: var(--6) !important;
      --main: rgba(255, 255, 255, 0.1);
      --item: #7c797930;
      --easink: cubic-bezier(0, 0, 0.58, 1);

      --toolbarbutton-hover-background: transparent !important;
      --toolbarbutton-active-background: transparent !important;
      --tabpanel-background-color: rgba(0, 0, 0, 0) !important;
      --tab-selected-bgcolor: ${outputs.transparentize outputs.colors.grey 0.4} !important;
      background: rgba(0, 0, 0, 0) !important;
    }

    /* Clean UI */
    * {
      outline-color: transparent !important;
      box-shadow: none !important;
      border: none !important;
    }

    /* Customization Panel Fix */
    #customization-panelWrapper > .panel-arrowbox > .panel-arrow {
      margin-inline-end: initial !important;
    }

    /* Video Background Fix */
    video {
      background-color: transparent !important;
    }

    /* ❌ Hide Items ❌ */
    /* ❌ Tooltips ❌ */
    /* tooltip, */

    /* ❌ Empty Space */
    spacer,.titlebar-spacer,

              /* ❌ Tab List */
              #alltabs-button,

              /* ❌ Extensions Menu */
              #unified-extensions-button,

              /* ❌ #PanelUI-button */
              #PanelUI-menu-button,

              /* ❌ Titlebar Window Controls */
              /* .titlebar-buttonbox-container, */

              /* ❌ Navigation Buttons */
              #back-button, #forward-button, #reload-button, #stop-reload-button,

              /* ❌ Menu Icons __ menuitem > .menu-iconic-left, */
               menu > .menu-iconic-left, .menu-right,

              /* ❌ Menu Separator */
              menuseparator, toolbarseparator,

              /* ❌ Menu Disabled */
              menuitem[disabled], menu[disabled],

              /* ❌ Overflow Icon */
              #nav-bar-overflow-button,

              /* ❌ url-bar Icons */
              #urlbar-zoom-button,#tracking-protection-icon-container,.identity-box,

              /* ❌ Bookmark Folder Icons */
              #PlacesToolbar .bookmark-item:not([label=""]) > .toolbarbutton-icon,

              /* ❌ Bookmarks [>] Button */
              #PlacesChevron,

              /* ❌ Tab Icon Overlay */
              .tab-icon-overlay,

              /* ❌ Tab Mute Icon */
              .tab-icon-sound-label,
              .tab-icon-overlay:not([muted]):is([soundplaying]),

              /* ❌ Tab Close Btn */
              .tab-close-button

              /* ❌ Tab Pinned Text */
              .tab-label-container[pinned],

              /* ❌ New Tab logo */
              /* .tabbrowser-tab[label="New Tab"] .tab-icon-image, */

              /* ❌ Findbar Checkboxes */
              /* .findbar-container > checkbox, */

              /* ❌ Menu Icons */
              #contentAreaContextMenu > menuitem > .menu-iconic-left,
              #context-navigation > menuitem > .menu-iconic-left,

              /* ❌ Downloads Icons */
              .downloadTypeIcon,
              #downloads-button > .toolbarbutton-badge-stack > .toolbarbutton-badge,
              :root:not([customizing]) #downloads-indicator-icon,
              #downloads-indicator-start-box, #downloads-indicator-start-image > *,
              #downloads-indicator-finish-box, #downloads-indicator-finish-image > *,

              /* ❌ Private Indicator */
              .private-browsing-indicator {
      display: none !important;
      -moz-user-focus: none;
    }

    /* 🔗 Status Panel [Url Popup] */
    #statuspanel #statuspanel-label {
      font-weight: 500 !important;
      padding-inline: var(--6) !important;
      padding-block: 2px !important;
      border-radius: var(--6) !important;
      margin: var(--8) !important;
      background-color: ${outputs.colors.black} !important;
      color: ${outputs.colors.white} !important;
    }

    /* ℹ️ Findbar Ctrl+F */
    findbar {
      padding: 0 !important;
      margin: 0 8px !important;
      border-radius: var(--6) !important;
      width: 240px;
      background: ${outputs.colors.grey} !important;
      order: -1;
      position: absolute;
    }
    .findbar-container {
      padding: 0 !important;
      margin: 0 !important;
      height: var(--tab-min-height) !important;
    }
    .findbar-textbox {
      width: 168px !important;
      padding-inline: var(--6) !important;
      height: var(--tab-min-height) !important;
      color: ${outputs.colors.white} !important;
      background: none !important;
    }
    findbar toolbarbutton {
      width: 25px;
      padding: 4px !important;
      margin: 0 !important;
      background: none !important;
      fill: ${outputs.colors.white} !important;
      scale: 0.7;
    }

    /* *️⃣ Menu *️⃣ */
    /* *️⃣ Toolbar Menu Alt */
    #toolbar-menubar[autohide="true"][inactive="true"] {
      height: 0 !important;
      margin: 0 !important;
    }

    #toolbar-menubar {
      height: 25px !important;
      border-radius: var(--6);
      background-color: transparent;
      position: relative;
      margin: var(--6) var(--6) 0 var(--6);
      z-index: 3;
    }

    /* *️⃣ Toolbar Menu Item */
    menu[_moz-menuactive="true"]:not([disabled="true"]),
    menucaption[_moz-menuactive="true"]:not([disabled="true"]) {
      background-color: var(--main) !important;
      border-radius: 4px;
    }
    #main-menubar {
      margin: 4px;
      background-color: none;
      color: ${outputs.colors.black};
      height: 16px !important;
    }

    /* *️⃣ Menu Popup Box */
    .menupopup-arrowscrollbox {
      border-radius: var(--8) !important;
      padding: var(--6) !important;
      background-color: ${outputs.colors.grey} !important;
      color: ${outputs.colors.white} !important;
    }
    #scrollbutton-down,
    #scrollbutton-up {
      display: none !important;
    }

    /* Menu Position */
    menupopup {
      margin: var(--6) 0 !important;
    }

    #main-menubar menupopup {
      margin: var(--6) var(--8) 0 -8px !important;
    }

    menupopup > menuitem,
    menupopup > menu {
      appearance: none !important;
      max-height: 20px !important;
      min-height: 20px !important;
      border-radius: var(--6) !important;
      padding-inline: var(--6) !important;
      margin: 0 !important;
      color: ${outputs.colors.white_dim} !important;
    }
    .menu-accel {
      margin-inline: var(--6) 0 !important;
    }

    /* ⬅️➡️🔄️ Context Nav Text Buttons*/
    menuitem[_moz-menuactive="true"]:not([disabled]),
    menupopup > menuitem[_moz-menuactive],
    menupopup > menu[_moz-menuactive] {
      background-color: var(--main) !important;
      color: ${outputs.colors.white} !important;
    }
    #context-navigation {
      flex-direction: column !important;
    }
    #context-navigation > menuitem::before {
      content: attr(aria-label);
    }
    #context-navigation > menuitem {
      justify-content: start !important;
      border-radius: var(--6) !important;
      padding-inline: var(--6) !important;
      height: 20px !important;
      width: 100% !important;
    }

    /* ❎ Tabs Multi-row ❎ */
    scrollbox[part][orient="horizontal"] {
      display: flex;
      flex-wrap: wrap !important;
      height: none !important;
    }

    #tabbrowser-tabs > * {
      padding: 3px !important;
      margin: 3px !important;
    }
    tab {
      margin: 0 4px 5px 0 !important;
    }
    :root:not([customizing]) #titlebar {
      margin-bottom: -25px;
    }

    .tabbrowser-tab .tab-background:not([selected]) {
      background: var(--item) !important;
    }
    .tab-content {
      padding-inline: var(--6) !important;
      color: ${outputs.colors.white} !important;
    }

    .tabbrowser-tab .tab-background[selected="true"] {
      background: var(--main) !important;
    }

    /* Tabs [Pinned] */
    .tabbrowser-tab[pinned] {
      width: calc(var(--tab-min-height) + var(--8)) !important;
    }

    /* Tabs Audio */
    #tabbrowser-tabs .tabbrowser-tab:is([soundplaying]) .tab-background {
      background-color: ${outputs.colors.red_dim} !important;
      transition: background-color 0.15s !important;
      transition-timing-function: var(--easink) !important;
    }

    /* Tabs Audio Favicon */
    .tab-icon-stack:not([pinned], [sharing], [crashed]):is([soundplaying], [muted])
      > :not(.tab-icon-overlay) {
      opacity: 1 !important;
    }

    /* Tab Close on hover */
    tab:not([pinned]):hover .tab-close-button {
      display: flex !important;
    }
    .tab-close-button {
      margin: -6px !important;
      opacity: 0.5;
      background-color: transparent !important;
    }

    /* New Tab by MMB on Tabs Toolbar  */
    #tabs-newtab-button,
    #tabbrowser-arrowscrollbox-periphery {
      flex: 1;
      align-items: stretch !important;
      opacity: 0 !important;
      -moz-window-dragging: drag !important;
    }

    /* 🪟 Bookmarks Multi-row  */
    :root[BookmarksToolbarOverlapsBrowser] :where(#PersonalToolbar) {
      height: unset !important;
    }
    #PersonalToolbar {
      padding: 0 !important;
      margin: 0 !important;
      max-height: none !important;
    }
    #PlacesToolbarItems {
      display: flex;
      flex-wrap: wrap;
      padding: 0 var(--6);
    }
    #PlacesToolbarItems > .bookmark-item {
      margin: 0 var(--8) var(--8) 0 !important;
      padding: 0 var(--6) !important;
      background: var(--item) !important;
      color: ${outputs.colors.grey} !important;
      height: var(--tab-min-height);
    }

    /* ⬇️ Downloads Indicator */
    #downloads-button {
      position: fixed !important;
      top: 0 !important;
      right: 0 !important;
      width: var(--tab-min-height);
      z-index: 1;
    }
    #downloads-indicator-progress-outer {
      position: fixed !important;
      align-items: end !important;
      top: var(--8) !important;
      right: var(--8) !important;
      left: auto !important;
      width: var(--6) !important;
      height: var(--tab-min-height) !important;
      border-radius: var(--6) !important;
      background: var(--item);
      visibility: visible !important;
    }
    #downloads-indicator-progress-inner {
      background: url("data:image/svg+xml;charset=UTF-8,%3csvg width='6' height='25' xmlns='http://www.w3.org/2000/svg'%3e%3crect width='6' height='25' fill='${outputs.colors.blue}'/%3e%3c/svg%3e")
        bottom no-repeat !important;
      height: var(--download-progress-pcent) !important;
      border-radius: var(--6) !important;
    }
    #downloads-button[attention="success"] #downloads-indicator-progress-outer {
      background: ${outputs.colors.blue} !important;
    }
    #downloads-button:is([attention="warning"], [attention="severe"])
      #downloads-indicator-progress-inner {
      background: ${outputs.colors.orange} !important;
      height: var(--8) !important;
    }

    /* ⬇️ Downloads Panel */
    #downloadsPanel {
      position: fixed !important;
      margin: 4px var(--6) !important;
    }
    #downloadsPanel-mainView {
      background-color: ${outputs.colors.grey} !important;
      color: ${outputs.colors.black};
      padding: var(--6) !important;
    }
    #downloadsFooterButtons > button,
    #downloadsListBox > richlistitem {
      min-height: var(--tab-min-height) !important;
      padding: 0 0 0 var(--6) !important;
      margin: 0 !important;
      border-radius: var(--6) !important;
    }
    #downloadsListBox > richlistitem * {
      padding: 0 !important;
      margin: 0 !important;
      padding-block: 0 !important;
      border-radius: var(--6) !important;
    }
    #downloadsListBox > richlistitem > .downloadMainArea {
      margin-inline-end: var(--8) !important;
    }

    .tabbrowser-tab:not([selected]):hover {
      opacity: 1 !important;
      overflow: visible !important;
    }
    .tab-stack {
      transition: max-width 150ms !important;
      transition-timing-function: var(--easink) !important;
      position: relative;
      top: 0;
      left: 0;
      right: 0;
    }
    .tabbrowser-tab:not([selected]):hover .tab-stack {
      min-width: max-content !important;
      position: absolute;
      z-index: 6;
    }
    .tab-background {
      outline: 1px solid;
      outline-color: ${outputs.transparentize outputs.colors.white 0.6} !important;
      transition:
        background-color 150ms,
        outline-color 150ms !important;
      transition-timing-function: var(--easink) !important;
      transition-delay: 0.1s;
      margin-block: 1px !important;
      outline-offset: 0 !important;
      border-radius: var(--tab-border-radius);
    }
    .tabbrowser-tab:hover .tab-background {
      background-color: ${outputs.colors.black} !important;
      overflow: visible !important;
    }

    #tabbrowser-arrowscrollbox {
      flex-direction: row !important;
      flex-wrap: wrap;
      align-items: stretch !important;
    }

    .tabbrowser-tab {
      position: relative;
      overflow: hidden !important;
    }

    .tab-label-container {
      #tabbrowser-tabs:not([secondarytext-unsupported]) & {
        height: 2.3em !important;
      }
    }

    .tabbrowser-tab:not([pinned]) {
      /* flex-basis: 10vw !important; */
      max-width: 240px !important;
      width: auto !important;
      transition: all 0.25s !important;
      transition-timing-function: var(--easink) !important;
      opacity: 0.4;
    }

    .tabbrowser-tab[selected] {
      max-width: 35vw !important; /* Set a large enough max-width */
      flex-basis: auto !important;
      width: max-content;
      opacity: 1 !important;
    }
    .tabbrowser-tab[selected] .tab-background {
      outline-color: ${outputs.colors.white} !important;
    }

    /* 📐 URLBAR in Tab */
    /* Source: https://github.com/MrOtherGuy/firefox-csshacks/.../selected_tab_as_urlbar.css */

    #main-window > body > box {
      position: relative;
      z-index: 1;
    }
    .urlbar-input-box {
      z-index: -1 !important;
    }
    #alltabs-button,
    #unified-extensions-button,
    #PanelUI-button,
    #nav-bar-overflow-button {
      z-index: 2;
      position: relative;
    }
    .urlbar-input-container > :not(.urlbar-input-box) {
      opacity: 0;
    }
    #urlbar-background {
      background: none !important;
    }
    #urlbar-container {
      position: static !important;
    }
    .urlbarView {
      background: var(--item);
      z-index: 1;
      padding: var(--6);
      border-radius: var(--6);
      left: 50vw;
      width: max(50vw, 320px) !important;
      transform: translateX(-50%) !important;
    }
    #nav-bar {
      height: var(--tab-min-height) !important;
      background-color: transparent !important;
    }

    /* 📐 Click Tab to Focus Urlbar */
    /* Source: https://github.com/MrOtherGuy/firefox-csshacks/.../click_selected_tab_to_focus_urlbar.css*/

    /* Make selected tab unclickable => click > capture box */
    .tabbrowser-tab:not([pinned])[selected] {
      pointer-events: none;
    }

    /* Retore pointer-events for usability */
    #TabsToolbar toolbarbutton,
    #TabsToolbar toolbaritem,
    .tabbrowser-tab,
    .tab-close-button,
    .tab-icon-stack {
      pointer-events: auto;
    }

    /* Capture box: click to focus urlbar */
    :root:not([customizing]) .urlbar-input-container::before {
      position: fixed;
      display: flex;
      flex: 1;
      height: var(--tab-min-height);
      width: 100%;
      top: var(--8);
      bottom: var(--8);
      content: "";
    }
    .urlbar-input-container:focus-within::before {
      display: none !important;
    }

    /* Tabs over the capture box */
    :root:not([customizing]) #TabsToolbar-customization-target {
      position: relative;
      z-index: 1;
      pointer-events: none;
    }

    /* Tab Focus => Url Select */
    #navigator-toolbox:focus-within
      .tabbrowser-tab:not([pinned])[selected]
      .tab-content {
      opacity: 0;
    }

    /* Tab URL */
    #navigator-toolbox:focus-within .tab-background:not([pinned])[selected] {
      background-position: var(--6) !important;
      background-color: var(--main) !important;
      background-size: auto !important;
      background-image: -moz-element(#urlbar-input) !important;
    }
  '';
in
  css
