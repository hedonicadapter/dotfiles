{
  config,
  lib,
  ...
}: let
  cfg = config.xremapCapsEsc;
in {
  options.xremapCapsEsc.devices = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Keyboards to swap CapsLock/Esc on; empty means all.";
  };

  config.services.xremap = {
    enable = true;
    config.modmap = [
      ({
          name = "CapsLock/Esc swap";
          remap = {
            "CapsLock" = "Esc";
            "Esc" = "CapsLock";
          };
        }
        // lib.optionalAttrs (cfg.devices != []) {device.only = cfg.devices;})
    ];
  };
}
