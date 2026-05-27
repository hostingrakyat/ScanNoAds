#!/usr/bin/env python3
"""Generate launcher icons for Scan No Ads without external deps (pure PNG encoder)."""
import os, zlib, struct

BG = (67, 56, 202)        # indigo-700
PAGE = (255, 255, 255)
TEXT = (180, 186, 210)
ACCENT = (34, 211, 238)   # cyan-400
SHADOW = (49, 41, 150)


def png_bytes(px, w, h):
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        row = px[y * w * 4:(y + 1) * w * 4]
        raw.extend(row)
    comp = zlib.compress(bytes(raw), 9)

    def chunk(typ, data):
        c = struct.pack(">I", len(data)) + typ + data
        c += struct.pack(">I", zlib.crc32(typ + data) & 0xffffffff)
        return c

    sig = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    return sig + chunk(b"IHDR", ihdr) + chunk(b"IDAT", comp) + chunk(b"IEND", b"")


def render(size, content_scale, with_bg):
    px = bytearray(size * size * 4)

    def put(x, y, c, a=255):
        if 0 <= x < size and 0 <= y < size:
            i = (y * size + x) * 4
            px[i], px[i + 1], px[i + 2], px[i + 3] = c[0], c[1], c[2], a

    if with_bg:
        for y in range(size):
            for x in range(size):
                # subtle vertical gradient
                t = y / size
                c = (int(BG[0] * (1 - t) + SHADOW[0] * t),
                     int(BG[1] * (1 - t) + SHADOW[1] * t),
                     int(BG[2] * (1 - t) + SHADOW[2] * t))
                put(x, y, c)

    cx = size / 2
    cy = size / 2
    dw = size * content_scale
    dh = dw * 1.28
    left = cx - dw / 2
    top = cy - dh / 2
    right = left + dw
    bottom = top + dh
    radius = dw * 0.08

    def in_rounded(x, y, l, t, r, b, rad):
        if x < l or x > r or y < t or y > b:
            return False
        for (cxr, cyr) in ((l + rad, t + rad), (r - rad, t + rad),
                            (l + rad, b - rad), (r - rad, b - rad)):
            if ((x < l + rad and y < t + rad) or (x > r - rad and y < t + rad) or
                    (x < l + rad and y > b - rad) or (x > r - rad and y > b - rad)):
                if ((x - cxr) ** 2 + (y - cyr) ** 2) > rad ** 2:
                    near = (abs(x - cxr) < rad and abs(y - cyr) < rad)
                    if near:
                        return False
        return True

    # white page
    for y in range(int(top), int(bottom) + 1):
        for x in range(int(left), int(right) + 1):
            if in_rounded(x, y, left, top, right, bottom, radius):
                put(x, y, PAGE)

    # text lines on page
    line_h = max(2, int(dh * 0.04))
    gap = int(dh * 0.10)
    tx0 = int(left + dw * 0.16)
    tx1 = int(right - dw * 0.16)
    ty = int(top + dh * 0.22)
    for n in range(4):
        w_end = tx1 if n != 3 else int(tx0 + (tx1 - tx0) * 0.6)
        for y in range(ty, ty + line_h):
            for x in range(tx0, w_end):
                put(x, y, TEXT)
        ty += gap

    # cyan scan line across page
    sl = int(cy)
    for y in range(sl - max(1, int(size * 0.012)), sl + max(1, int(size * 0.012))):
        for x in range(int(left - dw * 0.06), int(right + dw * 0.06)):
            put(x, y, ACCENT)

    # corner brackets
    bl = int(dw * 0.22)
    th = max(2, int(size * 0.022))
    corners = [
        (left - dw * 0.06, top - dh * 0.05, 1, 1),
        (right + dw * 0.06, top - dh * 0.05, -1, 1),
        (left - dw * 0.06, bottom + dh * 0.05, 1, -1),
        (right + dw * 0.06, bottom + dh * 0.05, -1, -1),
    ]
    for (bx, by, sx, sy) in corners:
        for i in range(bl):
            for t in range(th):
                put(int(bx + sx * i), int(by + sy * t), ACCENT)
                put(int(bx + sx * t), int(by + sy * i), ACCENT)

    return bytes(px)


def write(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(data)


RES = os.path.join(os.path.dirname(__file__), "..", "android", "app", "src", "main", "res")

# legacy full icons
legacy = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
for d, s in legacy.items():
    data = png_bytes(render(s, 0.52, True), s, s)
    write(os.path.join(RES, f"mipmap-{d}", "ic_launcher.png"), data)
    write(os.path.join(RES, f"mipmap-{d}", "ic_launcher_round.png"), data)

# adaptive foreground (108dp canvas, content in safe zone)
fg = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}
for d, s in fg.items():
    data = png_bytes(render(s, 0.40, False), s, s)
    write(os.path.join(RES, f"mipmap-{d}", "ic_launcher_foreground.png"), data)

print("icons generated")
