# Power-up Sprites

## Overview
6 power-up icon sprites with neon glow aesthetic, generated via Python PIL.
Each sprite is 32x32 pixels with transparent background (RGBA).

## Power-up Types

| Power-Up | File | Color | Visual |
|----------|------|-------|--------|
| SHIELD (护盾) | `powerup_shield.png` | Blue #60a5fa | Circular shield/bubble with inner highlight |
| SLOW (减速) | `powerup_slow.png` | Cyan #22d3ee | Clock face with hour/minute hands |
| GHOST (穿墙) | `powerup_ghost.png` | White #ffffff | Cute ghost dome shape with wavy bottom, eyes |
| MAGNET (磁铁) | `powerup_magnet.png` | Gold #fbbf24 | U-shaped horseshoe magnet with red/blue pole tips |
| DOUBLE_POINTS (双倍) | `powerup_double.png` | Pink #f472b6 | "2X" symbol with sparkle burst effect |
| SHRINK (收缩) | `powerup_shrink.png` | Purple #a855f7 | Dual arrows pointing inward (compress symbol) |

## Style Guide
- **Neon Glow Effect**: All icons have soft outer glow with bright neon colors
- **Transparent Background**: RGBA format, dark pixels are actually transparent
- **Size**: 32x32 pixels per sprite
- **Format**: PNG with alpha channel

## Generation
Regenerate sprites using:
```bash
python3 generate_sprites.py
```

## PowerUpType Enum Order (Reference)
Matches `scripts/powerup_manager.gd`:
1. SHIELD
2. SLOW
3. GHOST
4. MAGNET
5. DOUBLE_POINTS
6. SHRINK
