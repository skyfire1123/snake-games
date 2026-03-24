# Snake Skins Design Document

## Overview
This document defines the visual design for 5 snake skins in the game. Each skin has a distinct color palette and theme.

---

## Skin 1: Neon Green (Default)

| Property | Value |
|----------|-------|
| **Name** | Neon Green |
| **Head Color** | `#4ade80` |
| **Body Color** | `#22c55e` |
| **Tail Color** | `#16a34a` |
| **Glow Color** | `#4ade80` (soft neon glow) |
| **Theme** | Classic arcade neon — bright, energetic, easy to track |
| **Mood** | Retro-futuristic arcade |

---

## Skin 2: Hot Pink

| Property | Value |
|----------|-------|
| **Name** | Hot Pink |
| **Head Color** | `#f472b6` |
| **Body Color** | `#ec4899` |
| **Tail Color** | `#db2777` |
| **Glow Color** | `#f472b6` (vibrant pink glow) |
| **Theme** | Vibrant neon pink — bold, playful, high visibility |
| **Mood** | Energetic and stylish |

---

## Skin 3: Fire

| Property | Value |
|----------|-------|
| **Name** | Fire |
| **Head Color** | `#f97316` |
| **Body Color** | `#ea580c` |
| **Tail Color** | `#c2410c` |
| **Glow Color** | `#f97316` (orange flame glow) |
| **Theme** | Orange-red flame — intense, fierce, powerful |
| **Mood** | Aggressive and passionate |

---

## Skin 4: Ice

| Property | Value |
|----------|-------|
| **Name** | Ice |
| **Head Color** | `#38bdf8` |
| **Body Color** | `#0ea5e9` |
| **Tail Color** | `#0284c7` |
| **Glow Color** | `#38bdf8` (cool blue glow) |
| **Theme** | Cool blue ice — sleek, calm, crystalline |
| **Mood** | Cool and precise |

---

## Skin 5: Galaxy

| Property | Value |
|----------|-------|
| **Name** | Galaxy |
| **Head Color** | `#a855f7` |
| **Body Color** | `#9333ea` |
| **Tail Color** | `#7e22ce` |
| **Glow Color** | `#a855f7` (purple cosmic glow) |
| **Theme** | Purple cosmic — mysterious, deep space, otherworldly |
| **Mood** | Mysterious and elegant |

---

## Sprite Specifications

All sprites are **32×32 PNG** files with transparency support.

### Sprite Types (16 per skin)

**Heads (4):**
- `snake_head_up.png`
- `snake_head_down.png`
- `snake_head_left.png`
- `snake_head_right.png`

**Body segments (6):**
- `snake_body_vertical.png` — vertical straight body
- `snake_body_horizontal.png` — horizontal straight body
- `snake_body_up_right.png` — corner turning up→right
- `snake_body_up_left.png` — corner turning up→left
- `snake_body_down_right.png` — corner turning down→right
- `snake_body_down_left.png` — corner turning down→left

**Tails (4):**
- `snake_tail_up.png`
- `snake_tail_down.png`
- `snake_tail_left.png`
- `snake_tail_right.png`

---

## Skin Selection UI

A `skin_preview.png` (256×256) shows all 5 skins side by side for the skin selection screen.

---

*Document version: 1.0 — Sprint 3*
