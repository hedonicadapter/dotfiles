{outputs, ...}: let
  css = ''
    /* Hide Personalize new tab */
    @-moz-document url("about:home"),url("about:newtab"),url("about:blank") {
      .personalize-button {
        display: none !important;
      }
    }

    html {
      background: rgba(0, 0, 0, 0) !important;
      color: ${outputs.colors.white};
    }
    body {
      background: none !important;
      color: ${outputs.colors.white};
    }
    * {
      border-radius: 0.5rem;
      transition-duration: 0.15s;
      transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
      transition-property: all;
    }

    /* new tab */
    .search-handoff-button {
      background: rgba(0, 0, 0, 0.25) !important;
    }

    /* google */
    .sfbg {
      background: rgba(0, 0, 0, 0) !important;
    }
    #appbar {
      background: rgba(0, 0, 0, 0) !important;
    }
    .RNNXgb {
      background: rgba(0, 0, 0, 0) !important;
    }

    /* youtube */
    #contentContainer,
    #guide-content,
    ytd-app,
    ytd-mini-guide-renderer,
    ytd-mini-guide-entry-renderer,
    ytd-masthead #background,
    .ytd-searchbox,
    ytd-watch-flexy,
    .ytd-watch-flexy {
      background: rgba(0, 0, 0, 0) !important;
    }
    #chips-wrapper.ytd-feed-filter-chip-bar-renderer,
    ytd-feed-filter-chip-bar-renderer[is-dark-theme]
      #right-arrow.ytd-feed-filter-chip-bar-renderer::before,
    #right-arrow.ytd-feed-filter-chip-bar-renderer::before {
      background: rgba(0, 0, 0, 0) !important;
    }
    .ytd-searchbox,
    #search-icon-legacy.ytd-searchbox {
      border-color: transparent !important;
    }

    /* twitch */
    .top-nav__menu {
      background: rgba(0, 0, 0, 0) !important;
    }
    .channel-root,
    .channel-root__info .channel-info-content {
      background: rgba(0, 0, 0, 0) !important;
    }
    .user-menu-toggle > div,
    .eKDZrJ {
      background: transparent !important;
    }
    .side-nav,
    .side-nav-expanded {
      background: transparent !important;
    }
    nav > div {
      box-shadow: none !important;
    }
    input[type="search"] {
      background: transparent !important;
    }
    .stream-chat,
    .stream-chat-header,
    .chat-room,
    .Layout-sc-1xcs6mc-0 jWHzQH {
      background: transparent !important;
    }
    :root {
      --color-background-body: transparent !important;
    }

    /*reddit*/
    :root.theme-dark .sidebar-grid,
    :root.theme-dark .grid-container.grid,
    :root.theme-dark
      .sidebar-grid
      .theme-beta:not(.stickied):not(#left-sidebar-container):not(
        .left-sidebar-container
      ),
    :root.theme-dark
      .sidebar-grid
      .theme-rpl:not(.stickied):not(#left-sidebar-container):not(
        .left-sidebar-container
      ),
    :root.theme-dark
      .grid-container.grid
      .theme-beta:not(.stickied):not(#left-sidebar-container):not(
        .left-sidebar-container
      ),
    :root.theme-dark
      .grid-container.grid
      .theme-rpl:not(.stickied):not(#left-sidebar-container):not(
        .left-sidebar-container
      ) {
      background: rgba(0, 0, 0, 0) !important;
    }
    .bg-neutral-background {
      background: transparent !important;
    }
    .reddit-search-bar {
      background: transparent !important;
    }
    reddit-sidebar-nav {
      background: transparent !important;
    }
    shreddit-post {
      background: transparent !important;
    }
  '';
in
  css
