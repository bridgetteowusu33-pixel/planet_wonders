#!/usr/bin/env python3
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

W = 2048
H = 2048
BLACK = 0
WHITE = 255
OUTER = 18
MAIN = 12
DETAIL = 6

OUT_DIR = Path('assets/coloring/usa/food')


def canvas():
    img = Image.new('L', (W, H), WHITE)
    return img, ImageDraw.Draw(img)


def border(draw):
    draw.rectangle((36, 36, W - 36, H - 36), outline=BLACK, width=OUTER)


def plate(draw, x1=240, y1=980, x2=1808, y2=1760):
    draw.ellipse((x1, y1, x2, y2), outline=BLACK, width=OUTER)
    draw.ellipse((x1 + 90, y1 + 70, x2 - 90, y2 - 70), outline=BLACK, width=MAIN)


def smiling_face(draw, cx, cy, r):
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), outline=BLACK, width=MAIN)
    draw.ellipse((cx - int(r * 0.4), cy - int(r * 0.2), cx - int(r * 0.2), cy), outline=BLACK, width=DETAIL)
    draw.ellipse((cx + int(r * 0.2), cy - int(r * 0.2), cx + int(r * 0.4), cy), outline=BLACK, width=DETAIL)
    draw.arc((cx - int(r * 0.35), cy - int(r * 0.05), cx + int(r * 0.35), cy + int(r * 0.35)), 20, 160, fill=BLACK, width=DETAIL)


def burger(draw):
    plate(draw)
    draw.rounded_rectangle((540, 620, 1508, 840), radius=110, outline=BLACK, width=OUTER)
    draw.arc((580, 560, 1468, 860), 180, 360, fill=BLACK, width=MAIN)
    for x in [700, 830, 970, 1110, 1260, 1390]:
        draw.ellipse((x, 700, x + 28, 728), outline=BLACK, width=DETAIL)

    draw.rounded_rectangle((580, 850, 1468, 930), radius=35, outline=BLACK, width=MAIN)  # lettuce
    draw.rounded_rectangle((560, 942, 1488, 1022), radius=35, outline=BLACK, width=MAIN)  # tomato
    draw.rectangle((610, 1028, 1438, 1138), outline=BLACK, width=OUTER)  # patty
    draw.rectangle((630, 1146, 1418, 1246), outline=BLACK, width=MAIN)  # cheese
    draw.rounded_rectangle((560, 1246, 1488, 1390), radius=48, outline=BLACK, width=OUTER)  # bottom bun

    draw.rectangle((300, 1260, 500, 1400), outline=BLACK, width=MAIN)
    draw.rectangle((1540, 1260, 1740, 1400), outline=BLACK, width=MAIN)
    smiling_face(draw, 1024, 725, 82)


def pizza(draw):
    plate(draw, 220, 900, 1828, 1760)
    draw.ellipse((420, 520, 1628, 1720), outline=BLACK, width=OUTER)
    draw.ellipse((500, 600, 1548, 1640), outline=BLACK, width=MAIN)

    for i in range(8):
        a = 2 * math.pi * i / 8
        x = 1024 + int(510 * math.cos(a))
        y = 1120 + int(510 * math.sin(a))
        draw.line((1024, 1120, x, y), fill=BLACK, width=DETAIL)

    for x, y in [(760, 860), (960, 760), (1220, 790), (1350, 980), (1180, 1130), (830, 1110), (670, 1320), (990, 1410), (1300, 1330)]:
        draw.ellipse((x - 55, y - 35, x + 55, y + 35), outline=BLACK, width=MAIN)

    draw.rectangle((320, 320, 1728, 720), outline=BLACK, width=MAIN)
    draw.line((320, 720, 420, 900), fill=BLACK, width=MAIN)
    draw.line((1728, 720, 1628, 900), fill=BLACK, width=MAIN)
    for x in [700, 1024, 1360]:
        draw.arc((x - 40, 430, x + 40, 590), 200, 340, fill=BLACK, width=DETAIL)


