#!/usr/bin/env python3
"""Regenerate rah's derived cursors from the hand-made eye (left_ptr).

Writes PNGs + meta.hl into rah/hyprcursors/<shape>/ for the shapes below and
leaves every other shape (left_ptr included) alone. Existing define_override
lines are kept. Needs Pillow:

    nix-shell -p 'python3.withPackages (p: [p.pillow])' --run 'python3 rah-generate.py'

Drawing happens in a 48-unit space at 4x, then downsamples to 48/32/24.
"""

import math
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent / "rah" / "hyprcursors"
SIZES = [24, 32, 48]
BASE = 48
SS = 4  # supersampling factor
K = BASE * SS

RED = (255, 0, 0)
HOT = (255, 120, 110)  # core highlight
INK = (12, 10, 10)  # outline, close to the eye's blacks

# Eye geometry in the 49px source (left_ptr_002.png)
IRIS = (16.0, 27.0)
TIP = (8.5, 3.5)


# --- source eye -------------------------------------------------------------


def load_eye():
    """Split the hand-made cursor into eye body and beam (both 48x48 RGBA)."""
    src = Image.open(ROOT / "left_ptr" / "left_ptr_002.png").convert("RGBA")
    src = src.crop((0, 0, BASE, BASE))
    body = src.copy()
    beam = Image.new("RGBA", src.size)
    for y in range(BASE):
        for x in range(BASE):
            r, g, b, a = src.getpixel((x, y))
            is_red = r > g + 60 and r > b + 60
            # Beam: everything above the lid, plus translucent red where it meets the iris
            if y <= 21 or (y <= 24 and is_red and a < 150):
                beam.putpixel((x, y), (r, g, b, a))
                body.putpixel((x, y), (0, 0, 0, 0))
    return src, body, beam


# --- drawing helpers (all coords in 48-unit space) ---------------------------


def canvas():
    return Image.new("RGBA", (K, K))


def s(p):
    return (p[0] * SS, p[1] * SS)


def glow(img, radius=2.2, strength=0.55):
    """Red halo under the strokes so they read on dark backgrounds."""
    alpha = img.getchannel("A").filter(ImageFilter.GaussianBlur(radius * SS))
    alpha = alpha.point(lambda v: int(v * strength))
    halo = Image.new("RGBA", img.size, RED + (0,))
    halo.putalpha(alpha)
    return Image.alpha_composite(halo, img)


def stroke(draw, pts, width, color):
    w = max(1, round(width * SS))
    pts = [s(p) for p in pts]
    draw.line(pts, fill=color, width=w, joint="curve")
    r = w / 2
    for x, y in (pts[0], pts[-1]):
        draw.ellipse((x - r, y - r, x + r, y + r), fill=color)


def laser(paths, width=2.6, polys=()):
    """Black-outlined red strokes with a hot core, like the eye's beam tip."""
    img = canvas()
    d = ImageDraw.Draw(img)
    for layer_w, color in ((width + 2.0, INK + (255,)), (width, RED + (255,)), (width * 0.35, HOT + (255,))):
        for pts in paths:
            stroke(d, pts, layer_w, color)
        for poly in polys:
            if color[:3] == INK:
                d.polygon([s(p) for p in poly], fill=color, outline=color, width=round(2.0 * SS))
            elif color[:3] == RED:
                d.polygon([s(p) for p in poly], fill=color)
    return glow(img)


def arrowhead(tip, angle, length=7.0, half=5.0):
    """Triangle pointing along `angle` (radians) with its point at `tip`."""
    ux, uy = math.cos(angle), math.sin(angle)
    bx, by = tip[0] - ux * length, tip[1] - uy * length
    return [tip, (bx - uy * half, by + ux * half), (bx + uy * half, by - ux * half)]


def double_arrow(angle, half_len=15.0, center=(24, 24)):
    ux, uy = math.cos(angle), math.sin(angle)
    a = (center[0] - ux * half_len, center[1] - uy * half_len)
    b = (center[0] + ux * half_len, center[1] + uy * half_len)
    inner_a = (a[0] + ux * 5, a[1] + uy * 5)
    inner_b = (b[0] - ux * 5, b[1] - uy * 5)
    return laser([[inner_a, inner_b]], polys=[arrowhead(b, angle), arrowhead(a, angle + math.pi)])


