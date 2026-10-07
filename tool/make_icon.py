"""Generates the Pocket Wallet launcher icons (iOS + Android). Run: python3 tool/make_icon.py"""
import json, os
from PIL import Image, ImageDraw, ImageFilter

S = 2048  # supersampled canvas, downscaled to 1024

def gradient():
    stops = [(0.0, (226, 165, 110)), (0.32, (138, 91, 63)), (0.7, (58, 44, 37)), (1.0, (28, 24, 22))]
    img = Image.new("RGB", (S, S))
    px = img.load()
    for y in range(S):
        t = y / (S - 1)
        for i in range(len(stops) - 1):
            if stops[i][0] <= t <= stops[i + 1][0]:
                a, b = stops[i][1], stops[i + 1][1]
                k = (t - stops[i][0]) / (stops[i + 1][0] - stops[i][0])
                break
        c = tuple(int(a[i] + (b[i] - a[i]) * k) for i in range(3))
        for x in range(S):
            px[x, y] = c
    return img

def build():
    img = gradient()
    # soft shadow under the card
    sh = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle((250, 470, 1798, 1640), 190, fill=(40, 25, 70, 120))
    sh = sh.filter(ImageFilter.GaussianBlur(40))
    img.paste(sh, (0, 0), sh)
    d = ImageDraw.Draw(img)
    # dark card
    d.rounded_rectangle((220, 400, 1828, 1560), 190, fill=(22, 22, 24))
    d.rounded_rectangle((220, 400, 1828, 1560), 190, outline=(60, 60, 66), width=6)
    # dot-matrix "P"
    P = ["1111.",
         "1...1",
         "1...1",
         "1111.",
         "1....",
         "1....",
         "1...."]
    pitch, r = 150, 52
    gw, gh = 5 * pitch, 7 * pitch
    ox = (S - gw) // 2 + pitch // 2 - 20
    oy = 400 + (1160 - gh) // 2 + pitch // 2 - 10
    for j, row in enumerate(P):
        for i, ch in enumerate(row):
            cx, cy = ox + i * pitch, oy + j * pitch
            if ch == "1":
                d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(244, 241, 238))
            else:
                d.ellipse((cx - 14, cy - 14, cx + 14, cy + 14), fill=(70, 70, 76))
    # orange accent dot (corner of the P bowl) + chip dot
    cx, cy = ox + 4 * pitch, oy + 1 * pitch
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(255, 74, 28))
    d.ellipse((1570, 520, 1650, 600), fill=(255, 74, 28))
    return img.resize((1024, 1024), Image.LANCZOS)

def rounded(img, frac=0.22):
    m = Image.new("L", img.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, *img.size), int(img.size[0] * frac), fill=255)
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img, (0, 0), m)
    return out

base = build()
os.makedirs("assets", exist_ok=True)
base.save("assets/icon.png")

# iOS: square, no alpha
ios = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
contents = json.load(open(f"{ios}/Contents.json"))
for e in contents["images"]:
    size = float(e["size"].split("x")[0]); scale = int(e["scale"][0])
    px = round(size * scale)
    base.resize((px, px), Image.LANCZOS).convert("RGB").save(f"{ios}/{e['filename']}")

# Android legacy mipmaps (rounded)
for name, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    d = f"android/app/src/main/res/mipmap-{name}"
    if os.path.isdir(d):
        rounded(base).resize((px, px), Image.LANCZOS).save(f"{d}/ic_launcher.png")
print("done")
