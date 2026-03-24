#!/usr/bin/env python3
"""
Snake Sprite Generator — generates 16 sprites per skin (32x32 PNG).
Skins: neon_green, hot_pink, fire, ice, galaxy
"""

from PIL import Image, ImageDraw
import os

# Skin definitions: (head_color, body_color, tail_color, glow_color)
SKINS = {
    "neon_green": ("#4ade80", "#22c55e", "#16a34a", "#4ade80"),
    "hot_pink":   ("#f472b6", "#ec4899", "#db2777", "#f472b6"),
    "fire":       ("#f97316", "#ea580c", "#c2410c", "#f97316"),
    "ice":        ("#38bdf8", "#0ea5e9", "#0284c7", "#38bdf8"),
    "galaxy":     ("#a855f7", "#9333ea", "#7e22ce", "#a855f7"),
}

SKIN_DIR = "/Users/liyi/Projects/snake-game/assets/sprites/skins"
SIZE = 32


def hex_to_rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))


def draw_rounded_rect(draw, xy, radius, fill, outline=None, width=1):
    x1, y1, x2, y2 = xy
    r = radius
    draw.rectangle([x1 + r, y1, x2 - r, y2], fill=fill)
    draw.rectangle([x1, y1 + r, x2, y2 - r], fill=fill)
    draw.pieslice([x1, y1, x1 + 2*r, y1 + 2*r], 180, 270, fill=fill)
    draw.pieslice([x2 - 2*r, y1, x2, y1 + 2*r], 270, 360, fill=fill)
    draw.pieslice([x1, y2 - 2*r, x1 + 2*r, y2], 90, 180, fill=fill)
    draw.pieslice([x2 - 2*r, y2 - 2*r, x2, y2], 0, 90, fill=fill)
    if outline:
        draw.rectangle([x1 + r, y1, x2 - r, y1 + width], fill=outline)
        draw.rectangle([x1 + r, y2 - width, x2 - r, y2], fill=outline)
        draw.rectangle([x1, y1 + r, x1 + width, y2 - r], fill=outline)
        draw.rectangle([x2 - width, y1 + r, x2, y2 - r], fill=outline)
        draw.arc([x1, y1, x1 + 2*r, y1 + 2*r], 180, 270, fill=outline, width=width)
        draw.arc([x2 - 2*r, y1, x2, y1 + 2*r], 270, 360, fill=outline, width=width)
        draw.arc([x1, y2 - 2*r, x1 + 2*r, y2], 90, 180, fill=outline, width=width)
        draw.arc([x2 - 2*r, y2 - 2*r, x2, y2], 0, 90, fill=outline, width=width)