def hotdog(draw):
    plate(draw)
    draw.rounded_rectangle((520, 760, 1528, 1220), radius=220, outline=BLACK, width=OUTER)
    draw.rounded_rectangle((660, 860, 1388, 1110), radius=120, outline=BLACK, width=OUTER)

    for x in [720, 860, 1000, 1140, 1280]:
        draw.arc((x, 900, x + 120, 980), 20, 200, fill=BLACK, width=DETAIL)
    for x in [760, 900, 1060, 1220]:
        draw.arc((x, 1000, x + 120, 1080), 180, 360, fill=BLACK, width=DETAIL)

    # tray
    draw.rounded_rectangle((430, 1280, 1618, 1560), radius=35, outline=BLACK, width=MAIN)
    draw.rectangle((470, 1320, 1578, 1520), outline=BLACK, width=DETAIL)
    smiling_face(draw, 1024, 980, 70)


def pancakes(draw):
    plate(draw)
    base_y = 1260
    for i in range(4):
        y = base_y - i * 120
        draw.ellipse((560, y, 1488, y + 200), outline=BLACK, width=OUTER)

    # butter
    draw.rounded_rectangle((920, 760, 1128, 910), radius=20, outline=BLACK, width=MAIN)

    # syrup drips
    draw.line((920, 900, 860, 1060), fill=BLACK, width=MAIN)
    draw.line((1040, 910, 1050, 1110), fill=BLACK, width=MAIN)
    draw.line((1120, 900, 1180, 1080), fill=BLACK, width=MAIN)

    # fork
    draw.rectangle((1480, 980, 1560, 1540), outline=BLACK, width=MAIN)
    for i in range(4):
        x = 1470 + i * 30
        draw.line((x, 900, x, 980), fill=BLACK, width=DETAIL)


def donut(draw):
    plate(draw)
    draw.ellipse((520, 620, 1528, 1628), outline=BLACK, width=OUTER)
    draw.ellipse((860, 960, 1188, 1288), outline=BLACK, width=OUTER)

    # sprinkles
    for x, y in [(760, 850), (880, 760), (1050, 740), (1230, 820), (1320, 960), (1280, 1150), (1160, 1310), (950, 1380), (760, 1280), (680, 1080)]:
        draw.line((x - 26, y - 10, x + 26, y + 10), fill=BLACK, width=DETAIL)

    # tray + bakery arches
    draw.rounded_rectangle((300, 1450, 1748, 1710), radius=30, outline=BLACK, width=MAIN)
    for x in [360, 660, 960, 1260, 1560]:
        draw.arc((x - 80, 380, x + 80, 560), 180, 360, fill=BLACK, width=DETAIL)


def icecream(draw):
    draw.polygon([(850, 760), (1198, 760), (1080, 1500), (968, 1500)], outline=BLACK, width=OUTER)
    for y in [900, 1050, 1200, 1350]:
        draw.line((910, y, 1140, y), fill=BLACK, width=DETAIL)
    for x in [940, 1000, 1060, 1120]:
        draw.line((x, 800, x - 60, 1450), fill=BLACK, width=DETAIL)

    draw.ellipse((680, 430, 1020, 780), outline=BLACK, width=OUTER)
    draw.ellipse((900, 390, 1240, 740), outline=BLACK, width=OUTER)
    draw.ellipse((1120, 430, 1460, 780), outline=BLACK, width=OUTER)

    draw.rectangle((1240, 720, 1300, 980), outline=BLACK, width=MAIN)  # wafer stick
    smiling_face(draw, 1024, 600, 70)


def fried_chicken(draw):
    plate(draw)
    # drumsticks
    for cx, cy in [(760, 1020), (1160, 1060), (980, 1280)]:
        draw.ellipse((cx - 190, cy - 120, cx + 190, cy + 120), outline=BLACK, width=OUTER)
        draw.ellipse((cx + 160, cy - 70, cx + 250, cy + 20), outline=BLACK, width=MAIN)
        draw.ellipse((cx + 160, cy + 20, cx + 250, cy + 110), outline=BLACK, width=MAIN)

    # side dishes
    draw.ellipse((420, 1360, 760, 1600), outline=BLACK, width=MAIN)
    draw.ellipse((1280, 1360, 1620, 1600), outline=BLACK, width=MAIN)

    # napkin
    draw.polygon([(320, 1180), (540, 1140), (620, 1320), (380, 1380)], outline=BLACK, width=DETAIL)


