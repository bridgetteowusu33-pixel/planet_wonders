#!/usr/bin/env python3
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

W = 2048
H = 2048
BLACK = 0
WHITE = 255
OUTER = 20
MAIN = 12
DETAIL = 6

OUTPUT_DIR = Path('assets/coloring/ghana')


# -----------------------------
# Drawing helpers
# -----------------------------

def new_canvas() -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new('L', (W, H), WHITE)
    draw = ImageDraw.Draw(img)
    return img, draw


def add_border(draw: ImageDraw.ImageDraw) -> None:
    draw.rectangle((36, 36, W - 36, H - 36), outline=BLACK, width=OUTER)


def draw_sun(draw: ImageDraw.ImageDraw, cx: int, cy: int, r: int) -> None:
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), outline=BLACK, width=MAIN)
    for i in range(10):
        a = 2 * math.pi * i / 10
        x1 = cx + int((r + 10) * math.cos(a))
        y1 = cy + int((r + 10) * math.sin(a))
        x2 = cx + int((r + 80) * math.cos(a))
        y2 = cy + int((r + 80) * math.sin(a))
        draw.line((x1, y1, x2, y2), fill=BLACK, width=DETAIL)


def draw_cloud(draw: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int) -> None:
    draw.rounded_rectangle((x, y + h // 3, x + w, y + h), radius=h // 3, outline=BLACK, width=MAIN)
    draw.ellipse((x + w * 0.08, y, x + w * 0.4, y + h * 0.75), outline=BLACK, width=MAIN)
    draw.ellipse((x + w * 0.35, y - h * 0.15, x + w * 0.7, y + h * 0.7), outline=BLACK, width=MAIN)
    draw.ellipse((x + w * 0.62, y + h * 0.05, x + w * 0.95, y + h * 0.78), outline=BLACK, width=MAIN)


def draw_hill(draw: ImageDraw.ImageDraw, points: list[tuple[int, int]]) -> None:
    draw.polygon(points, outline=BLACK, width=MAIN)


def draw_house(draw: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int) -> None:
    body = (x, y + h * 0.28, x + w, y + h)
    draw.rectangle(body, outline=BLACK, width=MAIN)
    roof = [(x - int(w * 0.08), int(y + h * 0.28)), (x + w // 2, y), (x + int(w * 1.08), int(y + h * 0.28))]
    draw.polygon(roof, outline=BLACK, width=MAIN)

    door_w = int(w * 0.2)
    door_h = int(h * 0.42)
    dx1 = x + w // 2 - door_w // 2
    dy1 = y + h - door_h
    draw.rectangle((dx1, dy1, dx1 + door_w, y + h), outline=BLACK, width=MAIN)

    ww = int(w * 0.18)
    wh = int(h * 0.16)
    wx1 = x + int(w * 0.14)
    wx2 = x + int(w * 0.68)
    wy = y + int(h * 0.45)
    draw.rectangle((wx1, wy, wx1 + ww, wy + wh), outline=BLACK, width=DETAIL)
    draw.rectangle((wx2, wy, wx2 + ww, wy + wh), outline=BLACK, width=DETAIL)


def draw_tree(draw: ImageDraw.ImageDraw, x: int, y: int, s: float = 1.0) -> None:
    tw = int(90 * s)
    th = int(230 * s)
    draw.rounded_rectangle((x - tw // 2, y, x + tw // 2, y + th), radius=int(18 * s), outline=BLACK, width=MAIN)
    crowns = [
        (x - int(180 * s), y - int(130 * s), x + int(180 * s), y + int(120 * s)),
        (x - int(230 * s), y - int(20 * s), x - int(20 * s), y + int(220 * s)),
        (x + int(20 * s), y - int(30 * s), x + int(240 * s), y + int(220 * s)),
    ]
    for c in crowns:
        draw.ellipse(c, outline=BLACK, width=MAIN)


def draw_palm(draw: ImageDraw.ImageDraw, x: int, y: int, s: float = 1.0) -> None:
    draw.rounded_rectangle((x - int(26 * s), y, x + int(26 * s), y + int(280 * s)), radius=int(10 * s), outline=BLACK, width=MAIN)
    for i in range(6):
        a = (i - 2.5) * 0.4
        px = x + int(math.cos(a) * 220 * s)
        py = y - int(math.sin(a) * 140 * s) - int(30 * s)
        x0, y0 = x - int(20 * s), y - int(45 * s)
        left, right = sorted((x0, px))
        top, bottom = sorted((y0, py))
        if right - left < 4:
            right = left + 4
        if bottom - top < 4:
            bottom = top + 4
        draw.ellipse((left, top, right, bottom), outline=BLACK, width=MAIN)


def draw_person(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    s: float = 1.0,
    backpack: bool = False,
    raised_hand: bool = False,
    dress: bool = False,
) -> None:
    head_r = int(52 * s)
    draw.ellipse((x - head_r, y - head_r, x + head_r, y + head_r), outline=BLACK, width=MAIN)

    body_top = y + head_r
    body_bottom = y + head_r + int(210 * s)
    bw = int(110 * s)

    if dress:
        body = [(x - bw, body_top), (x + bw, body_top), (x + int(150 * s), body_bottom), (x - int(150 * s), body_bottom)]
        draw.polygon(body, outline=BLACK, width=MAIN)
        for i in range(1, 5):
            yy = body_top + int(i * (body_bottom - body_top) / 5)
            draw.line((x - int(90 * s), yy, x + int(90 * s), yy), fill=BLACK, width=DETAIL)
            draw.line((x - int(70 * s), yy - int(18 * s), x - int(10 * s), yy + int(18 * s)), fill=BLACK, width=DETAIL)
            draw.line((x + int(10 * s), yy + int(18 * s), x + int(70 * s), yy - int(18 * s)), fill=BLACK, width=DETAIL)
    else:
        draw.rounded_rectangle((x - bw, body_top, x + bw, body_bottom), radius=int(20 * s), outline=BLACK, width=MAIN)

    arm_y = body_top + int(65 * s)
    if raised_hand:
        draw.line((x - bw, arm_y, x - int(190 * s), arm_y - int(130 * s)), fill=BLACK, width=MAIN)
        draw.line((x + bw, arm_y, x + int(170 * s), arm_y - int(20 * s)), fill=BLACK, width=MAIN)
    else:
        draw.line((x - bw, arm_y, x - int(180 * s), arm_y + int(40 * s)), fill=BLACK, width=MAIN)
        draw.line((x + bw, arm_y, x + int(180 * s), arm_y + int(40 * s)), fill=BLACK, width=MAIN)

    foot_y = body_bottom + int(170 * s)
    draw.line((x - int(40 * s), body_bottom, x - int(55 * s), foot_y), fill=BLACK, width=MAIN)
    draw.line((x + int(40 * s), body_bottom, x + int(55 * s), foot_y), fill=BLACK, width=MAIN)
    draw.ellipse((x - int(95 * s), foot_y - int(22 * s), x - int(20 * s), foot_y + int(22 * s)), outline=BLACK, width=DETAIL)
    draw.ellipse((x + int(20 * s), foot_y - int(22 * s), x + int(95 * s), foot_y + int(22 * s)), outline=BLACK, width=DETAIL)

    if backpack:
        draw.rounded_rectangle((x + int(70 * s), body_top + int(20 * s), x + int(150 * s), body_bottom - int(10 * s)), radius=int(14 * s), outline=BLACK, width=DETAIL)


def draw_bird(draw: ImageDraw.ImageDraw, x: int, y: int, s: float = 1.0) -> None:
    r = int(26 * s)
    draw.arc((x - r * 2, y - r, x, y + r), 200, 340, fill=BLACK, width=DETAIL)
    draw.arc((x, y - r, x + r * 2, y + r), 200, 340, fill=BLACK, width=DETAIL)


def draw_river(draw: ImageDraw.ImageDraw, top_y: int, bottom_y: int) -> None:
    left = [(860, top_y), (700, top_y + 240), (620, top_y + 520), (560, bottom_y)]
    right = [(1180, top_y), (1320, top_y + 260), (1450, top_y + 520), (1520, bottom_y)]
    draw.line(left, fill=BLACK, width=OUTER)
    draw.line(right, fill=BLACK, width=OUTER)
    draw.line([(1000, top_y + 60), (980, top_y + 300), (940, top_y + 560), (920, bottom_y - 40)], fill=BLACK, width=DETAIL)
    draw.line([(1080, top_y + 40), (1110, top_y + 290), (1180, top_y + 560), (1240, bottom_y - 30)], fill=BLACK, width=DETAIL)


def draw_canoe(draw: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int) -> None:
    hull = [(x, y), (x + w, y), (x + int(w * 0.86), y + h), (x + int(w * 0.14), y + h)]
    draw.polygon(hull, outline=BLACK, width=MAIN)
    draw.line((x + int(w * 0.08), y + int(h * 0.55), x + int(w * 0.92), y + int(h * 0.55)), fill=BLACK, width=DETAIL)


def draw_fish(draw: ImageDraw.ImageDraw, x: int, y: int, s: float = 1.0) -> None:
    bw = int(130 * s)
    bh = int(74 * s)
    draw.ellipse((x - bw, y - bh, x + bw, y + bh), outline=BLACK, width=MAIN)
    tail = [(x + bw, y), (x + bw + int(70 * s), y - int(45 * s)), (x + bw + int(70 * s), y + int(45 * s))]
    draw.polygon(tail, outline=BLACK, width=MAIN)
    draw.ellipse((x - int(70 * s), y - int(12 * s), x - int(40 * s), y + int(12 * s)), outline=BLACK, width=DETAIL)


def draw_boat(draw: ImageDraw.ImageDraw, x: int, y: int, s: float = 1.0) -> None:
    w = int(320 * s)
    h = int(110 * s)
    hull = [(x, y), (x + w, y), (x + int(w * 0.86), y + h), (x + int(w * 0.14), y + h)]
    draw.polygon(hull, outline=BLACK, width=MAIN)
    mast_x = x + w // 2
    draw.line((mast_x, y, mast_x, y - int(240 * s)), fill=BLACK, width=MAIN)
    sail = [(mast_x, y - int(230 * s)), (mast_x + int(170 * s), y - int(120 * s)), (mast_x, y - int(50 * s))]
    draw.polygon(sail, outline=BLACK, width=MAIN)


def draw_drum(draw: ImageDraw.ImageDraw, x: int, y: int, s: float = 1.0) -> None:
    w = int(170 * s)
    h = int(210 * s)
    body = [(x - w, y), (x - int(w * 0.55), y + h), (x + int(w * 0.55), y + h), (x + w, y)]
    draw.polygon(body, outline=BLACK, width=MAIN)
    draw.ellipse((x - w, y - int(30 * s), x + w, y + int(30 * s)), outline=BLACK, width=MAIN)
    draw.ellipse((x - int(w * 0.55), y + h - int(30 * s), x + int(w * 0.55), y + h + int(30 * s)), outline=BLACK, width=MAIN)
    for i in range(5):
        xx = x - int(w * 0.7) + i * int(w * 0.35)
        draw.line((xx, y + int(10 * s), xx, y + h - int(10 * s)), fill=BLACK, width=DETAIL)


def draw_basket(draw: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int) -> None:
    draw.rounded_rectangle((x, y, x + w, y + h), radius=int(min(w, h) * 0.2), outline=BLACK, width=MAIN)
    draw.arc((x + int(w * 0.15), y - int(h * 0.8), x + int(w * 0.85), y + int(h * 0.4)), 190, 350, fill=BLACK, width=MAIN)
    for i in range(4):
        yy = y + int((i + 1) * h / 5)
        draw.line((x + int(w * 0.1), yy, x + int(w * 0.9), yy), fill=BLACK, width=DETAIL)


def draw_lantern(draw: ImageDraw.ImageDraw, x: int, y: int, s: float = 1.0) -> None:
    w = int(120 * s)
    h = int(180 * s)
    draw.rounded_rectangle((x, y, x + w, y + h), radius=int(20 * s), outline=BLACK, width=MAIN)
    draw.ellipse((x + int(20 * s), y + int(35 * s), x + int(100 * s), y + int(145 * s)), outline=BLACK, width=DETAIL)
    draw.arc((x + int(20 * s), y - int(50 * s), x + int(100 * s), y + int(40 * s)), 180, 360, fill=BLACK, width=MAIN)


def draw_star(draw: ImageDraw.ImageDraw, cx: int, cy: int, r: int) -> None:
    pts = []
    for i in range(10):
        rr = r if i % 2 == 0 else int(r * 0.45)
        a = -math.pi / 2 + i * math.pi / 5
        pts.append((cx + int(rr * math.cos(a)), cy + int(rr * math.sin(a))))
    draw.polygon(pts, outline=BLACK, width=DETAIL)


def draw_soccer_ball(draw: ImageDraw.ImageDraw, x: int, y: int, r: int) -> None:
    draw.ellipse((x - r, y - r, x + r, y + r), outline=BLACK, width=MAIN)
    pent = []
    for i in range(5):
        a = -math.pi / 2 + i * 2 * math.pi / 5
        pent.append((x + int(r * 0.42 * math.cos(a)), y + int(r * 0.42 * math.sin(a))))
    draw.polygon(pent, outline=BLACK, width=DETAIL)


def draw_chicken(draw: ImageDraw.ImageDraw, x: int, y: int, s: float = 1.0) -> None:
    draw.ellipse((x - int(90 * s), y - int(55 * s), x + int(90 * s), y + int(55 * s)), outline=BLACK, width=MAIN)
    draw.ellipse((x + int(65 * s), y - int(95 * s), x + int(135 * s), y - int(25 * s)), outline=BLACK, width=MAIN)
    beak = [(x + int(135 * s), y - int(65 * s)), (x + int(175 * s), y - int(50 * s)), (x + int(135 * s), y - int(35 * s))]
    draw.polygon(beak, outline=BLACK, width=DETAIL)
    tail = [(x - int(90 * s), y - int(20 * s)), (x - int(145 * s), y - int(90 * s)), (x - int(110 * s), y)]
    draw.polygon(tail, outline=BLACK, width=DETAIL)


def draw_thought_bubble(draw: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int) -> None:
    draw.ellipse((x, y, x + w, y + h), outline=BLACK, width=MAIN)


def finalize(img: Image.Image, out_path: Path) -> None:
    bw = img.point(lambda p: 0 if p < 180 else 255, mode='1').convert('L')
    bw.save(out_path, format='PNG', optimize=True)


# -----------------------------
# Scene builders
# -----------------------------

def scene_01_home(draw: ImageDraw.ImageDraw) -> None:
    draw_cloud(draw, 240, 170, 430, 220)
    draw_cloud(draw, 1280, 220, 420, 210)
    draw_sun(draw, 1700, 250, 110)
    draw_hill(draw, [(70, 1180), (520, 980), (980, 1120), (1460, 940), (1978, 1160), (1978, 1978), (70, 1978)])

    draw_house(draw, 240, 720, 720, 700)
    draw_tree(draw, 1370, 760, 1.1)
    draw_tree(draw, 1760, 900, 0.85)

    draw_person(draw, 950, 1140, 0.9, raised_hand=True)
    draw_person(draw, 1220, 1120, 0.95)
    draw_person(draw, 1090, 1260, 0.78, dress=True)

    draw_basket(draw, 470, 1480, 220, 160)
    draw_basket(draw, 760, 1520, 210, 150)


def scene_02_village(draw: ImageDraw.ImageDraw) -> None:
    draw_sun(draw, 320, 300, 120)
    draw_cloud(draw, 820, 160, 440, 220)
    draw_cloud(draw, 1370, 260, 370, 180)
    for bx in [340, 510, 1700, 1560]:
        draw_bird(draw, bx, 220, 1.0)

    for i, x in enumerate([180, 540, 900, 1260, 1600]):
        draw_house(draw, x, 880 + (i % 2) * 50, 300, 430)

    path = [(980, 950), (850, 1220), (740, 1500), (660, 1978), (1320, 1978), (1240, 1500), (1120, 1220)]
    draw.polygon(path, outline=BLACK, width=MAIN)

    draw_person(draw, 860, 1180, 0.8, backpack=True)
    draw_person(draw, 1050, 1220, 0.82, backpack=True)
    draw_person(draw, 1240, 1160, 0.78, backpack=True)


def scene_03_school(draw: ImageDraw.ImageDraw) -> None:
    draw_cloud(draw, 220, 220, 420, 200)
    draw_cloud(draw, 1380, 200, 420, 210)

    # school building
    draw.rectangle((430, 700, 1618, 1490), outline=BLACK, width=OUTER)
    draw.polygon([(380, 700), (1024, 470), (1668, 700)], outline=BLACK, width=OUTER)
    draw.rectangle((920, 1080, 1128, 1490), outline=BLACK, width=MAIN)
    for x in [560, 760, 1260, 1460]:
        draw.rectangle((x, 860, x + 150, 1000), outline=BLACK, width=DETAIL)

    draw.line((1024, 470, 1024, 280), fill=BLACK, width=MAIN)
    draw.polygon([(1024, 280), (1180, 350), (1024, 420)], outline=BLACK, width=MAIN)

    draw_person(draw, 740, 1420, 0.75, backpack=True)
    draw_person(draw, 1040, 1460, 0.75, backpack=True)
    draw_person(draw, 1290, 1420, 0.75, backpack=True)
    draw_person(draw, 1570, 1180, 0.78, raised_hand=True)


def scene_04_forest(draw: ImageDraw.ImageDraw) -> None:
    for x, s in [(250, 1.25), (620, 1.1), (1450, 1.22), (1780, 1.0)]:
        draw_tree(draw, x, 520, s)
    draw_cloud(draw, 780, 180, 470, 210)

    draw_river(draw, 860, 1900)
    draw_person(draw, 420, 1310, 0.78)

    # monkeys
    for x, y in [(700, 850), (1340, 810)]:
        draw.ellipse((x - 80, y - 60, x + 80, y + 60), outline=BLACK, width=MAIN)
        draw.ellipse((x - 55, y - 130, x + 55, y - 20), outline=BLACK, width=MAIN)
        draw.arc((x + 60, y - 20, x + 220, y + 140), 200, 360, fill=BLACK, width=DETAIL)

    for bx, by in [(980, 650), (1150, 760), (520, 700), (1580, 700)]:
        draw_bird(draw, bx, by, 0.9)


def scene_05_river(draw: ImageDraw.ImageDraw) -> None:
    draw_cloud(draw, 220, 200, 450, 220)
    draw_cloud(draw, 1280, 170, 500, 230)
    draw_palm(draw, 240, 760, 1.0)
    draw_palm(draw, 1760, 860, 0.95)

    draw_river(draw, 760, 1960)
    draw_canoe(draw, 760, 1040, 560, 170)
    draw_person(draw, 1030, 840, 0.72)
    draw.line((1140, 900, 1320, 1180), fill=BLACK, width=DETAIL)

    draw_fish(draw, 1500, 1280, 0.9)
    draw_fish(draw, 520, 1420, 0.7)
    draw_fish(draw, 1460, 1540, 0.65)


def scene_06_beach(draw: ImageDraw.ImageDraw) -> None:
    draw_sun(draw, 1700, 270, 100)
    draw_cloud(draw, 280, 220, 420, 190)

    # horizon and shore
    draw.line((80, 820, 1968, 820), fill=BLACK, width=MAIN)
    shore = [(80, 1260), (480, 1180), (940, 1280), (1420, 1160), (1968, 1260), (1968, 1978), (80, 1978)]
    draw.polygon(shore, outline=BLACK, width=MAIN)

    draw_boat(draw, 280, 920, 0.9)
    draw_boat(draw, 1220, 960, 0.8)

    for i in range(6):
        y = 1370 + i * 85
        draw.arc((160, y, 1890, y + 120), 185, 355, fill=BLACK, width=DETAIL)

    draw_person(draw, 640, 1440, 0.72)
    draw_person(draw, 860, 1480, 0.68)
    draw_basket(draw, 1010, 1570, 180, 130)


def scene_07_kente(draw: ImageDraw.ImageDraw) -> None:
    draw_cloud(draw, 260, 190, 420, 210)
    draw_cloud(draw, 1360, 230, 420, 180)

    draw_person(draw, 1024, 930, 1.12, dress=True)
    draw_person(draw, 690, 1010, 0.92, dress=True)
    draw_person(draw, 1360, 1010, 0.92, dress=True)

    draw_drum(draw, 490, 1360, 1.0)
    draw_drum(draw, 1560, 1360, 1.0)

    ground = [(80, 1410), (420, 1290), (950, 1360), (1480, 1290), (1968, 1410), (1968, 1978), (80, 1978)]
    draw.polygon(ground, outline=BLACK, width=MAIN)


def scene_08_festival(draw: ImageDraw.ImageDraw) -> None:
    # decorations
    draw.line((130, 220, 1918, 220), fill=BLACK, width=MAIN)
    for i in range(10):
        x1 = 160 + i * 180
        tri = [(x1, 220), (x1 + 70, 340), (x1 + 140, 220)]
        draw.polygon(tri, outline=BLACK, width=DETAIL)

    draw_person(draw, 620, 1000, 0.92, dress=True)
    draw_person(draw, 880, 950, 0.95, raised_hand=True)
    draw_person(draw, 1180, 1010, 0.92, dress=True)
    draw_person(draw, 1440, 970, 0.95, raised_hand=True)

    draw_person(draw, 350, 1320, 0.72)
    draw_person(draw, 1710, 1320, 0.72)
    draw_drum(draw, 1024, 1360, 1.15)

    stage = [(100, 1450), (1948, 1450), (1948, 1978), (100, 1978)]
    draw.polygon(stage, outline=BLACK, width=MAIN)


def scene_09_market(draw: ImageDraw.ImageDraw) -> None:
    draw_cloud(draw, 200, 180, 420, 190)
    draw_cloud(draw, 1420, 160, 430, 200)

    # stalls
    for i, x in enumerate([150, 700, 1250]):
        draw.rectangle((x, 700, x + 550, 1300), outline=BLACK, width=MAIN)
        roof = [(x - 30, 700), (x + 275, 520 + i * 20), (x + 580, 700)]
        draw.polygon(roof, outline=BLACK, width=MAIN)
        for c in range(4):
            xx = x + 70 + c * 120
            draw.ellipse((xx, 980, xx + 90, 1070), outline=BLACK, width=DETAIL)

    draw_basket(draw, 250, 1450, 260, 180)
    draw_basket(draw, 630, 1490, 220, 160)
    draw_basket(draw, 1420, 1450, 280, 190)

    draw_person(draw, 500, 1220, 0.72)
    draw_person(draw, 1040, 1180, 0.76)
    draw_person(draw, 1560, 1220, 0.74)


def scene_10_cooking(draw: ImageDraw.ImageDraw) -> None:
    draw_cloud(draw, 280, 180, 450, 200)
    draw_cloud(draw, 1330, 220, 420, 180)

    # outdoor hut line
    draw.line((180, 760, 1860, 760), fill=BLACK, width=MAIN)

    # pot and fire
    draw.ellipse((820, 1030, 1230, 1290), outline=BLACK, width=OUTER)
    draw.rectangle((860, 930, 1190, 1030), outline=BLACK, width=MAIN)
    flame = [(960, 1320), (1024, 1180), (1088, 1320), (1150, 1200), (1220, 1360), (820, 1360), (900, 1200)]
    draw.polygon(flame, outline=BLACK, width=MAIN)

    draw_person(draw, 560, 1000, 0.92, raised_hand=True)
    draw_person(draw, 1490, 1000, 0.92)
    draw_person(draw, 1024, 1440, 0.7)

    # vegetables basket
    draw_basket(draw, 280, 1420, 280, 190)
    for x in [320, 390, 470, 520]:
        draw.ellipse((x, 1450, x + 80, 1530), outline=BLACK, width=DETAIL)


def scene_11_food(draw: ImageDraw.ImageDraw) -> None:
    draw_cloud(draw, 240, 170, 420, 190)
    draw_cloud(draw, 1360, 180, 430, 200)

    # table
    draw.rounded_rectangle((180, 960, 1860, 1760), radius=60, outline=BLACK, width=OUTER)

    # plates and bowls
    draw.ellipse((300, 1080, 820, 1480), outline=BLACK, width=MAIN)   # jollof
    draw.ellipse((930, 1030, 1500, 1510), outline=BLACK, width=MAIN)  # banku
    draw.ellipse((1260, 1170, 1770, 1600), outline=BLACK, width=MAIN) # fish stew
    draw.ellipse((430, 1450, 980, 1700), outline=BLACK, width=MAIN)   # plantain

    # inner food contours
    for x in [390, 470, 560, 650, 730]:
        draw.arc((x, 1500, x + 140, 1660), 20, 340, fill=BLACK, width=DETAIL)
    for x in [1030, 1140, 1250]:
        draw.ellipse((x, 1160, x + 150, 1300), outline=BLACK, width=DETAIL)
    draw_fish(draw, 1510, 1380, 0.92)


def scene_12_helping(draw: ImageDraw.ImageDraw) -> None:
    draw_cloud(draw, 240, 190, 420, 190)
    draw_cloud(draw, 1340, 210, 420, 180)

    draw_person(draw, 780, 1020, 0.9)

    # watering can
    draw.rounded_rectangle((920, 1160, 1100, 1300), radius=26, outline=BLACK, width=MAIN)
    draw.arc((900, 1120, 1120, 1280), 180, 330, fill=BLACK, width=DETAIL)
    draw.line((1100, 1220, 1240, 1160), fill=BLACK, width=MAIN)
    for i in range(4):
        x = 1235 + i * 22
        draw.line((x, 1180, x + 20, 1240), fill=BLACK, width=DETAIL)

    # plants
    for x in [1310, 1480, 1650]:
        draw_basket(draw, x, 1380, 150, 120)
        draw.ellipse((x + 20, 1260, x + 130, 1400), outline=BLACK, width=MAIN)

    # chickens
    draw_chicken(draw, 520, 1500, 1.0)
    draw_chicken(draw, 780, 1620, 0.75)

    # coop
    draw.rectangle((220, 1260, 520, 1540), outline=BLACK, width=MAIN)
    draw.polygon([(200, 1260), (370, 1140), (540, 1260)], outline=BLACK, width=MAIN)


def scene_13_football(draw: ImageDraw.ImageDraw) -> None:
    draw_cloud(draw, 220, 180, 420, 190)
    draw_cloud(draw, 1380, 190, 430, 200)

    # field boundaries
    draw.rectangle((180, 720, 1860, 1780), outline=BLACK, width=MAIN)
    draw.line((1024, 720, 1024, 1780), fill=BLACK, width=DETAIL)
    draw.ellipse((854, 1040, 1194, 1380), outline=BLACK, width=DETAIL)

    # goals
    draw.rectangle((180, 1060, 360, 1460), outline=BLACK, width=MAIN)
    draw.rectangle((1688, 1060, 1860, 1460), outline=BLACK, width=MAIN)

    draw_person(draw, 840, 1180, 0.78)
    draw_person(draw, 1210, 1160, 0.82)
    draw_person(draw, 560, 1320, 0.72)
    draw_person(draw, 1480, 1320, 0.72)
    draw_person(draw, 350, 980, 0.62, raised_hand=True)
    draw_person(draw, 1690, 980, 0.62, raised_hand=True)

    draw_soccer_ball(draw, 1030, 1340, 85)


def scene_14_storytime(draw: ImageDraw.ImageDraw) -> None:
    # night scene elements as line art
    draw.ellipse((1540, 150, 1760, 370), outline=BLACK, width=MAIN)  # moon
    draw.ellipse((1620, 160, 1740, 300), outline=WHITE, width=1)  # tiny masking nudge via white line
    for sx, sy, r in [(220, 220, 24), (420, 140, 20), (620, 260, 22), (1320, 190, 18), (1840, 290, 20)]:
        draw_star(draw, sx, sy, r)

    draw_cloud(draw, 220, 320, 400, 170)
    draw_cloud(draw, 1280, 330, 420, 180)

    # ground arc
    draw.polygon([(80, 1360), (380, 1240), (860, 1320), (1260, 1240), (1968, 1380), (1968, 1978), (80, 1978)], outline=BLACK, width=MAIN)

    draw_lantern(draw, 970, 1120, 1.0)
    draw_person(draw, 700, 1180, 0.82)
    draw_person(draw, 1020, 1240, 0.72)
    draw_person(draw, 1320, 1180, 0.82)

    # storytelling bubbles
    draw_thought_bubble(draw, 560, 780, 220, 160)
    draw_thought_bubble(draw, 1240, 760, 240, 180)


def scene_15_dreams(draw: ImageDraw.ImageDraw) -> None:
    draw_sun(draw, 340, 340, 120)
    draw_cloud(draw, 730, 180, 450, 210)
    draw_cloud(draw, 1380, 250, 420, 180)

    # afia
    draw_person(draw, 1024, 1260, 1.0, dress=True)

    # thought bubbles for careers
    bubbles = [
        (250, 600, 360, 260),
        (670, 470, 360, 260),
        (1090, 500, 360, 260),
        (1510, 630, 360, 260),
    ]
    for b in bubbles:
        draw_thought_bubble(draw, *b)

    # icon: doctor cross
    draw.rectangle((390, 700, 470, 790), outline=BLACK, width=MAIN)
    draw.rectangle((350, 735, 510, 755), outline=BLACK, width=MAIN)

    # icon: pilot plane
    draw.polygon([(790, 610), (910, 650), (980, 620), (910, 700)], outline=BLACK, width=MAIN)
    draw.line((820, 650, 910, 650), fill=BLACK, width=DETAIL)

    # icon: teacher board
    draw.rectangle((1160, 610, 1360, 760), outline=BLACK, width=MAIN)
    draw.line((1200, 760, 1180, 820), fill=BLACK, width=DETAIL)
    draw.line((1320, 760, 1340, 820), fill=BLACK, width=DETAIL)

    # icon: engineer gear-ish
    cx, cy, r = 1690, 760, 70
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), outline=BLACK, width=MAIN)
    for i in range(8):
        a = 2 * math.pi * i / 8
        x1 = cx + int((r + 5) * math.cos(a))
        y1 = cy + int((r + 5) * math.sin(a))
        x2 = cx + int((r + 40) * math.cos(a))
        y2 = cy + int((r + 40) * math.sin(a))
        draw.line((x1, y1, x2, y2), fill=BLACK, width=DETAIL)

    # foreground
    draw.polygon([(80, 1560), (450, 1460), (900, 1540), (1370, 1460), (1968, 1600), (1968, 1978), (80, 1978)], outline=BLACK, width=MAIN)


SCENES = [
    ('ghana_01_home.png', scene_01_home),
    ('ghana_02_village.png', scene_02_village),
    ('ghana_03_school.png', scene_03_school),
    ('ghana_04_forest.png', scene_04_forest),
    ('ghana_05_river.png', scene_05_river),
    ('ghana_06_beach.png', scene_06_beach),
    ('ghana_07_kente.png', scene_07_kente),
    ('ghana_08_festival.png', scene_08_festival),
    ('ghana_09_market.png', scene_09_market),
    ('ghana_10_cooking.png', scene_10_cooking),
    ('ghana_11_food.png', scene_11_food),
    ('ghana_12_helping.png', scene_12_helping),
    ('ghana_13_football.png', scene_13_football),
    ('ghana_14_storytime.png', scene_14_storytime),
    ('ghana_15_dreams.png', scene_15_dreams),
]


def validate(path: Path) -> None:
    img = Image.open(path)
    if img.size != (W, H):
        raise RuntimeError(f'{path.name} has wrong size: {img.size}')
    px = img.convert('L').getdata()
    vals = set(px)
    if not vals.issubset({0, 255}):
        bad = sorted(v for v in vals if v not in {0, 255})
        raise RuntimeError(f'{path.name} has non-bw values: {bad[:10]}')


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for name, fn in SCENES:
        img, draw = new_canvas()
        fn(draw)
        add_border(draw)
        out_path = OUTPUT_DIR / name
        finalize(img, out_path)

    for name, _ in SCENES:
        validate(OUTPUT_DIR / name)


if __name__ == '__main__':
    main()
