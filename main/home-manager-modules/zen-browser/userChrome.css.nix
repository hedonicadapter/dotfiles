{outputs, ...}: let
  global = ''
    :root {
      --toolbarbutton-border-radius: 1px !important;
      --item: #7c797930;
      --easink: cubic-bezier(0, 0, 0.58, 1);
      --urlbarView-icon-margin-start: 4px !important;
      --urlbar-container-height: 0 !important;
      --tab-inline-padding: 4px !important;
    }

    * {
      box-shadow: none !important;
      border-radius: 1px !important;

      --urlbar-height: 32px !important;
      --zen-workspace-indicator-height: 34px !important;
    }
  '';
  removedElements = ''
    #stop-reload-button,
    #forward-button, #back-button,
    #unified-extensions-button,
    #PanelUI-button, /* hamburga menu */
    #tabs-newtab-button,
    #zen-sidebar-top-buttons,
    #zen-sidebar-bottom-buttons
    {
      display: none !important;
      -moz-user-focus: none;
    }
  '';

  tabs = ''
    /* Tabs Audio */
    #tabbrowser-tabs .tabbrowser-tab:is([soundplaying]) .tab-background {
      background-color: ${outputs.palette.base08} !important;
    }

    /* Tab Close on hover */
    tab:not([pinned]):hover .tab-close-button {
      display: flex !important;
    }
    .tab-close-button {
      margin: -6px !important;
      color: ${outputs.palette.base07} !important;
    }

    .tabbrowser-tab:not([selected]):hover {
      opacity: 1 !important;
      overflow: visible !important;
    }

    .tab-background {
      transition:
        background-color 150ms !important;
      transition-timing-function: var(--easink) !important;
      transition-delay: 0.1s;
      margin-block: 1px !important;
      outline-offset: 0 !important;
      border-radius: 1px;
      min-height: 0px !important;
    }

    .tabbrowser-tab:hover .tab-background {
      background-color: ${outputs.palette.base00} !important;
    }

    .tabbrowser-tab:not([pinned]) {
      opacity: 0.6;
    }

    .tabbrowser-tab[selected] {
      opacity: 1 !important;
      color: var(--tab-selected-bgcolor)!important;
      text-transform: uppercase;
    }

    #navigator-toolbox[zen-sidebar-expanded="true"] {
      & #tabbrowser-tabs {
        & .tabbrowser-tab {
          & .tab-background {
            margin-inline: 0 !important;
          }
        }
      }
    }
  '';

  sidebar = ''
    #navigator-toolbox {
      width: 20vw !important;
      max-width: 200px !important;
    }

    .urlbar-input-container {
      padding: 2px;
    }

    #navigator-toolbox[zen-sidebar-expanded="true"] {
      & #nav-bar {
        :root[zen-single-toolbar="true"] & {
          & #urlbar:not([breakout-extend="true"]):not([pageproxystate="invalid"]) .urlbar-input-container {
            padding-left: 5px !imporant;
            padding-right: 4px !imporant;
          }
        }
      }
    }

    #urlbar-container {
      margin-top: 10px !imporant;
    }

    .zen-workspace-tabs-section {
      &:not(.zen-current-workspace-indicator) {
        margin: 0 var(--zen-toolbox-padding) !imporant;
      }
    }
    .zen-current-workspace-indicator {
      padding: 12px calc(2px + var(--tab-inline-padding)) !important;
      min-height: 0 !important;
    }

    ${tabs}
  '';

  contextMenu = ''
    menupopup > menuitem,
    menupopup > menu {
      appearance: none !important;
      max-height: 20px !important;
      min-height: 20px !important;
      border-radius: 1px !important;
      padding-inline: var(--6) !important;
      margin: 0 !important;
      color: ${outputs.palette.base01} !important;
    }
    .menu-accel {
      margin-inline: var(--6) 0 !important;
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

    #context-navigation, menugroup {
      flex-direction: row !important;
    }
    menuitem > *, menuitem {
      margin: 0 !important;
      color: ${outputs.palette.base07};
      font-size: 25px !important;
    }
    menu, menuitem {
      &:where([_moz-menuactive]:not([disabled="true"])) {
        color: ${outputs.palette.base00};
        background-color: ${outputs.palette.base07};
      }
    }
    menuitem[_moz-menuactive]:not([disabled="true"]) > * {
        text-transform: uppercase !important;
    }
    menuitem[_moz-menuactive="true"]:not([disabled]), menuitem[_moz-menuactive="true"]:not([disabled]) > *, menupopup > menuitem[_moz-menuactive], menupopup > menu[_moz-menuactive] {
      background-color: ${outputs.palette.base07} !important;
      color: ${outputs.palette.base00} !important;
    }
    menu, menuitem, menucaption {
      @media (-moz-platform: linux) {
        padding: 0 !important;
      }
    }
  '';

  downloads = ''
    #downloads-button[attention="success"] #downloads-indicator-progress-outer {
      background: ${outputs.palette.base0D} !important;
    }
    #downloads-button:is([attention="warning"], [attention="severe"])
      #downloads-indicator-progress-inner {
      background: ${outputs.palette.base09} !important;
    }
    #downloadsPanel-mainView {
      background-color: ${outputs.palette.base01} !important;
      color: ${outputs.palette.base06};
    }
  '';

  misc = ''
    #browser > #appcontent {
      margin: 6px;
      border-radius: 1px;
    }

    :root:not([inDOMFullscreen="true"]):not([chromehidden~="location"]):not([chromehidden~="toolbar"]) {
      & #zen-tabbox-wrapper {
        margin: 0px !important;
        margin-top: calc(var(--zen-element-separation) *-1) !important;
      }
    }

    .vertical-pinned-tabs-container-separator {
      background: light-dark(${outputs.palette.base04}, ${outputs.palette.base06}) !important;
      height: 1px !important;
    }
    .zen-sidebar-web-panel-splitter, .zen-split-view-splitter[orient="vertical"], #zen-sidebar-splitter {
      background: light-dark(${outputs.palette.base04}, ${outputs.palette.base06}) !important;
      width: 1px !important;
    }

    #zen-sidebar-splitter {
      opacity: 1 !important;
      min-width: 0 !important;
    }

    video {
      background-color: transparent !important;
    }
  '';

  css = ''
    ${global}
    ${removedElements}
    ${sidebar}
    ${contextMenu}
    ${downloads}
    ${misc}
  '';
in
  css
