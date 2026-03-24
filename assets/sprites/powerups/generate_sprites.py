#!/usr/bin/env python3
"""Generate neon-styled power-up sprites for Snake Game."""

from PIL import Image, ImageDraw, ImageFilter
import math

def create_neon_icon(size=32, glow_size=4):
    """Create a transparent RGBA image."""
    return Image.new('RGBA', (size, size), (0, 0, 0, 0))

def draw_glow(draw, x, y, radius, color, glow_size=4):
    """Draw a soft glow circle."""
    for i in range(glow_size, 0, -1):
        alpha = int(80 / i)
        r = radius + i
        draw.ellipse([x - r, y - r, x + r, y + r],
                     fill=(color[0], color[1], color[2], alpha))

def draw_neon_line(draw, points, color, width=2, glow_size=3):
    """Draw a neon-styled line with glow."""
    for i in range(glow_size, 0, -1):
        alpha = int(60 / i)
        w = width + i
        draw.line(points, fill=(color[0], color[1], color[2], alpha), width=w)

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple."""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

# ============================================================
# 1. SHIELD - Blue circular shield/bubble
# ============================================================
def create_shield():
    img = create_neon_icon()
    draw = ImageDraw.Draw(img)
    color = hex_to_rgb('#60a5fa')
    cx, cy = 16, 16

    # Outer glow
    draw_glow(draw, cx, cy, 12, color, glow_size=5)

    # Main shield bubble (circle)
    draw.ellipse([cx - 11, cy - 11, cx + 11, cy + 11],
                 fill=(color[0], color[1], color[2], 220))

    # Inner highlight
    draw.ellipse([cx - 7, cy - 7, cx + 5, cy + 5],
                 fill=(255, 255, 255, 80))

    # Shield emblem - small inner circle
    draw.ellipse([cx - 4, cy - 4, cx + 4, cy + 4],
                 fill=(255, 255, 255, 150))

    return img

# ============================================================
# 2. SLOW - Cyan snail/clock symbol
# ============================================================
def create_slow():
    img = create_neon_icon()
    draw = ImageDraw.Draw(img)
    color = hex_to_rgb('#22d3ee')
    cx, cy = 16, 16

    # Outer glow
    draw_glow(draw, cx, cy, 12, color, glow_size=5)

    # Clock face (circle)
    draw.ellipse([cx - 10, cy - 10, cx + 10, cy + 10],
                 fill=(color[0], color[1], color[2], 200),
                 outline=(255, 255, 255, 200), width=1)

    # Clock center dot
    draw.ellipse([cx - 1, cy - 1, cx + 1, cy + 1],
                 fill=(255, 255, 255, 255))

    # Hour hand
    draw.line([cx, cy, cx, cy - 6], fill=(255, 255, 255, 220), width=2)

    # Minute hand (longer - indicates slow)
    draw.line([cx, cy, cx + 5, cy + 2], fill=(255, 255, 255, 220), width=2)

    # "S" curve for snail hint at bottom
    points = [(cx - 5, cy + 8), (cx, cy + 6), (cx + 5, cy + 8)]
    draw.arc([cx - 6, cy + 5, cx + 6, cy + 12], start=0, end=180,
             fill=(255, 255, 255, 180), width=1)

    return img

# ============================================================
# 3. GHOST - White semi-transparent ghost shape
# ============================================================
def create_ghost():
    img = create_neon_icon()
    draw = ImageDraw.Draw(img)
    color = (255, 255, 255)  # white
    cx, cy = 16, 17

    # Outer soft glow
    draw_glow(draw, cx, cy, 11, (200, 200, 255), glow_size=6)

    # Ghost body - dome top, wavy bottom
    body_points = [
        (cx - 9, cy + 8),   # bottom left
        (cx - 9, cy - 6),   # top left
        (cx + 9, cy - 6),   # top right
        (cx + 9, cy + 8),   # bottom right
    ]
    # Draw dome
    draw.arc([cx - 9, cy - 9, cx + 9, cy + 7],
             start=180, end=0, fill=(255, 255, 255, 180), width=0)

    # Cover bottom of arc
    draw.rectangle([cx - 9, cy - 1, cx + 9, cy + 8],
                   fill=(255, 255, 255, 180))

    # Wavy bottom
    wave_y = cy + 8
    for i in range(-9, 10, 3):
        dx = 3 if i < 0 else -3
        draw.polygon([
            (i, wave_y),
            (i + 3, wave_y + 4),
            (i + dx, wave_y)
        ], fill=(255, 255, 255, 180))

    # Re-draw full ghost shape properly
    ghost_path = [
        (cx - 9, cy + 8), (cx - 9, cy - 6),
    ]
    # Simple ghost: dome + body + wavy bottom
    draw.pieslice([cx - 9, cy - 9, cx + 9, cy + 11],
                  start=180, end=0,
                  fill=(255, 255, 255, 160))

    # Wavy bottom overlay
    for wx in range(-9, 10, 6):
        draw.polygon([
            (cx + wx, cy + 8),
            (cx + wx + 3, cy + 12),
            (cx + wx + 6, cy + 8)
        ], fill=(255, 255, 255, 160))

    # Eyes
    draw.ellipse([cx - 5, cy - 1, cx - 2, cy + 2],
                 fill=(30, 30, 60, 220))
    draw.ellipse([cx + 2, cy - 1, cx + 5, cy + 2],
                 fill=(30, 30, 60, 220))

    return img

# ============================================================
# 4. MAGNET - Gold horseshoe magnet U-shape
# ============================================================
def create_magnet():
    img = create_neon_icon()
    draw = ImageDraw.Draw(img)
    color = hex_to_rgb('#fbbf24')
    cx, cy = 16, 16

    # Outer glow
    draw_glow(draw, cx, cy, 12, color, glow_size=5)

    # Horseshoe magnet (U-shape)
    # Left arm
    draw.rectangle([cx - 9, cy - 8, cx - 4, cy + 8],
                   fill=(color[0], color[1], color[2], 220))
    # Right arm
    draw.rectangle([cx + 4, cy - 8, cx + 9, cy + 8],
                   fill=(color[0], color[1], color[2], 220))
    # Bottom arc connecting them
    draw.arc([cx - 9, cy - 4, cx + 9, cy + 12],
             start=0, end=180,
             fill=(color[0], color[1], color[2], 220), width=5)

    # Pole indicators (red/blue tips)
    draw.rectangle([cx - 9, cy - 8, cx - 4, cy - 5],
                   fill=(239, 68, 68, 255))  # red tip
    draw.rectangle([cx + 4, cy - 8, cx + 9, cy - 5],
                   fill=(59, 130, 246, 255))  # blue tip

    # Sparkles
    sparkle_positions = [(cx - 12, cy - 4), (cx + 12, cy - 4), (cx, cy - 10)]
    for sx, sy in sparkle_positions:
        draw.ellipse([sx - 1, sy - 1, sx + 1, sy + 1],
                     fill=(255, 255, 200, 255))

    return img

# ============================================================
# 5. DOUBLE_POINTS - Pink "2X" star symbol
# ============================================================
def create_double():
    img = create_neon_icon()
    draw = ImageDraw.Draw(img)
    color = hex_to_rgb('#f472b6')
    cx, cy = 16, 16

    # Outer glow
    draw_glow(draw, cx, cy, 13, color, glow_size=5)

    # Draw "2" and "X" combined as star burst
    # "2" - diagonal stroke with curve
    draw.line([cx - 8, cy + 5, cx - 4, cy - 6], fill=(color[0], color[1], color[2], 230), width=3)
    draw.arc([cx - 8, cy - 6, cx - 1, cy + 1], start=90, end=180,
             fill=(color[0], color[1], color[2], 230), width=3)
    draw.line([cx - 4, cy - 3, cx + 2, cy + 6], fill=(color[0], color[1], color[2], 230), width=3)

    # "X" - two crossing lines
    draw.line([cx + 3, cy - 6, cx + 9, cy + 6], fill=(color[0], color[1], color[2], 230), width=3)
    draw.line([cx + 9, cy - 6, cx + 3, cy + 6], fill=(color[0], color[1], color[2], 230), width=3)

    # Sparkle effects around
    for angle in range(0, 360, 45):
        rad = math.radians(angle)
        sx = cx + int(13 * math.cos(rad))
        sy = cy + int(13 * math.sin(rad))
        draw.ellipse([sx - 1, sy - 1, sx + 1, sy + 1],
                     fill=(255, 200, 255, 200))

    return img

# ============================================================
# 6. SHRINK - Purple downward arrow/compress symbol
# ============================================================
def create_shrink():
    img = create_neon_icon()
    draw = ImageDraw.Draw(img)
    color = hex_to_rgb('#a855f7')
    cx, cy = 16, 16

    # Outer glow
    draw_glow(draw, cx, cy, 13, color, glow_size=5)

    # Draw compress/condense symbol - arrows pointing inward from top and bottom
    # Top arrow pointing down
    draw.polygon([
        (cx, cy - 4),
        (cx - 7, cy - 10),
        (cx + 7, cy - 10)
    ], fill=(color[0], color[1], color[2], 220))

    # Bottom arrow pointing up
    draw.polygon([
        (cx, cy + 4),
        (cx - 7, cy + 10),
        (cx + 7, cy + 10)
    ], fill=(color[0], color[1], color[2], 220))

    # Center bar
    draw.rectangle([cx - 4, cy - 3, cx + 4, cy + 3],
                   fill=(color[0], color[1], color[2], 200))

    # Compress lines on sides
    draw.line([cx - 9, cy - 5, cx - 9, cy + 5], fill=(color[0], color[1], color[2], 180), width=1)
    draw.line([cx + 9, cy - 5, cx + 9, cy + 5], fill=(color[0], color[1], color[2], 180), width=1)

    return img

# ============================================================
# Generate and save all sprites
# ============================================================
output_dir = '/Users/liyi/Projects/snake-game/assets/sprites/powerups'

sprites = {
    'powerup_shield.png': create_shield(),
    'powerup_slow.png': create_slow(),
    'powerup_ghost.png': create_ghost(),
    'powerup_magnet.png': create_magnet(),
    'powerup_double.png': create_double(),
    'powerup_shrink.png': create_shrink(),
}

for filename, img in sprites.items():
    filepath = f'{output_dir}/{filename}'
    img.save(filepath, 'PNG')
    print(f'Saved: {filepath}')

print('\nAll power-up sprites generated successfully!')
