{
  programs.firefox = {
    enable = true;
    profiles.hedonicadapter = {
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      search.engines = {
        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              {
                name = "type";
                value = "packages";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }];

          icon =
            "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" ];
        };
      };
      search.force = true;

      userContent = ''
        /* Hide Personalize new tab */
        @-moz-document url("about:home"),url("about:newtab"),url("about:blank") {
          .personalize-button {
            display: none !important;
          }
        }

        ::selection {
          background-color: #2B2D42 !important;
          color: #87afaf !important;
        }
      '';
      userChrome = ''
                 /* Firefox Beta v 0.0.1 */
                 /* Source: https://github.com/BLACK4585/Firefox-Beta */
                 /* based on: https://github.com/Tagggar/Firefox-Alpha/ */
                 /* @import url("firefox-csshacks-master/chrome/autohide_bookmarks_and_main_toolbars.css"); */

                 .unified-extensions-item {
                   position: relative !important;
                   top: 23px !important;
                   left: 170px !important;
                   z-index: 2 !important;
                 }

                 #fxa-toolbar-menu-button {
                   position: relative !important;
                   top: 23px !important;
                   left: 170px !important;
                   z-index: 2 !important;
                 }

                 #unified-extensions-button {
                   position: relative !important;
                   top: 23px !important;
                   left: 170px !important;
                   z-index: 2 !important;
                 }

                 #nav-bar:not([urlbar-exceeds-toolbar-bounds]) {
                   overflow: visible !important;
                 }


                 :root {
                   --6: 5px;
                   --8: 8px;
                   --tab-min-height: 22px !important;
                   --tab-min-width: 24px !important;
                   --toolbarbutton-border-radius: var(--6) !important;
                   --tab-border-radius: var(--6) !important;
                   --main: #77777770;
                   --item: #77777730;
                   --grey: #bdae93;
                   --lightgrey: #ddc7a1;
                   --red: #ff000070;
                   --toolbarbutton-hover-background: transparent !important;
                   --toolbarbutton-active-background: transparent !important;
                 }

                 browser {
                    border-radius: var(--tab-browser-radius) !important;
                 }

                 /* Clean UI */
                 * {
                   border: none !important;
                 }
                 #TabsToolbar #firefox-view-button[open] > .toolbarbutton-icon, #tabbrowser-tabs:not([noshadowfortests]) .tab-background:is([selected], [multiselected]) {
                    box-shadow: none !important;
                 }

                ::selection {
                  background-color: #2B2D42 !important;
                  color: #87afaf !important;
                }

                 /* Customization Panel Fix */
                 #customization-panelWrapper > .panel-arrowbox > .panel-arrow {
                   margin-inline-end: initial !important;
                 }

                 /* Video Background Fix */
                 video {
                   background-color: #292828 !important;
                 }

                 /* ❌ Hide Items ❌ */
                 /* ❌ Tooltips ❌ */
                 tooltip,

                 /* ❌ Empty Space */
                 spacer,.titlebar-spacer,

                 /* ❌ Tab List */
                 #alltabs-button,

                 /* ❌ Extensions Menu
                 #unified-extensions-button,

                 /* ❌ #PanelUI-button */
                 #PanelUI-menu-button,

                 /* ❌ Titlebar Window Controls 
                 .titlebar-buttonbox-container,

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
                 #urlbar-zoom-button,#tracking-protection-icon-container,#identity-box,

                 /* ❌ Bookmark Folder Icons */
                 #PlacesToolbar .bookmark-item:not([label=""]) > .toolbarbutton-icon,

                 /* ❌ Bookmarks [>] Button */
                 #PlacesChevron,

                 /* ❌ Tab Icon Overlay */
                 .tab-icon-overlay,

                 /* ❌ Tab Mute Icon */
                 .tab-icon-sound-label,
                 .tab-icon-overlay:not([muted]):is([soundplaying]),

                 /* ❌ Tab Close Btn
                 .tab-close-button:not([selected]),

                 /* ❌ Tab Pinned Text */
                 .tab-label-container[pinned],

                 /* ❌ New Tab logo */
                 .tabbrowser-tab[label="New Tab"] .tab-icon-image,

                 /* ❌ Findbar Checkboxes */
                 .findbar-container > checkbox,

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
                   font-weight: 600 !important;
                   padding-inline: var(--6) !important;
                   border-radius: var(--6) !important;
                   margin: var(--8) !important;
                   background-color: #4c7a5d !important;
                 }

                 /* ℹ️ Findbar Ctrl+F */
                 findbar {
                   padding: 0 !important;
                   margin: 0 8px !important;
                   border-radius: var(--6) !important;
                   width: 240px;
                   background: var(--grey) !important;
                   order: -1;
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
                   color: #292828 !important;
                   background: none !important;
                 }
                 findbar toolbarbutton {
                   width: 24px;
                   padding: 4px !important;
                   margin: 0 !important;
                   background: none !important;
                   fill: #292828 !important;
                   scale: 0.7;
                 }

                 /* *️⃣ Menu *️⃣ */
                 /* *️⃣ Toolbar Menu Alt */
                 #toolbar-menubar[autohide="true"][inactive="true"] {
                   height: 0 !important;
                   margin: 0 !important;
                 }

                 #toolbar-menubar {
                   height: 24px !important;
                   border-radius: var(--6);
                   background-color: var(--grey);
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
                   color: #292828;
                   height: 16px !important;
                 }

                 #scrollbutton-down, #scrollbutton-up {
                   display: none !important;
                 }
                 /* *️⃣ Menu Popup Box */
                 .menupopup-arrowscrollbox {
                   border-radius: var(--8) !important;
                   padding: var(--6) !important;
                   background-color: var(--grey) !important;
                   color: #292828 !important;
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
                 }
                 .menu-accel {
                   margin-inline: var(--6) 0 !important;
                 }

                 /* ⬅️➡️🔄️ Context Nav Text Buttons*/
                 menuitem[_moz-menuactive="true"]:not([disabled]),
                 menupopup > menuitem[_moz-menuactive],
                 menupopup > menu[_moz-menuactive] {
                   background-color: var(--main) !important;
                   color: #292828 !important;  
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
                #tabbrowser-tabs{
                 padding-top:4px !important;
                }
                 #tabbrowser-tabs > * {
                   padding-top: 3px !important;
                   padding-bottom: 2px !important;
                   padding-inline:5px !important;
                 }
                 :root:not([customizing]) #titlebar {
                   margin-bottom: -24px;
                 }

                 .tabbrowser-tab {
                    --tab-label-mask-size: 1.5em !important;
                    position:relative;
                    border-radius:var(--tab-border-radius);
                    margin: -2px 1px !important;
                 }
                 .tabbrowser-tab[fadein]:not([selected]):not([pinned]) {
                   width: clamp(160px, 10vw, 200px) !important;
                 }
                 .tabbrowser-tab .tab-background:not([selected]) {
                 }
                 .tab-label-container:not([selected]) {
                   opacity: 0.5 !important;
                 }
                 .tab-content {
                   padding-inline: 6px !important;
                 }
                 .tab-text {
                   color: #fbf1c7 !important;
                   mix-blend-mode: exclusion !important;
                 }

                 /* Tabs [Selected] */
                 .tabbrowser-tab[selected][fadein]:not([pinned]) {
                   width: clamp(300px, 18vw, 500px) !important;
                 }
                 .tabbrowser-tab:not([pinned]) {
                    transition: opacity 150ms ease-out !important;
                 }
                 .tabbrowser-tab[selected] {
                    min-width:max-content !important;
                   box-shadow: none !important;
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
                   background-color: var(--red) !important;
                   transition: background-color 0.15s ease-out !important;
                 }
                 .tabbrowser-tab:is([soundplaying]){
                    opacity:1 !important;
                 }

                 /* Tabs Audio Favicon */
                 .tab-icon-stack:not([pinned], [sharing], [crashed]):is([soundplaying], [muted])
                   > :not(.tab-icon-overlay) {
                   opacity: 1 !important;
                 }

                 /* Tab Close on hover */
                 tab:not([pinned]):hover .tab-close-button {
                   display: flex !important;
                   opacity: 1;
                 }
                 .tab-close-button {
                   margin: -6px !important;
                   opacity: 0;
                   background-color: transparent !important;
                   transition: opacity 0.15s ease-out !important;
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
                   color: var(--grey) !important;
                   height: var(--tab-min-height);
                 }



                 /* 🔗 URLBAR Inbut https: */
                 #urlbar-input {
                   transition: transform 0.1s linear;
                   transform: none !important;
                   font-size: 1rem !important;
                   color: var(--lightgrey) !important;
                   padding-inline: 0px !important;
                 }

                 /* 📐 URLBAR in Tab */
                 /* Source: https://github.com/MrOtherGuy/firefox-csshacks/.../selected_tab_as_urlbar.css */

                 #urlbar-input-container > :not(.urlbar-input-box) {
                   opacity: 0;
                 }
                 #urlbar-background {
                   background: none !important;
                 }
                 #main-window > body > box {
                   z-index: 1;
                 }
                 .urlbar-input-box {
                   z-index: -1 !important;
                 }
                 .urlbarView {
                   background: rgba(48,49,52,0.8);
                   backdrop-filter: blur(10px) !important;
                   z-index: 1;
                   padding: var(--6);
                   border-radius: var(--6);
                   left: 50vw;
                   width: clamp(500px, 60%, 700px) !important;
                   transform: translateX(-50%) !important;
                 }
                 #nav-bar {
                   height: var(--tab-min-height) !important;
                   background-color: transparent !important;
                 }

                 /* 📐 Click Tab to Focus Urlbar */
                 /* Source: https://github.com/MrOtherGuy/firefox-csshacks/.../click_selected_tab_to_focus_urlbar.css*/

                 .tabbrowser-tab:not([selected]):hover {
                    opacity:1 !important;
                    overflow:visible !important;
                 }
                 .tab-stack {
                    transition: max-width 150ms ease-out !important;
                    position:relative;
                    top:0;
                    left:0;
                    right:0;
                 }
                 .tabbrowser-tab:not([selected]):hover .tab-stack {
                    min-width:max-content !important;
                    position:absolute;
                    z-index:6;
                 }
                 .tab-background {
                    outline: 1px solid transparent;
                    transition: background-color 150ms ease-out, outline-color 150ms ease-out !important;
                    transition-delay: 0.1s;
                 }
                 .tabbrowser-tab:hover .tab-background {
                    background-color: var(--lwt-accent-color) !important; 
                    overflow: visible !important;
                    outline-color: var(--main) !important;
                    border-radius:var(--tab-border-radius); }

                .tabbrowser-tab:not([selected]){
                  opacity:0.5;
                  transition: min-width 250ms ease-out, max-width 250ms ease-out, opacity 150ms ease-out !important;
                }
                 /* Make selected tab unclickable => click > capture box */
                 .tabbrowser-tab:not([pinned])[selected] {
                   pointer-events: none;
                 }

                 /* Restore pointer-events for usability */
                 #TabsToolbar toolbarbutton,
                 #TabsToolbar toolbaritem,
                 .tabbrowser-tab,
                 .tab-close-button,
                 .tab-icon-stack {
                   pointer-events: auto;
                 }


        #urlbar {
          position: fixed !important;
          top: 50% !important;
          left: 50% !important;
          transform: translate(-50%, -50%) !important;
          z-index: 1 !important;
          height: 100%;
          margin-top: 0;
          margin-bottom: auto;
          pointer-events: none;
        }

        #urlbar[breakout][breakout-extend] {
          top: var(--urlbar-toolbar-height) !important;
          left: 0 !important;
          width: 100% !important;
          transform: none !important;
          box-shadow: none !important;
          border-radius: 0 !important;
        }

                 /* Capture box: click to focus urlbar */
                 :root:not([customizing]) #urlbar-input-container::before {
                   position: fixed;
                   display: flex;
                   flex: 1;
                   height: var(--tab-min-height);
                   width: 100%;
                   top: var(--8);
                   bottom: var(--8);
                   content: "";
                 }
                 #urlbar-input-container{
                  margin-top: 0;
                  margin-bottom: auto;
                 }
                 #urlbar-input-container:focus-within::before {
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

                 /* 🪟 Drag Window from urlbar */
                 .urlbar-input-box,
                 #urlbar-input,
                 #urlbar-scheme,
                 #urlbar-container
                 #navigator-toolbox {
                   -moz-window-dragging: drag;
                   cursor: default;
                 }

                 /* ⬇️ Downloads Indicator */
                 #downloads-button {
                   position: fixed !important;
                   top: 0 !important;
                   right: 0px !important; 
                   width: var(--tab-min-height);
                   z-index: 1;
                 }
                 #downloads-indicator-progress-outer {
                   position: fixed !important;
                   align-items: end !important;
                   top: var(--8) !important;
                   right: 0px !important;
                   left: auto !important;
                   width: var(--6) !important;
                   height: var(--tab-min-height) !important;
                   border-radius: var(--6) !important;
                   background: var(--item);
                   visibility: visible !important;
                   border: 1px solid #fbf1c7 !important;
                   margin-right: 8px;
                 }
                 #downloads-indicator-progress-inner {
                   background: url("data:image/svg+xml;charset=UTF-8,%3csvg width='10' height='24' xmlns='http://www.w3.org/2000/svg'%3e%3crect width='10' height='24' fill='dodgerblue'/%3e%3c/svg%3e") bottom no-repeat !important;
                   height: var(--download-progress-pcent) !important;
                   border-radius: var(--6) !important;
                 }
                 #downloads-button[attention="success"] #downloads-indicator-progress-outer {
                   background: #a9b665 !important;
                 }
                 #downloads-button:is([attention="warning"], [attention="severe"])
                   #downloads-indicator-progress-inner {
                   background: #ea6962 !important;
                   height: var(--8) !important;
                 }

                 /* ⬇️ Downloads Panel */
                 #downloadsPanel {
                   position: fixed !important;
                   margin: 4px var(--6) !important;
                 }
                 #downloadsPanel-mainView {
                   background-color: #2b2a33 !important;
                   color: #fbf1c7;
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

                 /* Search Suggestions Fix*/
                 #urlbar-container #urlbar-input-container {
                  transition: opacity 0.15s ease-out;
                   opacity: 0;
                 }
                  #urlbar-container:focus-within #urlbar-input-container {
                    opacity: 1;
                  }

                 .urlbarView {
                   background-color: var(--lwt-accent-color); /* Pop-up background color (adaptive) */
                   color: #fbf1c7 !important;
                 }
      '';
    };
  };
}
