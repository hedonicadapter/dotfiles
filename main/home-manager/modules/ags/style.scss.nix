{outputs, ...}: let
  scss = ''
    * {
      background-color: transparent;
      border-radius: 1px;
    }

    @keyframes spin-low {
        to { -gtk-icon-transform: rotate(1turn); }
    }
    @keyframes spin-mid {
        to { -gtk-icon-transform: rotate(1turn); }
    }
    @keyframes spin-high {
        to { -gtk-icon-transform: rotate(1turn); }
    }

    window.Bar {
      color: ${outputs.colors.base07};
      min-height: 23px;
      font-size: 20px;

      .bar-items {
        margin-left: 6px;
        margin-right: 6px;
        margin-top: 4px;
        margin-bottom: -2px;

        .bar-item {
          margin-left: 8px;
          margin-right: 8px;
        }
      }

      .indicator {
        color: ${outputs.colors.base07};
        margin-left: 4px;
        margin-right: 4px;
      }

      .workspaces {
        font-size: 16px;
      }

      .tray {
        margin-left: 4px;
        margin-right: 4px;
        margin-top: 1px;
        font-size: 16px;

        > * {
          padding: 0 3px;
        }
      }

      .media-player {
        min-height: 21px;

        background-color: ${outputs.colors.base0B};
        color: ${outputs.colors.base00};

        > * {
          font-size: 12px;
          font-weight: 600;
        }

        .main {
          padding-left: 8px;
          padding-right: 8px;
          padding-bottom: 1px;

          .media-controls {
            font-size: 14px;
          }

          .position-bar {
            border: 2px solid ${outputs.colors.base00};
            min-height: 10px;
            margin: 0 8px;

            .current-position {
              border: 1px solid ${outputs.colors.base0B};
              background-color: ${outputs.colors.base00};
              min-height: 8px;
            }
          }
          .position-and-length{
            padding: 0 8px;
          }
        }
        .track-info {
          padding: 2px 0;
          font-size: 16px;

          padding-right: 8px;
          padding-bottom: 1px;
          padding-top: 2px;

          .cover-art-container {
            margin-left: 2px;
            margin-bottom: 2px;
            margin-right: 4px;
          }
          .album-title {}
          .artist-names {}
          .project-name {}
        }
      }

      .audio {
        .default-io {
          > * {
            margin-left: 6px;
            margin-right: 6px;
            margin-top: -2px;
          }
          .bar-label {
          }
          .bar {
          }
        }
      }
      .audio.hovered {
        background-color: ${outputs.colors.base07};
        color: ${outputs.colors.base00};
      }

      .time {
        font-size: 18px;
      }
    }

    menu {
      background-color: ${outputs.colors.base00};
      padding: 1px;
      margin: 0px;

      > menuitem {
        padding: 1px;
        margin: 0px;
      }

      > menuitem:hover {
          background-color: ${outputs.colors.base07};
          color: ${outputs.colors.base00};
      }
    }

    button, box {
      all:unset;
      padding: 0;
      background: transparent;
    }

    .focused {
      opacity: 100;
    }

    .notifications {
      background-color: ${outputs.colors.base00};
      color: ${outputs.colors.base07};
      margin-right: 3px;
      margin-top: -2px;
      padding-bottom: 1px;

      :not(.latest) {
        min-height: 0;
      }
      .header {
        border: 2px solid transparent;
        font-size: 18px;

        .app-name {
          padding-left: 1px;
          padding-bottom: 1px;
          font-weight: 600;
        }
        .summary {
        }
        .time {
          font-size: 16px;
        }
        .close-button {
          margin-left: -4px;
          padding-right:1px;
        }
      }
      .body {
        padding-top: 4px;
      }
      .actions {
        padding-bottom: 4px;
        button {
        }
      }
      .hovered {
      }
    }

    .fan {
      margin-left: 4px;
      font-size: 16px;
    }

    .low {
      color: ${outputs.colors.base05};

      .header {
        border-color: ${outputs.colors.base07};
        color: ${outputs.colors.base07};

        .app-name {
          background-color: ${outputs.colors.base07};
          color: ${outputs.colors.base00};
        }
      }

      .fan {
        color: ${outputs.colors.base05};
        animation: spin-low 1.5s linear infinite;
      }
    }
    .mid {
      color: ${outputs.colors.base07};

      .header {
        border-color: ${outputs.colors.base0C};
        color: ${outputs.colors.base07};

        .app-name {
            background-color: ${outputs.colors.base0C};
            color: ${outputs.colors.base00};
        }
      }

      .fan {
        color: ${outputs.colors.base07};
        animation: spin-mid 1s linear infinite;
      }
    }
    .high {
      color: ${outputs.colors.base08};

      .header {
        border-color: ${outputs.colors.base08};
        color: ${outputs.colors.base07};

        .app-name{
            background-color: ${outputs.colors.base08};
            color: ${outputs.colors.base07};
        }
      }

      .fan {
        color: ${outputs.colors.base08};
        animation: spin-high 0.25s linear infinite;
      }
    }

  '';
in
  scss