def make_glow(size, color, amount=6):
    """Create a small glow halo image."""
    img = Image.new("RGBA", (size + amount*2, size + amount*2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx = (size + amount*2) // 2
    cy = (size + amount*2) // 2
    r = size // 2 + amount
    base_r, base_g, base_b = color
    for i in range(amount, 0, -1):
        alpha = int(60 * (1 - i / amount))
        fill = (base_r, base_g, base_b, alpha)
        draw.ellipse([cx - r + i*2, cy - r + i*2,
                      cx + r - i*2, cy + r - i*2], fill=fill)
    return img


def create_head(direction, head_color, body_color):
    """Create a snake head sprite facing a direction."""
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    r, g, b = hex_to_rgb(head_color)

    if direction == "up":
        # Tongue
        draw.polygon([(16, 4), (14, 10), (18, 10)], fill=(220, 50, 50))
        # Head rounded rect (pointing up)
        draw_rounded_rect(draw, (8, 10, 24, 26), 4, (r, g, b))
        # Eyes
        draw.ellipse((10, 12, 14, 16), fill=(255, 255, 255))
        draw.ellipse((18, 12, 22, 16), fill=(255, 255, 255))
        draw.ellipse((11, 13, 13, 15), fill=(0, 0, 0))
        draw.ellipse((19, 13, 21, 15), fill=(0, 0, 0))
    elif direction == "down":
        draw.polygon([(16, 28), (14, 22), (18, 22)], fill=(220, 50, 50))
        draw_rounded_rect(draw, (8, 6, 24, 22), 4, (r, g, b))
        draw.ellipse((10, 16, 14, 20), fill=(255, 255, 255))
        draw.ellipse((18, 16, 22, 20), fill=(255, 255, 255))
        draw.ellipse((11, 17, 13, 19), fill=(0, 0, 0))
        draw.ellipse((19, 17, 21, 19), fill=(0, 0, 0))
    elif direction == "left":
        draw.polygon([(4, 16), (10, 14), (10, 18)], fill=(220, 50, 50))
        draw_rounded_rect(draw, (6, 8, 22, 24), 4, (r, g, b))
        draw.ellipse((8, 10, 12, 14), fill=(255, 255, 255))
        draw.ellipse((8, 18, 12, 22), fill=(255, 255, 255))
        draw.ellipse((9, 11, 11, 13), fill=(0, 0, 0))
        draw.ellipse((9, 19, 11, 21), fill=(0, 0, 0))
    elif direction == "right":
        draw.polygon([(28, 16), (22, 14), (22, 18)], fill=(220, 50, 50))
        draw_rounded_rect(draw, (10, 8, 26, 24), 4, (r, g, b))
        draw.ellipse((20, 10, 24, 14), fill=(255, 255, 255))
        draw.ellipse((20, 18, 24, 22), fill=(255, 255, 255))
        draw.ellipse((21, 11, 23, 13), fill=(0, 0, 0))
        draw.ellipse((21, 19, 23, 21), fill=(0, 0, 0))

    return img


def create_body_straight(vertical, body_color):
    """Create straight body segment. vertical=True for up/down, False for left/right."""
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    r, g, b = hex_to_rgb(body_color)
    if vertical:
        draw_rounded_rect(draw, (8, 0, 24, SIZE), 4, (r, g, b))
    else:
        draw_rounded_rect(draw, (0, 8, SIZE, 24), 4, (r, g, b))
    return img


def create_body_corner(corner, body_color):
    """Create corner body segment. corner: 'up_right', 'up_left', 'down_right', 'down_left'."""
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    r, g, b = hex_to_rgb(body_color)

    if corner == "up_right":
        draw.rectangle([8, 0, 24, 20], fill=(r, g, b))
        draw.rectangle([8, 8, SIZE, 24], fill=(r, g, b))
        draw.ellipse([6, 6, 26, 26], fill=(r, g, b))
    elif corner == "up_left":
        draw.rectangle([8, 0, 24, 20], fill=(r, g, b))
        draw.rectangle([0, 8, 24, 24], fill=(r, g, b))
        draw.ellipse([6, 6, 26, 26], fill=(r, g, b))
    elif corner == "down_right":
        draw.rectangle([8, 12, 24, SIZE], fill=(r, g, b))
        draw.rectangle([8, 8, SIZE, 24], fill=(r, g, b))
        draw.ellipse([6, 6, 26, 26], fill=(r, g, b))
    elif corner == "down_left":
        draw.rectangle([8, 12, 24, SIZE], fill=(r, g, b))
        draw.rectangle([0, 8, 24, 24], fill=(r, g, b))
        draw.ellipse([6, 6, 26, 26], fill=(r, g, b))

    # redraw transparent center to avoid dark overlap
    draw2 = ImageDraw.Draw(img)
    draw2.ellipse([10, 10, 22, 22], fill=(r, g, b))
    return img


def create_tail(direction, tail_color):
    """Create a tail sprite facing a direction."""
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    r, g, b = hex_to_rgb(tail_color)

    if direction == "up":
        draw.polygon([(16, 0), (10, 18), (22, 18)], fill=(r, g, b))
    elif direction == "down":
        draw.polygon([(16, 32), (10, 14), (22, 14)], fill=(r, g, b))
    elif direction == "left":
        draw.polygon([(0, 16), (18, 10), (18, 22)], fill=(r, g, b))
    elif direction == "right":
        draw.polygon([(32, 16), (14, 10), (14, 22)], fill=(r, g, b))

    return img


def generate_skin(skin_name, head_color, body_color, tail_color, glow_color):
    """Generate all 16 sprites for a skin."""
    out_dir = os.path.join(SKIN_DIR, skin_name)
    os.makedirs(out_dir, exist_ok=True)

    # Heads
    for d in ["up", "down", "left", "right"]:
        img = create_head(d, head_color, body_color)
        img.save(os.path.join(out_dir, f"snake_head_{d}.png"))

    # Straight body
    img = create_body_straight(True, body_color)
    img.save(os.path.join(out_dir, "snake_body_vertical.png"))
    img = create_body_straight(False, body_color)
    img.save(os.path.join(out_dir, "snake_body_horizontal.png"))

    # Corner body
    for corner in ["up_right", "up_left", "down_right", "down_left"]:
        img = create_body_corner(corner, body_color)
        img.save(os.path.join(out_dir, f"snake_body_{corner}.png"))

    # Tails
    for d in ["up", "down", "left", "right"]:
        img = create_tail(d, tail_color)
        img.save(os.path.join(out_dir, f"snake_tail_{d}.png"))

    print(f"  ✓ {skin_name}: 16 sprites saved to {out_dir}")


def generate_preview():
    """Create skin_preview.png showing all 5 skins side by side."""
    img = Image.new("RGBA", (256, 256), (20, 20, 30, 255))
    draw = ImageDraw.Draw(img)

    names = list(SKINS.keys())
    labels = ["Neon Green", "Hot Pink", "Fire", "Ice", "Galaxy"]
    x_positions = [8, 58, 108, 158, 208]  # 5 cols, 48px wide each

    for i, (name, label) in enumerate(zip(names, labels)):
        head_c, body_c, tail_c, glow_c = SKINS[name]
        hr, hg, hb = hex_to_rgb(head_c)
        br, bg, bb = hex_to_rgb(body_c)
        tr, tg, tb = hex_to_rgb(tail_c)

        x = x_positions[i]
        # Draw a mini snake preview: head → body → tail
        # Head
        draw.ellipse([x + 12, 20, x + 36, 44], fill=(hr, hg, hb))
        draw.ellipse([x + 14, 24, x + 20, 30], fill=(255, 255, 255))
        draw.ellipse([x + 28, 24, x + 34, 30], fill=(255, 255, 255))
        draw.ellipse([x + 15, 25, x + 19, 29], fill=(0, 0, 0))
        draw.ellipse([x + 29, 25, x + 33, 29], fill=(0, 0, 0))
        # Body
        draw_rounded_rect(draw, (x + 12, 44, x + 36, 100), 4, (br, bg, bb))
        # Tail
        draw.polygon([(x + 24, 100), (x + 16, 140), (x + 32, 140)], fill=(tr, tg, tb))
        # Glow effect
        gr, gg, gb = hex_to_rgb(glow_c)
        for glow_r in range(8, 0, -1):
            alpha = int(20 * (1 - glow_r / 8))
            glow_fill = (gr, gg, gb, alpha)
            draw.ellipse([x + 8 - glow_r, 16 - glow_r,
                          x + 40 + glow_r, 48 + glow_r], fill=glow_fill)

        # Label
        draw.text((x + 2, 148), label, fill=(220, 220, 240))

    out_path = os.path.join(SKIN_DIR, "skin_preview.png")
    img.save(out_path)
    print(f"  ✓ skin_preview.png saved to {out_path}")


def main():
    print("Generating snake sprites...")
    for name, (head, body, tail, glow) in SKINS.items():
        generate_skin(name, head, body, tail, glow)

    print("\nGenerating skin preview...")
    generate_preview()
    print("\nAll done!")


if __name__ == "__main__":
    main()