def apple_pie(draw):
    plate(draw)
    draw.ellipse((520, 760, 1528, 1520), outline=BLACK, width=OUTER)
    draw.ellipse((610, 840, 1438, 1440), outline=BLACK, width=MAIN)

    # lattice top
    for x in [700, 840, 980, 1120, 1260, 1400]:
        draw.line((x, 860, x - 180, 1400), fill=BLACK, width=DETAIL)
        draw.line((x - 200, 860, x, 1400), fill=BLACK, width=DETAIL)

    # slice cut out
    draw.polygon([(1024, 1120), (1340, 980), (1360, 1290)], outline=BLACK, width=OUTER)

    # steam
    for x in [900, 1040, 1180]:
        draw.arc((x, 520, x + 90, 700), 200, 340, fill=BLACK, width=DETAIL)

    # fork
    draw.rectangle((1480, 1060, 1560, 1580), outline=BLACK, width=MAIN)
    for i in range(4):
        x = 1470 + i * 30
        draw.line((x, 970, x, 1060), fill=BLACK, width=DETAIL)


def sandwich(draw):
    plate(draw)
    # bread slices
    draw.rounded_rectangle((520, 720, 1528, 1140), radius=120, outline=BLACK, width=OUTER)
    draw.rounded_rectangle((520, 1140, 1528, 1520), radius=80, outline=BLACK, width=OUTER)

    # layers
    draw.rectangle((560, 1120, 1488, 1180), outline=BLACK, width=MAIN)  # lettuce
    draw.rectangle((560, 1180, 1488, 1240), outline=BLACK, width=MAIN)  # cheese
    draw.rectangle((560, 1240, 1488, 1310), outline=BLACK, width=MAIN)  # tomato

    # lunch tray
    draw.rounded_rectangle((380, 1520, 1668, 1730), radius=30, outline=BLACK, width=MAIN)


def milkshake(draw):
    # glass
    draw.polygon([(780, 640), (1268, 640), (1180, 1520), (868, 1520)], outline=BLACK, width=OUTER)
    draw.ellipse((780, 560, 1268, 720), outline=BLACK, width=OUTER)

    # whipped cream
    draw.ellipse((730, 400, 930, 650), outline=BLACK, width=MAIN)
    draw.ellipse((900, 340, 1120, 650), outline=BLACK, width=MAIN)
    draw.ellipse((1080, 400, 1320, 650), outline=BLACK, width=MAIN)

    # straw
    draw.rectangle((1210, 300, 1260, 980), outline=BLACK, width=MAIN)

    # cherry
    draw.ellipse((960, 240, 1070, 350), outline=BLACK, width=MAIN)
    draw.arc((980, 180, 1120, 300), 210, 350, fill=BLACK, width=DETAIL)

    # counter
    draw.rounded_rectangle((300, 1570, 1748, 1760), radius=20, outline=BLACK, width=MAIN)


SCENES = [
    ('usa_food_01_burger.png', burger),
    ('usa_food_02_pizza.png', pizza),
    ('usa_food_03_hotdog.png', hotdog),
    ('usa_food_04_pancakes.png', pancakes),
    ('usa_food_05_donut.png', donut),
    ('usa_food_06_icecream.png', icecream),
    ('usa_food_07_friedchicken.png', fried_chicken),
    ('usa_food_08_applepie.png', apple_pie),
    ('usa_food_09_sandwich.png', sandwich),
    ('usa_food_10_milkshake.png', milkshake),
]


def save_bw(img, path):
    bw = img.point(lambda p: 0 if p < 180 else 255, mode='1').convert('L')
    bw.save(path, format='PNG', optimize=True)


def validate(path):
    img = Image.open(path)
    if img.size != (W, H):
        raise RuntimeError(f'bad size {path.name}: {img.size}')
    vals = set(img.convert('L').getdata())
    if not vals.issubset({0, 255}):
        raise RuntimeError(f'bad grayscale values in {path.name}')


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, fn in SCENES:
        img, draw = canvas()
        fn(draw)
        border(draw)
        save_bw(img, OUT_DIR / name)
    for name, _ in SCENES:
        validate(OUT_DIR / name)


if __name__ == '__main__':
    main()
