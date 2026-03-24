#!/usr/bin/env python3
"""Generate Neon-style game art assets for Snake Game Phase 3."""

from PIL import Image, ImageDraw, ImageFilter
import os

# Colors (RGB)
NEON_GREEN = (74, 222, 128)
NEON_BLUE = (96, 165, 250)
NEON_PINK = (244, 114, 182)
BG_COLOR = (26, 26, 46)
GRID_COLOR = (22, 33, 62)
FOOD_RED = (248, 113, 113)
FOOD_GOLD = (251, 191, 36)
FOOD_BLUE = (96, 165, 250)
WHITE = (255, 255, 255)

# Paths
BASE = "/Users/liyi/Projects/snake-game/assets/sprites"

def make_dirs():
    for d in ["snake", "food", "hud", "particles", "map"]:
        os.makedirs(os.path.join(BASE, d), exist_ok=True)

def neon_glow(color, size=32, radius_factor=3):
    """Create a neon circle with glow effect."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center = size // 2
    r = size // radius_factor
    # Outer glow
    for blur in range(3, 0, -1):
        alpha = 40 * blur
        draw.ellipse([center-r-blur*2, center-r-blur*2, center+r+blur*2, center+r+blur*2],
                     fill=(*color, alpha))
    # Core
    draw.ellipse([center-r, center-r, center+r, center+r], fill=(*color, 255))
    # Bright center
    inner_r = r // 2
    draw.ellipse([center-inner_r, center-inner_r, center+inner_r, center+inner_r],
                 fill=(255, 255, 255, 200))
    return img

def neon_rect(color, size=32, width=None):
    """Create a neon rectangle."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    w = width or size // 4
    pad = (size - w) // 2
    # Glow
    for b in range(3, 0, -1):
        alpha = 30 * b
        draw.rectangle([pad-b*2, pad-b*2, pad+w+b*2, pad+w+b*2],
                       fill=(*color, alpha))
    # Core
    draw.rectangle([pad, pad, pad+w, pad+w], fill=(*color, 255))
    return img

def save(img, subdir, name):
    path = os.path.join(BASE, subdir, name)
    img.save(path)
    print(f"  Created: {path}")
    return path

# ============================================================
# 1. SNAKE SPRITES
# ============================================================

def create_snake_head(direction):
    """Snake head with eyes facing direction."""
    size = 32
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Head shape (rounded square)
    cx, cy = size // 2, size // 2
    r = size // 3
    pad = 4
    
    # Glow layers
    for b in range(4, 0, -1):
        alpha = 30 * b
        draw.ellipse([cx-r-pad-b*2, cy-r-pad-b*2, cx+r+pad+b*2, cy+r+pad+b*2],
                     fill=(*NEON_GREEN, alpha))
    # Core head
    draw.ellipse([cx-r-pad, cy-r-pad, cx+r+pad, cy+r+pad], fill=(*NEON_GREEN, 255))
    
    # Eyes
    eye_r = 3
    eye_bright = (255, 255, 255, 255)
    if direction == 'up':
        eye1 = (cx - 5, cy - 6)
        eye2 = (cx + 5, cy - 6)
    elif direction == 'down':
        eye1 = (cx - 5, cy + 3)
        eye2 = (cx + 5, cy + 3)
    elif direction == 'left':
        eye1 = (cx - 6, cy - 5)
        eye2 = (cx - 6, cy + 5)
    else:  # right
        eye1 = (cx + 3, cy - 5)
        eye2 = (cx + 3, cy + 5)
    
    for ex, ey in [eye1, eye2]:
        # Eye glow
        draw.ellipse([ex-eye_r-1, ey-eye_r-1, ex+eye_r+1, ey+eye_r+1],
                     fill=(255, 255, 255, 60))
        # Eye core
        draw.ellipse([ex-eye_r, ey-eye_r, ex+eye_r, ey+eye_r],
                     fill=eye_bright)
    
    return img

