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

    /* Keep media and embedded content out of this: a radius on <video> forces a
       clip mask on every frame, and `transition-property: all` made Gecko diff
       every animatable property on every element each restyle. Measured in
       headless Zen 1.21.8b at 240 Hz: +40% CPU and 4x more >50 ms video-frame
       gaps versus no stylesheet; colour-only transitions cost ~nothing. */
    *:not(video, canvas, img, picture, iframe, embed, object, svg, audio) {
      border-radius: 1px !important;
      transition-duration: 0.15s;
      transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
      transition-property: background-color, color, border-color;
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
