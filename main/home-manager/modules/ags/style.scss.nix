{outputs, ...}: let
  scss = ''
    * {
      font-family: "Mx437 DOS/V re. JPN30";
    }

    window.Bar {
      color: ${outputs.colors.base07};
      transition: all 0.15s ease-out;

      .bar-items {
        margin-left: 14px;
        margin-right: 14px;
        margin-top: 4px;
        margin-bottom: -2px;

        .bar-item {
          background: ${outputs.colors.base00};
        }
      }

      label {
        color: ${outputs.colors.base07};
      }

      .indicator {
        color: ${outputs.colors.base07};
        margin-left: 4px;
        margin-right: 4px;
      }

      .tray {
        margin-left: 4px;
        margin-right: 4px;
      }

      .dash {
        .hovered {
        }
      }

      .hovered {
      }
    }

    button {
      padding: 0;
      background: transparent;
    }

    .focused {
      opacity: 100;
    }

    .notifications {
      :not(.latest) {
        min-height: 0;
      }
      .header {
        .app-name {
        }
        .summary {
        }
        .time {
        }
      }
      .hovered {
      }
    }

    .low {
        background-color: ${outputs.colors.base07};
        color: ${outputs.colors.base02};
    }
    .mid {
        background-color: ${outputs.colors.base0C};
        color: ${outputs.colors.base00};
    }
    .high {
        background-color: ${outputs.colors.base08};
        color: ${outputs.colors.base07};
    }
  '';
in
  scss
