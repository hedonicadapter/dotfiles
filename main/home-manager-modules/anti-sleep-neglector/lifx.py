"""Make sunsetr follow a LIFX group.

Polls the group over the LIFX LAN protocol and writes a `lifx` sunsetr preset:
bulb kelvin becomes the colour temperature, bulb brightness maps linearly onto
gamma from LIFX_BRIGHTNESS_FLOOR (bulbs at 0%) to 100% (bulbs at 100%).
Power is ignored: an off bulb still reports its last brightness and kelvin.

While the bulbs answer, a marker in $XDG_RUNTIME_DIR tells the
anti-sleep-neglector monitor to leave sunsetr alone. When they stop answering
the marker is removed and the monitor goes back to its per-period presets.

Bulbs reply to the port the query came from, so LIFX_PORT must be open in the
firewall: replies to a broadcast never match conntrack.

Tunables (env):
  LIFX_GROUP             group label, case-insensitive (default "home")
  LIFX_INTERVAL          seconds between polls (default 5)
  LIFX_BRIGHTNESS_FLOOR  gamma % with the group at 0% brightness (default 50)
  LIFX_BROADCAST         broadcast address (default 255.255.255.255)
  LIFX_PORT              local UDP port (default 56700)
  LIFX_SUNSETR_BASE      sunsetr.toml without static_temp/static_gamma (required)
"""

import os
import random
import select
import signal
import socket
import struct
import subprocess
import sys
import time
from pathlib import Path

GROUP = os.environ.get("LIFX_GROUP", "home").casefold()
INTERVAL = float(os.environ.get("LIFX_INTERVAL", "5"))
FLOOR = int(os.environ.get("LIFX_BRIGHTNESS_FLOOR", "50"))
BROADCAST = os.environ.get("LIFX_BROADCAST", "255.255.255.255")
PORT = int(os.environ.get("LIFX_PORT", "56700"))
BASE = Path(os.environ["LIFX_SUNSETR_BASE"]).read_text().rstrip("\n") + "\n"

PRESET = "lifx"
CONFIG_HOME = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
PRESET_FILE = CONFIG_HOME / "sunsetr/presets" / PRESET / "sunsetr.toml"
MARKER = Path(os.environ["XDG_RUNTIME_DIR"]) / "anti-sleep-neglector-lifx"

# Polls without an answer before handing back to the monitor
MISSES = 3
# How long to collect replies to one broadcast
REPLY_WINDOW = 1.0

BULB_PORT = 56700
GET_GROUP, STATE_GROUP = 51, 53
LIGHT_GET, LIGHT_STATE = 101, 107
HEADER = 36
# Echoed in replies; filters out other clients' traffic and our own broadcasts
SOURCE = random.randint(2, 0xFFFFFFFF)


def packet(msg_type):
    # Frame: size, protocol 1024 | addressable | tagged (all devices), source
    frame = struct.pack("<HHI", HEADER, 1024 | 0x1000 | 0x2000, SOURCE)
    # Frame address: target (zero = all), reserved, flags, sequence
    address = struct.pack("<8s6sBB", bytes(8), bytes(6), 0, 0)
    # Protocol header: reserved, type, reserved
    return frame + address + struct.pack("<QHH", 0, msg_type, 0)


def query(sock):
    """Return [(brightness, kelvin)] for bulbs in GROUP, 16-bit brightness."""
    for msg_type in (GET_GROUP, LIGHT_GET):
        sock.sendto(packet(msg_type), (BROADCAST, BULB_PORT))

    groups, lights = {}, {}
    deadline = time.monotonic() + REPLY_WINDOW
    while (left := deadline - time.monotonic()) > 0:
        if not select.select([sock], [], [], left)[0]:
            break
        data = sock.recv(1024)
        if len(data) < HEADER or struct.unpack_from("<I", data, 4)[0] != SOURCE:
            continue
        mac = data[8:14]
        msg_type = struct.unpack_from("<H", data, 32)[0]
        if msg_type == STATE_GROUP and len(data) >= HEADER + 48:
            # Payload: group uuid[16], label[32], updated_at
            label = data[HEADER + 16:HEADER + 48].split(b"\0", 1)[0]
            groups[mac] = label.decode(errors="replace").casefold()
        elif msg_type == LIGHT_STATE and len(data) >= HEADER + 8:
            # Payload: hue, saturation, brightness, kelvin, ...
            _, _, brightness, kelvin = struct.unpack_from("<4H", data, HEADER)
            lights[mac] = (brightness, kelvin)

    return [state for mac, state in lights.items() if groups.get(mac) == GROUP]


def sunsetr_running():
    # `sunsetr preset` without a running instance starts sunsetr in the foreground
    cmd = ["systemctl", "--user", "is-active", "-q", "sunsetr.service"]
    return subprocess.run(cmd).returncode == 0


def active_preset():
    cmd = ["sunsetr", "preset", "active"]
    return subprocess.run(cmd, capture_output=True, text=True).stdout.strip()


def write_preset(temp, gamma):
    PRESET_FILE.parent.mkdir(parents=True, exist_ok=True)
    tmp = PRESET_FILE.with_suffix(".tmp")
    tmp.write_text(f"{BASE}static_temp = {temp}\nstatic_gamma = {gamma}\n")
    tmp.replace(PRESET_FILE)


def sync(bulbs, last):
    """Apply the group's average; return the (temp, gamma) written."""
    brightness = sum(b for b, _ in bulbs) / len(bulbs) / 0xFFFF
    kelvin = sum(k for _, k in bulbs) / len(bulbs)
    values = (
        min(max(round(kelvin / 50) * 50, 1000), 20000),
        min(max(round(FLOOR + (100 - FLOOR) * brightness), 10), 100),
    )
    if values != last:
        write_preset(*values)
        print(f"temp {values[0]} K, gamma {values[1]}%", flush=True)

    MARKER.touch()
    # Same name twice toggles back to default, so only switch when needed
    if sunsetr_running() and active_preset() != PRESET:
        subprocess.run(["sunsetr", "preset", PRESET], timeout=10)
    return values


def release():
    """Hand sunsetr back to the monitor's per-period presets."""
    MARKER.unlink(missing_ok=True)
    cmd = ["systemctl", "--user", "start", "--no-block",
           "anti-sleep-neglector-monitor.service"]
    subprocess.run(cmd)


def main():
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(("", PORT))

    last, missed = None, 0
    try:
        while True:
            try:
                bulbs = query(sock)
            except OSError as e:
                # No network yet, interface down
                print(f"query failed: {e}", file=sys.stderr, flush=True)
                bulbs = []

            if bulbs:
                missed = 0
                last = sync(bulbs, last)
            else:
                missed += 1
                if missed == MISSES and MARKER.exists():
                    print(f"group {GROUP!r} not answering", flush=True)
                    release()
            time.sleep(INTERVAL)
    finally:
        # Monitor takes over on its next tick
        MARKER.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
