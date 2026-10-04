"""Mirror a LIFX lamp's color onto OpenRGB ARGB zones (CPU cooler fan).

Env:
  LIFX_LABEL      lamp label to follow; default first powered-on lamp by label
  LIFX_BROADCAST  broadcast address; default 255.255.255.255
  LIFX_PORT       local UDP port for replies (must be open in firewall)
  OPENRGB_ZONE    zone name substring; default "addressable"
  OPENRGB_LEDS    LED count to size empty resizable zones to
  POLL_SECONDS    poll interval
"""

import colorsys
import math
import os
import random
import socket
import struct
import time

from openrgb import OpenRGBClient
from openrgb.utils import DeviceType, RGBColor, ZoneType

LIFX_LABEL = os.environ.get("LIFX_LABEL", "")
LIFX_BROADCAST = os.environ.get("LIFX_BROADCAST", "255.255.255.255")
LIFX_PORT = int(os.environ.get("LIFX_PORT", "56701"))
OPENRGB_ZONE = os.environ.get("OPENRGB_ZONE", "addressable").lower()
OPENRGB_LEDS = int(os.environ.get("OPENRGB_LEDS", "16"))
POLL_SECONDS = float(os.environ.get("POLL_SECONDS", "2"))

LIGHT_GET = 101
LIGHT_STATE = 107
SOURCE = random.randint(2, 2**32 - 1)


def lifx_packet(msg_type, seq):
    # Frame: protocol 1024, addressable, tagged (broadcast to all lamps)
    flags = 1024 | (1 << 12) | (1 << 13)
    header = struct.pack("<HHI", 36, flags, SOURCE)
    header += bytes(8) + bytes(6) + struct.pack("<BB", 0x01, seq)
    header += struct.pack("<QHH", 0, msg_type, 0)
    return header


def parse_state(data):
    if len(data) < 36 + 52:
        return None
    (msg_type,) = struct.unpack_from("<H", data, 32)
    if msg_type != LIGHT_STATE:
        return None
    hue, sat, bri, kelvin, _, power = struct.unpack_from("<HHHHhH", data, 36)
    label = data[48:80].split(b"\0", 1)[0].decode("utf-8", "replace")
    return {"label": label, "hue": hue, "sat": sat, "bri": bri, "kelvin": kelvin, "on": power > 0}


def query_lamps(sock, seq):
    sock.sendto(lifx_packet(LIGHT_GET, seq), (LIFX_BROADCAST, 56700))
    lamps = {}
    deadline = time.monotonic() + 0.5
    while (remaining := deadline - time.monotonic()) > 0:
        sock.settimeout(remaining)
        try:
            data, addr = sock.recvfrom(1024)
        except socket.timeout:
            break
        state = parse_state(data)
        if state:
            lamps[addr[0]] = state
    return list(lamps.values())


def pick_lamp(lamps):
    if LIFX_LABEL:
        return next((l for l in lamps if l["label"] == LIFX_LABEL), None)
    on = sorted((l for l in lamps if l["on"]), key=lambda l: l["label"])
    return on[0] if on else None


def kelvin_rgb(kelvin):
    # Tanner Helland approximation, 1000-40000 K
    t = max(1000, min(40000, kelvin)) / 100
    r = 255 if t <= 66 else 329.698727446 * (t - 60) ** -0.1332047592
    g = (
        99.4708025861 * math.log(t) - 161.1195681661
        if t <= 66
        else 288.1221695283 * (t - 60) ** -0.0755148492
    )
    b = 255 if t >= 66 else (0 if t <= 19 else 138.5177312231 * math.log(t - 10) - 305.0447927307)
    return tuple(max(0, min(255, c)) / 255 for c in (r, g, b))


def lamp_rgb(lamp):
    if not lamp or not lamp["on"]:
        return (0, 0, 0)
    sat = lamp["sat"] / 65535
    bri = lamp["bri"] / 65535
    hue_rgb = colorsys.hsv_to_rgb(lamp["hue"] / 65535, 1, 1)
    white = kelvin_rgb(lamp["kelvin"])
    # Low saturation means white at the lamp's color temperature
    mix = [w + (h - w) * sat for w, h in zip(white, hue_rgb)]
    return tuple(round(c * bri * 255) for c in mix)


def target_zones(client):
    zones = []
    for dev in client.devices:
        if dev.type != DeviceType.MOTHERBOARD:
            continue
        modes = [m.name.lower() for m in dev.modes]
        for mode in ("direct", "static"):
            if mode in modes:
                dev.set_mode(mode)
                break
        for zone in dev.zones:
            if OPENRGB_ZONE not in zone.name.lower():
                continue
            # ARGB headers report 0 LEDs until sized
            if zone.type == ZoneType.LINEAR and not zone.leds:
                zone.resize(OPENRGB_LEDS)
            zones.append(zone)
    return zones


def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sock.bind(("", LIFX_PORT))

    # OpenRGB lists no devices until detection finishes; wait instead of failing
    seen = None
    while True:
        client = OpenRGBClient(name="lifx-rgb-sync")
        zones = target_zones(client)
        if zones:
            break
        names = [f"{d.name}: {[z.name for z in d.zones]}" for d in client.devices]
        if names != seen:
            print(f"No OpenRGB zone matching {OPENRGB_ZONE!r} yet. Devices: {names}", flush=True)
            seen = names
        client.disconnect()
        time.sleep(10)
    print(f"Driving zones: {[z.name for z in zones]}", flush=True)

    last = None
    seq = 0
    while True:
        seq = (seq + 1) % 256
        lamps = query_lamps(sock, seq)
        # No replies is a network blip, not lamps off; keep current color
        rgb = lamp_rgb(pick_lamp(lamps)) if lamps else last
        if rgb is not None and rgb != last:
            for zone in zones:
                zone.set_color(RGBColor(*rgb))
            print(f"Color {rgb}", flush=True)
            last = rgb
        time.sleep(POLL_SECONDS)


if __name__ == "__main__":
    main()
