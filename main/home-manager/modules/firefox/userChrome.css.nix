{outputs, ...}: let
  css = ''
        url(about:newtab) > *, url(about:home) > * {
          display:none !important;
        }
        #navigator-toolbox {
        }
        /* Firefox Alpha v 1.1.0 */
        /* Source: https://github.com/Tagggar/Firefox-Alpha/ */
        html > * {
          background-color: transparent;
          color: ${outputs.colors.base07};
        }
        html {
          color: ${outputs.colors.base07};
        }
        #browser > #appcontent {
          margin: 6px;
          border-radius: 1px;
        }
        :root {
          --6: 4px;
          --8: 8px;
          --tab-min-height: 18px !important;
          --tab-min-width: 25px !important;
          --toolbarbutton-border-radius: 1px !important;
          --tab-border-radius: 1px !important;
          --main: rgba(255, 255, 255, 0.1);
          --item: #7c797930;
          --easink: cubic-bezier(0, 0, 0.58, 1);
          --urlbarView-icon-margin-start: 4px!important;
          --urlbar-container-height: 0!important;

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
          border-radius: 1px !important;
          margin: var(--8) !important;
          background-color: ${outputs.colors.base00} !important;
          color: ${outputs.colors.base07} !important;
        }

        /* ℹ️ Findbar Ctrl+F */
        findbar {
          padding: 0 !important;
          margin: 0 8px !important;
          border-radius: 1px !important;
          width: 240px;
          background: ${outputs.colors.base01} !important;
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
          color: ${outputs.colors.base07} !important;
          background: none !important;
        }
        findbar toolbarbutton {
          width: 25px;
          padding: 4px !important;
          margin: 0 !important;
          background: none !important;
          fill: ${outputs.colors.base07} !important;
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
          border-radius: 1px;
          background-color: transparent;
          position: relative;
          margin: var(--6) var(--6) 0 var(--6);
          z-index: 3;
        }

        /* *️⃣ Toolbar Menu Item */
        menu[_moz-menuactive="true"]:not([disabled="true"]),
        menucaption[_moz-menuactive="true"]:not([disabled="true"]) {
          background-color: var(--main) !important;
          border-radius: 1px;
        }
        #main-menubar {
          margin: 4px;
          background-color: none;
          color: ${outputs.colors.base00};
          height: 16px !important;
        }

        /* *️⃣ Menu Popup Box */
        .menupopup-arrowscrollbox {
          border-radius: 1px !important;
          padding: var(--6) !important;
          background-color: ${outputs.colors.base01} !important;
          color: ${outputs.colors.base07} !important;
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
          border-radius: 1px !important;
          padding-inline: var(--6) !important;
          margin: 0 !important;
          color: ${outputs.colors.base01} !important;
        }
        .menu-accel {
          margin-inline: var(--6) 0 !important;
        }

        /* ⬅️➡️🔄️ Context Nav Text Buttons*/
        menuitem[_moz-menuactive="true"]:not([disabled]),
        menupopup > menuitem[_moz-menuactive],
        menupopup > menu[_moz-menuactive] {
          background-color: var(--main) !important;
          color: ${outputs.colors.base07} !important;
        }
        #context-navigation {
          flex-direction: column !important;
        }
        #context-navigation > menuitem::before {
          content: attr(aria-label);
        }
        #context-navigation > menuitem {
          justify-content: start !important;
          border-radius: 1px !important;
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
          padding: 1px !important;
          margin: 1px !important;
        }
        tab {
          padding:0;
        }
        :root:not([customizing]) #titlebar {
          margin-bottom: -25px;
        }

        .tabbrowser-tab .tab-background:not([selected]) {
          background: var(--item) !important;
        }
        .tab-content {
          padding-inline: var(--6) !important;
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
          background-color: ${outputs.colors.base08} !important;
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
          color: ${outputs.colors.base07} !important;
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
          color: ${outputs.colors.base01} !important;
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
          border-radius: 1px !important;
          background: var(--item);
          visibility: visible !important;
        }
        #downloads-indicator-progress-inner {
          background: url("data:image/svg+xml;charset=UTF-8,%3csvg width='6' height='25' xmlns='http://www.w3.org/2000/svg'%3e%3crect width='6' height='25' fill='${outputs.colors.base0D}'/%3e%3c/svg%3e")
            bottom no-repeat !important;
          height: var(--download-progress-pcent) !important;
          border-radius: 1px !important;
        }
        #downloads-button[attention="success"] #downloads-indicator-progress-outer {
          background: ${outputs.colors.base0D} !important;
        }
        #downloads-button:is([attention="warning"], [attention="severe"])
          #downloads-indicator-progress-inner {
          background: ${outputs.colors.base09} !important;
          height: var(--8) !important;
        }

        /* ⬇️ Downloads Panel */
        #downloadsPanel {
          position: fixed !important;
          margin: 4px var(--6) !important;
        }
        #downloadsPanel-mainView {
          background-color: ${outputs.colors.base01} !important;
          color: ${outputs.colors.base00};
          padding: var(--6) !important;
        }
        #downloadsFooterButtons > button,
        #downloadsListBox > richlistitem {
          min-height: var(--tab-min-height) !important;
          padding: 0 0 0 var(--6) !important;
          margin: 0 !important;
          border-radius: 1px !important;
        }
        #downloadsListBox > richlistitem * {
          padding: 0 !important;
          margin: 0 !important;
          padding-block: 0 !important;
          border-radius: 1px !important;
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
          transition:
            background-color 150ms !important;
          transition-timing-function: var(--easink) !important;
          transition-delay: 0.1s;
          margin-block: 1px !important;
          outline-offset: 0 !important;
          border-radius: 1px;
        }
        .tabbrowser-tab:hover .tab-background {
          background-color: ${outputs.colors.base00} !important;
          overflow: visible !important;
        }

        #tabbrowser-arrowscrollbox {
          flex-direction: row !important;
          flex-wrap: wrap;
          display:flex !important;
        }

        .tabbrowser-tab {
          position: relative;
          overflow: hidden !important;
          width:20vw;
          max-width:70px!important;
          font-weight: bold !important;
        }

        .tab-label-container {
          #tabbrowser-tabs:not([secondarytext-unsupported]) & {
            height: 1.3em !important;
          }
        }

        .tabbrowser-tab:not([pinned]) {
          transition: all 0.25s !important;
          transition-timing-function: var(--easink) !important;
          opacity: 0.6;
        }

        .tabbrowser-tab[selected] {
          max-width: 300px!important;
          opacity: 1 !important;
          color: var(--tab-selected-bgcolor)!important;
          text-transform: uppercase;
        }
        .tabbrowser-tab[selected] .tab-background {
            background-color: var(--tab-selected-textcolor) !important;
        }

        /* Source file https://github.com/MrOtherGuy/firefox-csshacks/tree/master/chrome/navbar_below_content.css made available under Mozilla Public License v. 2.0
        See the above repository for updates as well as full license text. */

        /* Moves the main toolbar (#nav-bar) to the bottom of the window */

        @-moz-document url(chrome://browser/content/browser.xhtml){

          :root:not([inFullscreen]){
            --uc-bottom-toolbar-height: calc(29px + var(--toolbarbutton-outer-padding) )
          }

      :root[uidensity="compact"]:not([inFullscreen]){
            --uc-bottom-toolbar-height: calc(22px + var(--toolbarbutton-outer-padding) )
          }

          #nav-bar{
            position: fixed !important;
            bottom: 0px;
            /* For some reason -webkit-box behaves internally like -moz-box, but can be used with fixed position. display: flex would work too but it breaks extension menus. */
            display: -webkit-box;
            width: 100%;
            z-index: 1;
          }
          #nav-bar-customization-target{ -webkit-box-flex: 1; }

          /* Fix panels sizing */
          .panel-viewstack{ max-height: unset !important; }

          #urlbar[breakout][breakout-extend]{
            display: flex !important;
            flex-direction: column-reverse;
            bottom: 0px !important; /* Change to 3-5 px if using compact_urlbar_megabar.css depending on toolbar density */
            top: auto !important;
          }

          #urlbar[breakout] {
            bottom:0!important;
          }

          .urlbarView-body-inner{ border-top-style: none !important; }
    }
    .browser-toolbar{
      background:transparent!important;
    }
    #identity-permission-box {
      display: none!important;
    }

    .urlbarView-row {
      &:not([type="tip"], [type="dynamic"]) {
        :root[uidensity="touch"] & {
          padding-block: 0!important;
        }
      }
    }
    .urlbarView-row-inner {
      padding-block: 0!important;
    }
    .urlbarView-row {
      &:not([type="tip"], [type="dynamic"]) {
        :root:not([uidensity="compact"]) & {
          min-height: 23px!important;
        }
      }
    }
    .urlbarView {
      display: flex !important;
      flex-direction: column-reverse !important;
      margin-inline:0 !important;
    }
    :root[uidensity="touch"] #urlbar .search-one-offs:not([hidden]), #urlbar .search-one-offs:not([hidden]){
      padding-block: 0!important;
    }
    .searchbar-engine-one-off-item > .button-box > .button-icon {
      width: 14px!important;
      height: 14px!important;
    }
    #urlbar .searchbar-engine-one-off-item {
      margin-inline: 0!important;
    }
    .searchbar-engine-one-off-item {
      margin-inline-end: 0!important;
    }
    button {
      margin: 1px 1px 0px!important;
    }
    .urlbarView-title-separator, .urlbarView-action {
      display: none;
    }
    #urlbar:not([open]) #urlbar-results {
      display: flex!important;
      flex-direction: column-reverse!important;
    }
    .urlbarView-row[dynamicType=onboardTabToSearch] {
      display: none !important;
    }
    .search-one-offs {
      display: none !important;
    }
    #urlbar-container, #search-container {
      margin-inline:0!important;
    }
    #urlbar {
      flex-direction:column-reverse !important;
    }
    #urlbar-results {
      padding-block: 0 !important;
    }
    .urlbarView-row[type="search"]{
      display:none!important;
    }
    #urlbar[breakout][breakout-extend] {
      & > .urlbar-input-container {
        padding-block: 0 !important;
      }
    }
    .urlbarView-row[label] {
      margin-block-start: 0 !important;
    }
    .urlbarView-favicon {
      margin-inline-end: 5px !important;
    }
    @media (-moz-bool-pref: "browser.urlbar.richSuggestions.featureGate") {
      #identity-box[pageproxystate="invalid"] > .identity-box-button, #identity-icon-box {
        padding-left: 6px !important;
        padding-right: 0px !important;
      }
    }
  '';
in
  css
