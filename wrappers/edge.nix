''
     #!/usr/bin/env bash
    nohup microsoft-edge-dev --disable-features=WaylandFractionalScaleV1 "$@" > /dev/null 2>&1 &
'';