def edge_arrow(angle, bar):
    """Arrow pointing at an edge (bar = list of points for the edge line)."""
    ux, uy = math.cos(angle), math.sin(angle)
    tip = (24 + ux * 11, 24 + uy * 11)
    tail = (24 - ux * 9, 24 - uy * 9)
    shaft_end = (tip[0] - ux * 5, tip[1] - uy * 5)
    return laser([[tail, shaft_end], bar], polys=[arrowhead(tip, angle)])


def beam_at(angle, origin, length=22.0, base_w=7.0, tip_w=1.6):
    """Procedural copy of the eye's beam: wide and faint at the iris, opaque at the tip."""
    img = canvas()
    d = ImageDraw.Draw(img)
    ux, uy = math.cos(angle), math.sin(angle)
    steps = 40
    for i in range(steps):
        t = i / (steps - 1)
        cx = origin[0] + ux * length * t
        cy = origin[1] + uy * length * t
        w = base_w + (tip_w - base_w) * t
        a = int(60 + 195 * t**1.6)
        r = w * SS / 2
        d.ellipse((cx * SS - r, cy * SS - r, cx * SS + r, cy * SS + r), fill=RED + (a,))
    return img


# --- compositing ------------------------------------------------------------


def down(img, size):
    return img.resize((size, size), Image.LANCZOS)


def at_base(layer_hi):
    return down(layer_hi, BASE)


def over(*layers):
    out = Image.new("RGBA", (BASE, BASE))
    for layer in layers:
        out = Image.alpha_composite(out, layer)
    return out


def shift(img, dx, dy):
    out = Image.new("RGBA", img.size)
    out.paste(img, (dx, dy), img)
    return out


# --- shapes -----------------------------------------------------------------


