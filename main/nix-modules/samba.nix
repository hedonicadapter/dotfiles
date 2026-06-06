{
  services.samba = {
    enable = true;
    openFirewall = true; # Automatically opens ports 137, 138, 139, 445
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "NixOS-Samba";
        "netbios name" = "nixserver";
        "security" = "user";
        # Better macOS compatibility
        "vfs objects" = "fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
      };
      "MyShare" = {
        "path" = "/home/hedonicadapter/Documents/share";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "hedonicadapter";
      };
    };
  };

  # Optional: Enable Avahi so your Mac sees the server in the Finder sidebar automatically
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
    };
  };
}
