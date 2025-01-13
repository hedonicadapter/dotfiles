{outputs, ...}: let
  scss = ''
    * {
      background-color: transparent;
      border-radius: 1px;
    }

    button, box {
      all:unset;
      padding: 0;
      background: transparent;
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
      background-color: ${outputs.colors.base00};
      font-size: 20px;

      .bar-items {
        min-height: 24px;
        margin-left: 6px;
        margin-right: 6px;
        margin-top: 3px;
        margin-bottom: -2px;

        .bar-item {
          margin-left: 8px;
          margin-right: 8px;

          .main {
            padding-left: 8px;
            padding-right: 8px;
            padding-bottom: 1px;
          }
          .panel {}
        }

        .indicator {
          color: ${outputs.colors.base07};
          margin-left: 4px;
          margin-right: 4px;
        }

        .left {
          .workspaces {
            font-size: 16px;
          }

          .mode {
            margin-left: 4px;

            .NORMAL {
            }
            .RUN {
              background-color: ${outputs.colors.base0D};
              color: ${outputs.colors.base01};
            }
            .BROWSER {
              background-color: ${outputs.colors.base0D};
              color: ${outputs.colors.base01};
            }
            .FILES {
              background-color: ${outputs.colors.base06};
              color: ${outputs.colors.base02};
            }
            .QUERY {
              background-color: ${outputs.colors.base0C};
              color: ${outputs.colors.base01};
            }
            .UTIL {
              background-color: ${outputs.colors.base0E};
              color: ${outputs.colors.base01};
            }
            .SYSTEM {
              background-color: ${outputs.colors.base0F};
              color: ${outputs.colors.base01};
            }
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
            margin-top: 1px;
            background-color: ${outputs.colors.base0B};
            color: ${outputs.colors.base00};

            .main {
              .media-controls {
                font-size: 14px;
                margin-left: 6px;
                margin-top:-1px;
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
                padding: 0 6px;
                font-size: 16px;
                font-weight: 600;
              }
            }

            .panel {
              .cover-art {
                padding: 4px;
                margin-right: 4px;
              }
              .track-info {
                font-size: 16px;
                padding-bottom: 1px;
                padding-top: 2px;

                .album-title {}
                .artist-names {}
                .project-name {}
              }
            }
          }
        }

        .center {
          .title {}
        }

        .right {
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
          }

          .audio {
            .main { }

            .panel {
              padding: 1px;

              > * {
                padding-top: 1px;
                padding-bottom: 1px;
              }
            }

            .bar-label {
              font-size: 19px;
              padding-top: 1px;
            }

            .bar {
              font-size: 19px;
              margin-top: -2px;

              .low {
                color: ${outputs.colors.base07};
              }
              .mid {
                color: ${outputs.colors.base09};
              }
              .high {
                color: ${outputs.colors.base08};
              }

              .hovered {
                .low {
                  color: ${outputs.colors.base00};
                }
              }
            }
          }
          .audio.hovered {
            background-color: ${outputs.colors.base07};
            color: ${outputs.colors.base00};
          }

          .fan {
            margin-left: 4px;
            font-size: 16px;
          }

          .time {
            font-size: 18px;
          }
        }
      }
    }

    menu {
      background-color: ${outputs.colors.base00};
      padding: 1px;
      margin: 0px;

      > * {
        padding: 0px;
        margin: 0px;
      }

      > *:hover {
          background-color: ${outputs.colors.base07};
          color: ${outputs.colors.base00};
      }
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
