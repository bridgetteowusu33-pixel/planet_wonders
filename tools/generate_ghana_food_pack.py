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

OUT_DIR = Path('assets/coloring/ghana/food')


def new_canvas() -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new('L', (W, H), WHITE)
    draw = ImageDraw.Draw(img)
    return img, draw


def add_border(draw: ImageDraw.ImageDraw) -> None:
    draw.rectangle((36, 36, W - 36, H - 36), outline=BLACK, width=OUTER)


def draw_plate(draw: ImageDraw.ImageDraw, x1=230, y1=960, x2=1818, y2=1760) -> None:
    draw.ellipse((x1, y1, x2, y2), outline=BLACK, width=OUTER)
    draw.ellipse((x1 + 95, y1 + 70, x2 - 95, y2 - 70), outline=BLACK, width=MAIN)


def draw_bowl(draw: ImageDraw.ImageDraw, x1=430, y1=760, x2=1618, y2=1580) -> None:
    draw.ellipse((x1, y1, x2, y2), outline=BLACK, width=OUTER)
    draw.arc((x1 + 60, y1 + 40, x2 - 60, y2 - 60), 180, 360, fill=BLACK, width=MAIN)


def draw_spoon(draw: ImageDraw.ImageDraw, x: int, y: int, length: int = 560, angle: float = -0.55) -> None:
    x2 = x + int(length * math.cos(angle))
    y2 = y + int(length * math.sin(angle))
    draw.line((x, y, x2, y2), fill=BLACK, width=MAIN)
    draw.ellipse((x2 - 70, y2 - 50, x2 + 70, y2 + 50), outline=BLACK, width=MAIN)


def draw_tomato(draw: ImageDraw.ImageDraw, cx: int, cy: int, r: int) -> None:
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), outline=BLACK, width=MAIN)
    for i in range(5):
        a = i * 2 * math.pi / 5
        x = cx + int(r * 0.6 * math.cos(a))
        y = cy + int(r * 0.6 * math.sin(a))
        draw.line((cx, cy, x, y), fill=BLACK, width=DETAIL)


