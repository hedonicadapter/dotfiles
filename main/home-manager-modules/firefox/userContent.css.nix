{outputs, ...}: let
  css = ''
    /* Hide Personalize new tab */
    @-moz-document url("about:home"),url("about:newtab"),url("about:blank") {
      .personalize-button {
        display: none !important;
      }
    }

    html, body {
      border-radius: 1px !important;
    }

    * {
      border-radius: 1px !important;
      transition-duration: 0.15s;
      transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
      transition-property: all;
    }

    /* new tab */
    .search-handoff-button {
    }

    /* google */
    .sfbg
    }
    #appbar {
    }
    .RNNXgb {
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
    }
    #chips-wrapper.ytd-feed-filter-chip-bar-renderer,
    ytd-feed-filter-chip-bar-renderer[is-dark-theme]
      #right-arrow.ytd-feed-filter-chip-bar-renderer::before,
    #right-arrow.ytd-feed-filter-chip-bar-renderer::before {
    }
    .ytd-searchbox,
    #search-icon-legacy.ytd-searchbox {
    }

    /* twitch */
    .top-nav__menu {
    }
    .channel-root,
    .channel-root__info .channel-info-content {
    }
    .user-menu-toggle > div,
    .eKDZrJ {
    }
    .side-nav,
    .side-nav-expanded {
    }
    nav > div {
      box-shadow: none !important;
    }
    input[type="search"] {
    }
    .stream-chat,
    .stream-chat-header,
    .chat-room,
    .Layout-sc-1xcs6mc-0 jWHzQH {
    }
    :root {
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
    }
    .bg-neutral-background {
    }
    .reddit-search-bar {
    }
    reddit-sidebar-nav {
    }
    shreddit-post {
    }
  '';
in
  css
