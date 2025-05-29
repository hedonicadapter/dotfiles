{outputs, ...}: {
  programs.fastfetch = {
    enable = true;
    settings = {
      multithreating = true;
      logo = {
        source = ".config/fastfetch/logo.txt";
        type = "file";
        position = "left";
        # color = {
        #   1:
        #   2:
        # };
      };
      display = {
        showErrors = true;
        separator = " ";
      };
      modules = [
        "break"

        {
          type = "os";
          key = "";
        }
        {
          type = "kernel";
          key = "";
        }
        {
          type = "host";
          key = "";
        }
        {
          type = "cpu";
          key = "";
        }
        {
          type = "gpu";
          key = "";
        }
        {
          type = "netio";
          key = "";
        }

        {
          type = "separator";
          string = "჻";
        }

        {
          type = "shell";
          key = "";
        }
        {
          type = "wm";
          key = "";
        }

        {
          type = "separator";
          string = "჻";
        }

        {
          type = "cpuusage";
          key = "";
        }
        {
          type = "memory";
          key = "";
        }
        {
          type = "disk";
          key = "";
        }
        {
          type = "packages";
          key = "";
        }
        {
          type = "swap";
          key = "";
        }
        {
          type = "battery";
          key = "Battery";
        }

        {
          type = "separator";
          string = "჻";
        }

        {
          type = "weather";
          key = "Weather";
        }
        {
          type = "uptime";
          key = "";
        }
        {
          type = "colors";
          key = "";
        }
      ];
    };
  };
}