def shapes(src, body, beam):
    out = {}

    # pointer: brighter beam and a flare at the tip
    bright = beam.copy()
    bright.putalpha(bright.getchannel("A").point(lambda v: min(255, int(v * 1.8))))
    flare = canvas()
    fd = ImageDraw.Draw(flare)
    for r, col in ((3.6, RED + (120,)), (2.2, RED + (255,)), (1.1, (255, 230, 220, 255))):
        fd.ellipse((s((TIP[0] - r, TIP[1] - r)) + s((TIP[0] + r, TIP[1] + r))), fill=col)
    out["hand2"] = ([over(body, bright, at_base(glow(flare, 1.5, 0.8)))], 50, TIP)

    # not-allowed: beam stopped by a red circle-slash
    c, r = (13.0, 11.0), 8.0
    ring = canvas()
    rd = ImageDraw.Draw(ring)
    for w, col in ((4.6, INK + (255,)), (2.6, RED + (255,))):
        rd.ellipse(s((c[0] - r, c[1] - r)) + s((c[0] + r, c[1] + r)), outline=col, width=round(w * SS))
        d = r * 0.7
        stroke(rd, [(c[0] - d, c[1] - d), (c[0] + d, c[1] + d)], w, col)
    stub = beam.crop((0, 19, BASE, BASE))
    stub_layer = Image.new("RGBA", (BASE, BASE))
    stub_layer.paste(stub, (0, 19))
    out["crossed_circle"] = ([over(body, stub_layer, at_base(glow(ring)))], 50, c)

    # wait: eye centered, beam sweeping round the iris
    eye_dx, eye_dy = 24 - round(IRIS[0]) + 2, 24 - round(IRIS[1]) + 4
    centered = shift(body, eye_dx, eye_dy)
    origin = (IRIS[0] + eye_dx, IRIS[1] + eye_dy)
    frames = []
    for i in range(24):
        ang = -math.pi / 2 + 2 * math.pi * i / 24
        frames.append(over(at_base(beam_at(ang, origin, length=19)), centered))
    out["watch"] = (frames, 45, (24, 24))

    # progress: the arrow as is, three embers orbiting top right
    frames = []
    oc, orad = (37.0, 11.0), 6.0
    for i in range(16):
        layer = canvas()
        ld = ImageDraw.Draw(layer)
        for j, (rad, a) in enumerate(((2.4, 255), (1.9, 170), (1.4, 90))):
            ang = 2 * math.pi * (i / 16) - j * 0.55
            x, y = oc[0] + orad * math.cos(ang), oc[1] + orad * math.sin(ang)
            ld.ellipse(s((x - rad - 0.8, y - rad - 0.8)) + s((x + rad + 0.8, y + rad + 0.8)), fill=INK + (a,))
            ld.ellipse(s((x - rad, y - rad)) + s((x + rad, y + rad)), fill=RED + (a,))
        frames.append(over(src, at_base(glow(layer, 1.5, 0.6))))
    out["left_ptr_watch"] = (frames, 60, TIP)

    # text: laser I-beam
    out["xterm"] = (
        [at_base(laser([[(24, 11), (24, 37)], [(19.5, 10), (28.5, 10)], [(19.5, 38), (28.5, 38)]], width=2.2))],
        50,
        (24, 24),
    )

    # crosshair family: four ticks around an open center, dot in the middle
    ticks = [[(24, 8), (24, 19)], [(24, 29), (24, 40)], [(8, 24), (19, 24)], [(29, 24), (40, 24)]]
    dot = laser([[(24, 24), (24, 24)]], width=2.4)
    cross = Image.alpha_composite(laser(ticks, width=2.2), dot)
    for name in ("crosshair", "tcross", "cross"):
        out[name] = ([at_base(cross)], 50, (24, 24))

    # resize
    out["sb_h_double_arrow"] = ([at_base(double_arrow(0))], 50, (24, 24))
    out["sb_v_double_arrow"] = ([at_base(double_arrow(math.pi / 2))], 50, (24, 24))
    out["fd_double_arrow"] = ([at_base(double_arrow(-math.pi / 4))], 50, (24, 24))  # / (ne-sw)
    out["bd_double_arrow"] = ([at_base(double_arrow(math.pi / 4))], 50, (24, 24))  # \ (nw-se)

    out["left_side"] = ([at_base(edge_arrow(math.pi, [(10, 12), (10, 36)]))], 50, (10, 24))
    out["right_side"] = ([at_base(edge_arrow(0, [(38, 12), (38, 36)]))], 50, (38, 24))
    out["top_side"] = ([at_base(edge_arrow(-math.pi / 2, [(12, 10), (36, 10)]))], 50, (24, 10))
    out["bottom_side"] = ([at_base(edge_arrow(math.pi / 2, [(12, 38), (36, 38)]))], 50, (24, 38))

    def corner(angle, pts, hot):
        return ([at_base(edge_arrow(angle, pts))], 50, hot)

    out["top_left_corner"] = corner(-3 * math.pi / 4, [(20, 11), (11, 11), (11, 20)], (11, 11))
    out["top_right_corner"] = corner(-math.pi / 4, [(28, 11), (37, 11), (37, 20)], (37, 11))
    out["bottom_left_corner"] = corner(3 * math.pi / 4, [(11, 28), (11, 37), (20, 37)], (11, 37))
    out["bottom_right_corner"] = corner(math.pi / 4, [(37, 28), (37, 37), (28, 37)], (37, 37))

    # move / grabbing: four-way arrows
    paths, polys = [], []
    for ang in (0, math.pi / 2, math.pi, -math.pi / 2):
        ux, uy = math.cos(ang), math.sin(ang)
        tip = (24 + ux * 16, 24 + uy * 16)
        paths.append([(24, 24), (tip[0] - ux * 5, tip[1] - uy * 5)])
        polys.append(arrowhead(tip, ang, length=6.0, half=4.5))
    out["grabbing"] = ([at_base(laser(paths, width=2.4, polys=polys))], 50, (24, 24))

    return out


# --- output -----------------------------------------------------------------


def write_shape(name, frames, delay, hotspot):
    d = ROOT / name
    overrides = []
    if (d / "meta.hl").exists():
        overrides = [l for l in (d / "meta.hl").read_text().splitlines() if l.startswith("define_override")]
        shutil.rmtree(d)
    d.mkdir(parents=True)

    lines = [
        "resize_algorithm = none",
        f"hotspot_x = {hotspot[0] / BASE:.2f}",
        f"hotspot_y = {hotspot[1] / BASE:.2f}",
        "",
    ]
    n = 0
    for size in SIZES:
        for frame in frames:
            fname = f"{name}_{n:03d}.png"
            (frame if size == BASE else down(frame, size)).save(d / fname)
            lines.append(f"define_size = {size}, {fname}, {delay}")
            n += 1
    lines.append("")
    lines += overrides
    (d / "meta.hl").write_text("\n".join(lines) + "\n")


def main():
    src, body, beam = load_eye()
    for name, (frames, delay, hot) in shapes(src, body, beam).items():
        write_shape(name, frames, delay, hot)
        print(f"{name}: {len(frames)} frame(s)")


if __name__ == "__main__":
    main()
