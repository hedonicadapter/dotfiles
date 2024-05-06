''
    #!/usr/bin/env bash
    nohup armcord --disable-features=WaylandFractionalScaleV1 "$@" > /dev/null 2>&1 &
'';