def draw_pepper(draw: ImageDraw.ImageDraw, x: int, y: int, s: float = 1.0) -> None:
    w = int(160 * s)
    h = int(230 * s)
    draw.ellipse((x, y, x + w, y + h), outline=BLACK, width=MAIN)
    draw.line((x + w // 2, y, x + w // 2, y - int(50 * s)), fill=BLACK, width=DETAIL)


def draw_leaf(draw: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int) -> None:
    draw.ellipse((x, y, x + w, y + h), outline=BLACK, width=MAIN)
    draw.line((x + 20, y + h // 2, x + w - 20, y + h // 2), fill=BLACK, width=DETAIL)


def draw_fish(draw: ImageDraw.ImageDraw, cx: int, cy: int, s: float = 1.0) -> None:
    w = int(260 * s)
    h = int(130 * s)
    draw.ellipse((cx - w, cy - h, cx + w, cy + h), outline=BLACK, width=MAIN)
    tail = [(cx + w, cy), (cx + w + int(120 * s), cy - int(75 * s)), (cx + w + int(120 * s), cy + int(75 * s))]
    draw.polygon(tail, outline=BLACK, width=MAIN)
    draw.ellipse((cx - int(w * 0.7), cy - int(h * 0.15), cx - int(w * 0.55), cy + int(h * 0.15)), outline=BLACK, width=DETAIL)


def draw_egg(draw: ImageDraw.ImageDraw, cx: int, cy: int, w: int = 170, h: int = 230) -> None:
    draw.ellipse((cx - w // 2, cy - h // 2, cx + w // 2, cy + h // 2), outline=BLACK, width=MAIN)


def draw_meat_chunk(draw: ImageDraw.ImageDraw, x: int, y: int, w: int = 170, h: int = 130) -> None:
    draw.rounded_rectangle((x, y, x + w, y + h), radius=24, outline=BLACK, width=MAIN)


def draw_mortar_pestle(draw: ImageDraw.ImageDraw, x: int, y: int) -> None:
    draw.ellipse((x, y, x + 360, y + 220), outline=BLACK, width=OUTER)
    draw.rectangle((x + 50, y + 110, x + 310, y + 240), outline=BLACK, width=MAIN)
    draw.rounded_rectangle((x + 190, y - 120, x + 300, y + 80), radius=20, outline=BLACK, width=MAIN)


def draw_ladle(draw: ImageDraw.ImageDraw, x: int, y: int, length: int = 520, angle: float = 0.25) -> None:
    x2 = x + int(length * math.cos(angle))
    y2 = y + int(length * math.sin(angle))
    draw.line((x, y, x2, y2), fill=BLACK, width=MAIN)
    draw.ellipse((x - 110, y - 80, x + 110, y + 80), outline=BLACK, width=MAIN)


def draw_grill(draw: ImageDraw.ImageDraw, x: int, y: int, w: int = 1000, h: int = 420) -> None:
    draw.rounded_rectangle((x, y, x + w, y + h), radius=36, outline=BLACK, width=OUTER)
    for i in range(1, 7):
        yy = y + i * h // 7
        draw.line((x + 40, yy, x + w - 40, yy), fill=BLACK, width=DETAIL)
    for i in range(1, 6):
        xx = x + i * w // 6
        draw.line((xx, y + 30, xx, y + h - 30), fill=BLACK, width=DETAIL)


def draw_bread_ball(draw: ImageDraw.ImageDraw, cx: int, cy: int, r: int = 80) -> None:
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), outline=BLACK, width=MAIN)


def draw_palm_fruit(draw: ImageDraw.ImageDraw, cx: int, cy: int, r: int = 70) -> None:
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), outline=BLACK, width=MAIN)
    draw.arc((cx - int(r * 0.6), cy - int(r * 0.5), cx + int(r * 0.6), cy + int(r * 0.7)), 210, 330, fill=BLACK, width=DETAIL)


def scene_jollof(draw: ImageDraw.ImageDraw) -> None:
    draw_plate(draw)
    draw_bowl(draw, 450, 740, 1598, 1560)
    for x, y in [(760, 1030), (900, 980), (1040, 1060), (1180, 980), (1320, 1050), (860, 1180), (1020, 1220), (1220, 1180)]:
        draw_meat_chunk(draw, x - 52, y - 42, 104, 84)
    draw_spoon(draw, 1450, 780)
    draw_tomato(draw, 360, 1390, 90)
    draw_tomato(draw, 1660, 1380, 80)
    draw_pepper(draw, 300, 1520, 0.7)
    draw_pepper(draw, 1690, 1520, 0.7)


def scene_plantain(draw: ImageDraw.ImageDraw) -> None:
    draw_plate(draw)
    for i in range(7):
        x = 560 + i * 150
        y = 980 + (i % 2) * 120
        draw.ellipse((x, y, x + 260, y + 140), outline=BLACK, width=OUTER)
        draw.arc((x + 50, y + 40, x + 210, y + 120), 180, 360, fill=BLACK, width=DETAIL)
    draw_bowl(draw, 1280, 1240, 1710, 1650)
    for x in [1360, 1460, 1560]:
        draw_pepper(draw, x, 1380, 0.38)
    draw_leaf(draw, 250, 1280, 280, 200)
    draw_leaf(draw, 1500, 840, 320, 230)


def scene_banku(draw: ImageDraw.ImageDraw) -> None:
    draw_plate(draw)
    draw_bowl(draw, 430, 780, 1618, 1580)
    draw_egg(draw, 760, 1080, 230, 280)
    draw_egg(draw, 1040, 1110, 230, 280)
    draw_fish(draw, 1380, 1120, 0.65)
    draw_pepper(draw, 1360, 1320, 0.5)
    draw_pepper(draw, 1480, 1320, 0.46)
    draw_spoon(draw, 520, 760, 520, -0.95)


def scene_fufu(draw: ImageDraw.ImageDraw) -> None:
    draw_plate(draw)
    draw_bowl(draw, 460, 800, 1588, 1580)
    draw_egg(draw, 980, 1140, 300, 340)
    draw_egg(draw, 1210, 1160, 260, 300)
    draw_fish(draw, 730, 1260, 0.56)
    draw_mortar_pestle(draw, 180, 1220)
    draw_spoon(draw, 1560, 860, 460, -0.45)


def scene_waakye(draw: ImageDraw.ImageDraw) -> None:
    draw_plate(draw)
    draw_bowl(draw, 420, 760, 1628, 1580)
    for x, y in [(700, 1020), (840, 980), (980, 1040), (1120, 980), (1260, 1040), (760, 1170), (920, 1230), (1080, 1180), (1240, 1230)]:
        draw_meat_chunk(draw, x - 46, y - 36, 92, 72)
    draw_egg(draw, 1370, 1040, 170, 220)
    for i in range(4):
        draw.arc((1260 + i * 50, 1160, 1390 + i * 50, 1320), 180, 360, fill=BLACK, width=MAIN)
    draw_fish(draw, 1420, 1280, 0.48)


def scene_koko(draw: ImageDraw.ImageDraw) -> None:
    draw_bowl(draw, 460, 850, 1460, 1560)
    draw_spoon(draw, 1350, 860, 500, -0.6)

    # cup
    draw.rounded_rectangle((1500, 980, 1780, 1480), radius=40, outline=BLACK, width=OUTER)
    draw.arc((1740, 1120, 1910, 1320), 240, 120, fill=BLACK, width=MAIN)

    # bread balls
    draw_plate(draw, 230, 1400, 1200, 1900)
    draw_bread_ball(draw, 520, 1640, 92)
    draw_bread_ball(draw, 740, 1620, 82)
    draw_bread_ball(draw, 920, 1660, 88)


def scene_kelewele(draw: ImageDraw.ImageDraw) -> None:
    draw_plate(draw)
    draw_bowl(draw, 460, 780, 1588, 1540)
    for r in range(4):
        for c in range(5):
            x = 640 + c * 180 + (r % 2) * 40
            y = 930 + r * 130
            draw.rounded_rectangle((x, y, x + 120, y + 90), radius=20, outline=BLACK, width=MAIN)
    draw_pepper(draw, 340, 1350, 0.72)
    draw_pepper(draw, 500, 1460, 0.58)
    draw_leaf(draw, 1520, 1320, 260, 180)


def scene_groundnut(draw: ImageDraw.ImageDraw) -> None:
    draw_plate(draw)
    draw_bowl(draw, 430, 760, 1618, 1580)
    for x, y in [(760, 1060), (980, 980), (1200, 1080), (900, 1220), (1140, 1260), (1320, 1200)]:
        draw_meat_chunk(draw, x - 70, y - 50, 140, 100)
    draw_ladle(draw, 420, 880, 620, 0.35)


def scene_tilapia(draw: ImageDraw.ImageDraw) -> None:
    draw_grill(draw, 520, 980, 1000, 420)
    draw_fish(draw, 1020, 1190, 1.05)

    # garnishes
    draw_pepper(draw, 320, 1440, 0.62)
    draw_pepper(draw, 430, 1460, 0.54)
    for cx in [1540, 1680, 1820]:
        draw.ellipse((cx - 70, 1420, cx + 70, 1560), outline=BLACK, width=MAIN)
        draw.line((cx - 60, 1490, cx + 60, 1490), fill=BLACK, width=DETAIL)

    # onion rings
    for cx in [620, 760, 900]:
        draw.ellipse((cx - 60, 1440, cx + 60, 1560), outline=BLACK, width=MAIN)
        draw.ellipse((cx - 30, 1470, cx + 30, 1530), outline=BLACK, width=DETAIL)


def scene_palmnut(draw: ImageDraw.ImageDraw) -> None:
    draw_plate(draw)
    draw_bowl(draw, 440, 770, 1608, 1580)
    draw_fish(draw, 760, 1170, 0.55)
    for x, y in [(980, 1020), (1160, 980), (1320, 1080), (1050, 1240), (1240, 1280)]:
        draw_meat_chunk(draw, x - 70, y - 52, 140, 104)
    for cx, cy in [(340, 1460), (460, 1560), (1620, 1480), (1750, 1580), (1500, 1630)]:
        draw_palm_fruit(draw, cx, cy, 62)


SCENES = [
    ('ghana_food_01_jollof.png', scene_jollof),
    ('ghana_food_02_plantain.png', scene_plantain),
    ('ghana_food_03_banku.png', scene_banku),
    ('ghana_food_04_fufu.png', scene_fufu),
    ('ghana_food_05_waakye.png', scene_waakye),
    ('ghana_food_06_koko.png', scene_koko),
    ('ghana_food_07_kelewele.png', scene_kelewele),
    ('ghana_food_08_groundnut.png', scene_groundnut),
    ('ghana_food_09_tilapia.png', scene_tilapia),
    ('ghana_food_10_palmnut.png', scene_palmnut),
]


def finalize(img: Image.Image, out_path: Path) -> None:
    # Hard-threshold to pure B/W for fill safety.
    bw = img.point(lambda p: 0 if p < 180 else 255, mode='1').convert('L')
    bw.save(out_path, format='PNG', optimize=True)


def validate(path: Path) -> None:
    img = Image.open(path)
    if img.format != 'PNG':
        raise RuntimeError(f'{path.name} is not PNG')
    if img.size != (W, H):
        raise RuntimeError(f'{path.name} size is {img.size}, expected {(W, H)}')
    vals = set(img.convert('L').getdata())
    if not vals.issubset({0, 255}):
        bad = sorted(v for v in vals if v not in {0, 255})
        raise RuntimeError(f'{path.name} contains non-BW values: {bad[:10]}')


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    for name, fn in SCENES:
        img, draw = new_canvas()
        fn(draw)
        add_border(draw)
        finalize(img, OUT_DIR / name)

    for name, _ in SCENES:
        validate(OUT_DIR / name)


if __name__ == '__main__':
    main()
