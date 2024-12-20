{outputs, ...}: let
  scss = ''
    * {
      background-color: transparent;
    }

    window.Bar {
      color: ${outputs.colors.base07};

      .bar-items {
        margin-left: 14px;
        margin-right: 14px;
        margin-top: 4px;
        margin-bottom: -2px;

        .bar-item {
          margin-left: 6px;
          margin-right: 6px;
        }
      }

      .indicator {
        color: ${outputs.colors.base07};
        margin-left: 4px;
        margin-right: 4px;
      }

      .media-player {
        min-height: 20px;

        padding-left: 8px;
        padding-right: 8px;
        padding-bottom: 1px;

        background-color: ${outputs.colors.base0B};
        color: ${outputs.colors.base00};

        > * {
          font-size: 12px;
          font-weight: 600;
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

      .tray {
        margin-left: 4px;
        margin-right: 4px;
        > * {
          padding: 3px 0;
        }
      }

      .dash {
        .hovered {
        }
      }

      .hovered {
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
      margin-top: -4px;
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

    .low {
      .header {
        border-color: ${outputs.colors.base07};
        color: ${outputs.colors.base07};

        .app-name {
          background-color: ${outputs.colors.base07};
          color: ${outputs.colors.base00};
        }
      }
    }
    .mid {
      .header {
        border-color: ${outputs.colors.base0C};
        color: ${outputs.colors.base07};

        .app-name {
            background-color: ${outputs.colors.base0C};
            color: ${outputs.colors.base00};
        }
      }
    }
    .high {
      .header {
        border-color: ${outputs.colors.base08};
        color: ${outputs.colors.base07};

        .app-name{
            background-color: ${outputs.colors.base08};
            color: ${outputs.colors.base07};
        }
      }
    }
  '';
in
  scss