def create_snake_body_straight(vertical=True):
    size = 32
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    r = size // 3
    pad = 4
    
    # Glow
    for b in range(4, 0, -1):
        alpha = 25 * b
        draw.ellipse([-pad-b*2, size//2-r-b*2, size+pad+b*2, size//2+r+b*2],
                     fill=(*NEON_GREEN, alpha))
    
    if vertical:
        draw.rectangle([size//2-r-pad, 0, size//2+r+pad, size], fill=(*NEON_GREEN, 255))
        # Inner highlight
        draw.rectangle([size//2-2, 2, size//2+2, size-2], fill=(150, 255, 180, 100))
    else:
        draw.rectangle([0, size//2-r-pad, size, size//2+r+pad], fill=(*NEON_GREEN, 255))
        draw.rectangle([2, size//2-2, size-2, size//2+2], fill=(150, 255, 180, 100))
    
    return img

def create_snake_body_corner(corner):
    """corner: 'up_right', 'up_left', 'down_right', 'down_left'"""
    size = 32
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw as thick L-shape using ellipses
    pad = 4
    r = size // 3
    
    # Glow
    for b in range(3, 0, -1):
        alpha = 20 * b
        if corner == 'up_right':
            draw.ellipse([size//2-r-pad-b*2, -b*2, size//2+r+pad+b*2, size//2+r+pad+b*2],
                         fill=(*NEON_GREEN, alpha))
            draw.ellipse([-b*2, size//2-r-pad-b*2, size//2+r+pad+b*2, size//2+r+pad+b*2],
                         fill=(*NEON_GREEN, alpha))
        elif corner == 'up_left':
            draw.ellipse([size//2-r-pad-b*2, -b*2, size//2+r+pad+b*2, size//2+r+pad+b*2],
                         fill=(*NEON_GREEN, alpha))
            draw.ellipse([-b*2, size//2-r-pad-b*2, size//2+r+pad+b*2, size//2+r+pad+b*2],
                         fill=(*NEON_GREEN, alpha))
        elif corner == 'down_right':
            draw.ellipse([size//2-r-pad-b*2, size//2-r-pad-b*2, size//2+r+pad+b*2, size+b*2],
                         fill=(*NEON_GREEN, alpha))
            draw.ellipse([size//2-r-pad-b*2, -b*2, size+b*2, size//2+r+pad+b*2],
                         fill=(*NEON_GREEN, alpha))
        elif corner == 'down_left':
            draw.ellipse([-b*2, size//2-r-pad-b*2, size//2+r+pad+b*2, size+b*2],
                         fill=(*NEON_GREEN, alpha))
            draw.ellipse([size//2-r-pad-b*2, -b*2, size+b*2, size//2+r+pad+b*2],
                         fill=(*NEON_GREEN, alpha))
    
    if corner == 'up_right':
        draw.rectangle([size//2, 0, size, size//2+r+pad], fill=(*NEON_GREEN, 255))
        draw.rectangle([0, size//2, size//2+r+pad, size], fill=(*NEON_GREEN, 255))
        draw.ellipse([size//2-r//2, size//2-r//2, size//2+r//2, size//2+r//2], fill=(*NEON_GREEN, 255))
    elif corner == 'up_left':
        draw.rectangle([0, 0, size//2+r+pad, size//2+r+pad], fill=(*NEON_GREEN, 255))
        draw.rectangle([0, size//2, size//2+r+pad, size], fill=(*NEON_GREEN, 255))
        draw.ellipse([size//2-r//2, size//2-r//2, size//2+r//2, size//2+r//2], fill=(*NEON_GREEN, 255))
    elif corner == 'down_right':
        draw.rectangle([size//2, size//2-r-pad, size, size//2+r+pad], fill=(*NEON_GREEN, 255))
        draw.rectangle([size//2-r-pad, size//2, size, size], fill=(*NEON_GREEN, 255))
        draw.ellipse([size//2-r//2, size//2-r//2, size//2+r//2, size//2+r//2], fill=(*NEON_GREEN, 255))
    elif corner == 'down_left':
        draw.rectangle([0, size//2-r-pad, size//2+r+pad, size//2+r+pad], fill=(*NEON_GREEN, 255))
        draw.rectangle([0, size//2, size//2+r+pad, size], fill=(*NEON_GREEN, 255))
        draw.ellipse([size//2-r//2, size//2-r//2, size//2+r//2, size//2+r//2], fill=(*NEON_GREEN, 255))
    
    return img

def create_snake_tail(direction):
    size = 32
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    r = size // 4
    pad = 6
    
    # Glow
    for b in range(3, 0, -1):
        alpha = 25 * b
        if direction == 'up':
            draw.ellipse([size//2-r-pad-b*2, pad-b*2, size//2+r+pad+b*2, pad+r*2+b*2],
                         fill=(*NEON_GREEN, alpha))
        elif direction == 'down':
            draw.ellipse([size//2-r-pad-b*2, size//2-b*2, size//2+r+pad+b*2, size-pad+b*2+r*2],
                         fill=(*NEON_GREEN, alpha))
        elif direction == 'left':
            draw.ellipse([pad-b*2, size//2-r-pad-b*2, pad+r*2+b*2, size//2+r+pad+b*2],
                         fill=(*NEON_GREEN, alpha))
        elif direction == 'right':
            draw.ellipse([size//2-b*2, size//2-r-pad-b*2, size-pad+b*2+r*2, size//2+r+pad+b*2],
                         fill=(*NEON_GREEN, alpha))
    
    if direction == 'up':
        draw.ellipse([size//2-r-pad, pad, size//2+r+pad, pad+r*2], fill=(*NEON_GREEN, 255))
    elif direction == 'down':
        draw.ellipse([size//2-r-pad, size//2, size//2+r+pad, size-pad], fill=(*NEON_GREEN, 255))
    elif direction == 'left':
        draw.ellipse([pad, size//2-r-pad, pad+r*2, size//2+r+pad], fill=(*NEON_GREEN, 255))
    elif direction == 'right':
        draw.ellipse([size//2, size//2-r-pad, size-pad, size//2+r+pad], fill=(*NEON_GREEN, 255))
    
    return img

# ============================================================
# 2. FOOD SPRITES
# ============================================================

def create_food_normal():
    return neon_glow(FOOD_RED, 32, 3)

def create_food_gold():
    size = 32
    img = neon_glow(FOOD_GOLD, 32, 3)
    draw = ImageDraw.Draw(img)
    # Add sparkle lines
    cx, cy = size // 2, size // 2
    r = size // 3
    for angle in range(0, 360, 45):
        import math
        rad = math.radians(angle)
        x1 = cx + int(r * 0.5 * math.cos(rad))
        y1 = cy + int(r * 0.5 * math.sin(rad))
        x2 = cx + int((r + 4) * math.cos(rad))
        y2 = cy + int((r + 4) * math.sin(rad))
        draw.line([x1, y1, x2, y2], fill=(255, 255, 200, 200), width=1)
    return img

def create_food_blue():
    size = 32
    img = neon_glow(FOOD_BLUE, 32, 3)
    draw = ImageDraw.Draw(img)
    # Add electric zigzag
    cx, cy = size // 2, size // 2
    import math
    for i in range(-3, 4):
        angle1 = math.radians(i * 15 - 10)
        angle2 = math.radians(i * 15 + 10)
        x1 = cx + int(8 * math.sin(angle1))
        y1 = cy + int(8 * math.cos(angle1))
        x2 = cx + int(14 * math.sin(angle2))
        y2 = cy + int(14 * math.cos(angle2))
        draw.line([x1, y1, x2, y2], fill=(180, 220, 255, 200), width=1)
    return img

def create_food_timed_on():
    size = 32
    img = neon_glow((255, 100, 255), 32, 3)
    draw = ImageDraw.Draw(img)
    # Draw clock-like marks
    cx, cy = size // 2, size // 2
    import math
    for a in [90, 180, 270]:
        rad = math.radians(a)
        x = cx + int(6 * math.cos(rad))
        y = cy + int(6 * math.sin(rad))
        draw.ellipse([x-1, y-1, x+1, y+1], fill=(255, 200, 255, 255))
    draw.ellipse([cx-2, cy-2, cx+2, cy+2], fill=(255, 255, 255, 255))
    return img

def create_food_timed_off():
    size = 32
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    r = size // 3
    # Dim outline only
    draw.ellipse([cx-r-2, cy-r-2, cx+r+2, cy+r+2], fill=(200, 50, 200, 40))
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(200, 50, 200, 80))
    return img

# ============================================================
# 3. HUD ELEMENTS
# ============================================================

def create_hud_icon(icon_type, size=16):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    if icon_type == 'score':
        # Star shape
        cx, cy = size // 2, size // 2
        r = size // 2 - 1
        points = []
        import math
        for i in range(5):
            angle = math.radians(i * 72 - 90)
            points.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
            angle2 = math.radians(i * 72 + 36 - 90)
            r2 = r * 0.4
            points.append((cx + r2 * math.cos(angle2), cy + r2 * math.sin(angle2)))
        draw.polygon(points, fill=(*NEON_GOLD, 255))
        for b in range(2, 0, -1):
            draw.polygon(points, fill=(*NEON_GOLD, 30*b))
    
    elif icon_type == 'level':
        # Up arrow
        cx, cy = size // 2, size // 2
        r = size // 2 - 1
        draw.polygon([(cx, 1), (cx + r, cy + r), (cx, cy + r//2), (cx, cy + r),
                      (cx - r, cy + r), (cx - r, cy + r//2)],
                     fill=(*NEON_BLUE, 255))
        for b in range(2, 0, -1):
            alpha = 30 * b
            draw.polygon([(cx, 1-b), (cx + r+b, cy + r+b), (cx, cy + r//2),
                          (cx - r-b, cy + r+b)],
                         fill=(*NEON_BLUE, alpha))
    
    elif icon_type == 'mode':
        # Grid icon
        g = size // 4
        for i in range(3):
            for j in range(3):
                draw.rectangle([i*g+1, j*g+1, i*g+g-1, j*g+g-1],
                               fill=(*NEON_PINK, 200))
        for b in range(2, 0, -1):
            alpha = 20 * b
            for i in range(3):
                for j in range(3):
                    draw.rectangle([i*g+1-b, j*g+1-b, i*g+g-1+b, j*g+g-1+b],
                                   fill=(*NEON_PINK, alpha))
    
    elif icon_type == 'length':
        # Snake length bars
        bar_w = 2
        for i in range(3):
            x = size // 2 - 3 + i * 3
            h = 4 + i * 3
            draw.rectangle([x, size - h, x + bar_w, size],
                           fill=(*NEON_GREEN, 255))
            draw.rectangle([x-1, size - h - 1, x + bar_w + 1, size],
                           fill=(*NEON_GREEN, 30))
    
    return img

def create_pause_btn():
    size = 48
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Rounded square background with glow
    pad = 4
    r = 8
    # Glow
    for b in range(3, 0, -1):
        alpha = 25 * b
        draw.rounded_rectangle([pad-b*2, pad-b*2, size-pad+b*2-1, size-pad+b*2-1],
                                r, fill=(*NEON_BLUE, alpha))
    # Core
    draw.rounded_rectangle([pad, pad, size-pad-1, size-pad-1], r,
                            fill=(*NEON_BLUE, 255))
    
    # Two pause bars
    bw = 5
    bh = 16
    bx1 = size // 2 - bw - 3
    bx2 = size // 2 + 3
    by = (size - bh) // 2
    draw.rectangle([bx1, by, bx1+bw, by+bh], fill=(255, 255, 255, 255))
    draw.rectangle([bx2, by, bx2+bw, by+bh], fill=(255, 255, 255, 255))
    
    return img

def create_play_btn():
    size = 48
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    pad = 4
    r = 8
    # Glow
    for b in range(3, 0, -1):
        alpha = 25 * b
        draw.rounded_rectangle([pad-b*2, pad-b*2, size-pad+b*2-1, size-pad+b*2-1],
                                r, fill=(*NEON_GREEN, alpha))
    # Core
    draw.rounded_rectangle([pad, pad, size-pad-1, size-pad-1], r,
                            fill=(*NEON_GREEN, 255))
    
    # Play triangle
    pts = [(size//2 - 6, size//2 - 10), (size//2 - 6, size//2 + 10), (size//2 + 12, size//2)]
    draw.polygon(pts, fill=(255, 255, 255, 255))
    
    return img

NEON_GOLD = FOOD_GOLD

# ============================================================
# 4. PARTICLES
# ============================================================

def create_eat_particle():
    size = 16
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    r = 3
    # Glow
    for b in range(3, 0, -1):
        draw.ellipse([cx-r-b*2, cy-r-b*2, cx+r+b*2, cy+r+b*2],
                     fill=(*NEON_GREEN, 40*b))
    # Core
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(*NEON_GREEN, 255))
    draw.ellipse([cx-1, cy-1, cx+1, cy+1], fill=(255, 255, 255, 255))
    return img

def create_death_explosion():
    size = 32
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    
    import math
    for angle in range(0, 360, 30):
        rad = math.radians(angle)
        x1 = cx + int(4 * math.cos(rad))
        y1 = cy + int(4 * math.sin(rad))
        x2 = cx + int(14 * math.cos(rad))
        y2 = cy + int(14 * math.sin(rad))
        # Glow
        draw.line([x1, y1, x2, y2], fill=(*NEON_GREEN, 100), width=3)
        draw.line([x1, y1, x2, y2], fill=(*NEON_PINK, 200), width=1)
    
    # Center
    draw.ellipse([cx-3, cy-3, cx+3, cy+3], fill=(255, 255, 255, 200))
    
    return img

# ============================================================
# 5. MAP DECORATION
# ============================================================

def create_grid_border():
    size = 64  # 2 cells wide border tile
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Neon border line
    line_color = NEON_BLUE
    pad = 2
    for b in range(3, 0, -1):
        draw.rectangle([pad-b*2, pad-b*2, size-pad+b*2-1, size-pad+b*2-1],
                       outline=(*line_color, 30*b), width=1)
    draw.rectangle([pad, pad, size-pad-1, size-pad-1],
                   outline=(*line_color, 255), width=2)
    return img

def create_background_tile():
    size = 64
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Subtle grid pattern
    grid_color = (22, 33, 62, 60)  # GRID_COLOR with alpha
    cell = 16
    for x in range(0, size, cell):
        draw.line([x, 0, x, size], fill=grid_color, width=1)
    for y in range(0, size, cell):
        draw.line([0, y, size, y], fill=grid_color, width=1)
    
    # Corner accent dots
    dot_color = (30, 50, 90, 80)
    for x in range(0, size, cell):
        for y in range(0, size, cell):
            draw.ellipse([x, y, x+1, y+1], fill=dot_color)
    
    return img

def create_corner_decoration():
    size = 64
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Neon corner bracket
    pad = 4
    thick = 3
    color = NEON_PINK
    
    # Glow
    for b in range(3, 0, -1):
        alpha = 25 * b
        # Top-left corner bracket
        draw.line([pad-b*2, pad, pad+b*2, pad], fill=(*color, alpha), width=thick+b*2)
        draw.line([pad, pad-b*2, pad, pad+b*2], fill=(*color, alpha), width=thick+b*2)
    
    # Core bracket
    draw.line([pad, pad, pad+20, pad], fill=(*color, 255), width=thick)
    draw.line([pad, pad, pad, pad+20], fill=(*color, 255), width=thick)
    
    # Small inner glow circle
    draw.ellipse([pad+2, pad+2, pad+6, pad+6], fill=(*NEON_PINK, 150))
    draw.ellipse([pad+3, pad+3, pad+5, pad+5], fill=(255, 200, 220, 200))
    
    return img

# ============================================================
# MAIN GENERATION
# ============================================================

if __name__ == "__main__":
    make_dirs()
    
    print("\n=== Creating Snake Sprites ===")
    for direction in ['up', 'down', 'left', 'right']:
        img = create_snake_head(direction)
        save(img, 'snake', f'snake_head_{direction}.png')
    
    for vertical in [True, False]:
        name = 'vertical' if vertical else 'horizontal'
        img = create_snake_body_straight(vertical)
        save(img, 'snake', f'snake_body_{name}.png')
    
    for corner in ['up_right', 'up_left', 'down_right', 'down_left']:
        img = create_snake_body_corner(corner)
        save(img, 'snake', f'snake_body_{corner}.png')
    
    for direction in ['up', 'down', 'left', 'right']:
        img = create_snake_tail(direction)
        save(img, 'snake', f'snake_tail_{direction}.png')
    
    print("\n=== Creating Food Sprites ===")
    save(create_food_normal(), 'food', 'food_normal.png')
    save(create_food_gold(), 'food', 'food_gold.png')
    save(create_food_blue(), 'food', 'food_blue.png')
    save(create_food_timed_on(), 'food', 'food_timed.png')
    save(create_food_timed_off(), 'food', 'food_timed_off.png')
    
    print("\n=== Creating HUD Elements ===")
    for icon in ['score', 'level', 'mode', 'length']:
        save(create_hud_icon(icon, 16), 'hud', f'hud_{icon}_icon.png')
    save(create_pause_btn(), 'hud', 'pause_btn.png')
    save(create_play_btn(), 'hud', 'play_btn.png')
    
    print("\n=== Creating Particles ===")
    save(create_eat_particle(), 'particles', 'eat_particle.png')
    save(create_death_explosion(), 'particles', 'death_explosion.png')
    
    print("\n=== Creating Map Decorations ===")
    save(create_grid_border(), 'map', 'grid_border.png')
    save(create_background_tile(), 'map', 'background_tile.png')
    save(create_corner_decoration(), 'map', 'corner_decoration.png')
    
    print("\n=== File Summary ===")
    import subprocess
    result = subprocess.run(['find', BASE, '-name', '*.png', '-type', 'f'],
                            capture_output=True, text=True)
    files = sorted(result.stdout.strip().split('\n'))
    total = 0
    for f in files:
        size = os.path.getsize(f)
        total += size
        print(f"  {size:>6} bytes  {f}")
    print(f"\n  Total: {len(files)} files, {total:,} bytes")
