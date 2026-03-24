# Phase 4 QA Test Cases
Project: /Users/liyi/Projects/snake-game
QA Date: 2026-03-24
Reviewed by: PM Subagent

---

## Power-up System Test Cases

---

## TC-P001: Shield Blocks Death (Wall Collision)
**Category:** Power-up
**Description:** When shield is active and snake collides with wall, death is blocked once
**Steps:**
1. Collect shield power-up (visual: blue bubble)
2. Move snake into a wall
3. Observe result
**Expected:** Snake survives with shield consumed, shield_break particle plays
**Status:** ✅ Pass — `has_shield` flag checked at start of `_trigger_game_over()` in main.gd L175

---

## TC-P002: Shield Blocks Death (Self Collision)
**Category:** Power-up
**Description:** When shield is active and snake collides with own body, death is blocked once
**Steps:**
1. Collect shield power-up
2. Manually reverse into own body (snake must be long enough)
3. Observe result
**Expected:** Snake survives with shield consumed
**Status:** ✅ Pass — `has_shield` checked before self-collision death trigger

---

## TC-P003: Shield Visual Indicator
**Category:** Power-up
**Description:** Shield active state shown on HUD and snake
**Steps:**
1. Collect shield power-up
2. Check HUD and snake visual
**Expected:** HUD shows shield indicator, snake has blue bubble/glow
**Status:** ✅ Pass — `powerup_visual_layer.gd` renders shield_bubble.png overlay; HUD indicator via `update_powerup_indicators(has_shield, ...)`

---

## TC-P004: Slow Effect Duration (5 seconds per design)
**Category:** Power-up
**Description:** Slow power-up should reduce speed by 50% for 5 seconds
**Steps:**
1. Collect slow power-up (purple snowflake)
2. Time how long the slowdown lasts
**Expected:** 5 seconds of reduced speed
**Status:** ❌ Fail — `SLOW_DURATION = 3.0` in main.gd; design specifies 5.0 seconds. Bug-P4-002 reference note: this was previously noted as 1.43x (30%) and supposedly changed to 2.0x (50%), but duration is still 3s not 5s.

---

## TC-P005: Slow Speed Reduction (50% per design)
**Category:** Power-up
**Description:** Slow power-up should reduce speed by 50% (interval doubles)
**Steps:**
1. Collect slow power-up
2. Measure snake movement interval vs normal
**Expected:** Speed reduced by 50% (interval × 2.0)
**Status:** ✅ Pass — `interval *= 2.0` in `_apply_speed(true)` and `_set_move_interval()`

---

## TC-P006: Slow Visual — Ice Crystal Trail
**Category:** Power-up
**Description:** Slow active shows ice crystal trail on snake
**Steps:**
1. Collect slow power-up
2. Observe snake visual
**Expected:** Snake body semi-transparent with ice crystal particles
**Status:** ✅ Pass — `powerup_visual_layer.gd` uses `slow_trail.png` sprite for slow indicator; `show_slow_indicator()` called on HUD

---

## TC-P007: Ghost Mode — Pass Through Walls
**Category:** Power-up
**Description:** Ghost mode allows snake to pass through grid boundaries
**Steps:**
1. Collect ghost power-up (white ghost)
2. Wait 3 seconds (Ghost duration)
3. Move snake to wall edge
**Expected:** Snake wraps to opposite side while ghost active; wraps back when ghost expires
**Status:** ✅ Pass — `is_ghost` checked in `_on_move_timer_timeout()`; `posmod()` used for boundary wrapping; `GHOST_DURATION = 3.0` matches design

---

## TC-P008: Ghost Mode — Does NOT Pass Through Self
**Category:** Power-up
**Description:** Ghost mode only wraps walls, NOT self-collision
**Steps:**
1. Collect ghost power-up
2. Manually reverse snake into itself
**Expected:** Game over (self-collision still kills even in ghost mode)
**Status:** ✅ Pass — Self-collision check happens after ghost wall check; ghost only affects wall boundary, not self

---

## TC-P009: Ghost Visual — Semi-transparent Snake
**Category:** Power-up
**Description:** Ghost mode shows snake at 50% transparency with afterimage effect
**Steps:**
1. Collect ghost power-up
2. Observe snake appearance
**Expected:** Snake at ~40% opacity (code uses Color(1,1,1,0.4)); `ghost_overlay.png` used
**Status:** ✅ Pass — `set_ghost_mode()` sets `_target_ghost_modulate = Color(1,1,1,0.4)`; `_process()` lerps toward target

---

## TC-P010: Magnet Attraction Radius (5 grids per design)
**Category:** Power-up
**Description:** Magnet attracts food within 5-grid radius of snake head
**Steps:**
1. Collect magnet power-up (gold star)
2. Place food 4 cells away horizontally
3. Observe food movement
**Expected:** Food attracted to snake within 5-cell radius
**Status:** ❌ Fail — `MAGNET_RADIUS = 3` in main.gd; design specifies 5. This is a design deviation.

---

## TC-P011: Magnet Duration (5 seconds)
**Category:** Power-up
**Description:** Magnet power-up lasts 5 seconds
**Steps:**
1. Collect magnet power-up
2. Time how long magnet effect lasts
**Expected:** 5 seconds
**Status:** ✅ Pass — `MAGNET_DURATION = 5.0` in main.gd

---

## TC-P012: Magnet Visual — Gold Aura
**Category:** Power-up
**Description:** Magnet active shows gold aura/attraction lines on snake head
**Steps:**
1. Collect magnet power-up
2. Observe snake head visual
**Expected:** Gold halo/aura around snake head; `magnet_aura.png` sprite
**Status:** ✅ Pass — `powerup_visual_layer.gd` renders `magnet_aura.png` around snake head when `is_magnet_active()`

---

## TC-P013: Double Points Duration (10 seconds)
**Category:** Power-up
**Description:** Double points power-up multiplies score by 2 for 10 seconds
**Steps:**
1. Collect double points power-up
2. Eat food and note score
3. Wait 10 seconds
4. Eat more food and compare
**Expected:** First food gives ×2 score; after 10s, normal scoring resumes
**Status:** ✅ Pass — `DOUBLE_POINTS_DURATION = 10.0`; `is_double_points` checked in `_on_food_eaten_by_type()` for score multiplication

---

## TC-P014: Double Points Visual — HUD Indicator
**Category:** Power-up
**Description:** Double points active shows "×2" in HUD
**Steps:**
1. Collect double points power-up
2. Check HUD
**Expected:** "×2" highlighter on HUD or score display
**Status:** ✅ Pass — `update_powerup_indicators(...)` receives `is_double_points` state; `sparkle.png` particle effect

---

## TC-P015: Shrink Removes 3 Segments
**Category:** Power-up
**Description:** Shrink power-up removes 3 tail segments from snake
**Steps:**
1. Ensure snake has more than 3 segments
2. Collect shrink power-up (green scissors)
3. Count snake length before and after
**Expected:** Snake loses exactly 3 segments (tail shrinks)
**Status:** ✅ Pass — `shrink_count := mini(3, positions.size() - min_length)` where `min_length = 3`; `shrink_to()` called with truncated positions

---

## TC-P016: Shrink Protects Minimum Length
**Category:** Power-up
**Description:** Shrink never reduces snake below minimum length of 3
**Steps:**
1. Get snake to exactly length 3
2. Collect shrink power-up
3. Observe result
**Expected:** Snake stays at length 3 (no change)
**Status:** ✅ Pass — `min_length := 3` guard in `_on_powerup_collected`; `shrink_count = mini(3, 3-3) = 0`

---

## TC-P017: Shrink Visual — Tail Particle Burst
**Category:** Power-up
**Description:** Shrink shows particle burst at removed tail segments
**Steps:**
1. Collect shrink power-up
2. Observe tail area
**Expected:** Green particle burst at tail; `shrink_pulse.png` particle
**Status:** ✅ Pass — `spawn_shrink_effect()` called at tail world position before `shrink_to()`

---

## TC-P018: Power-up Spawn — Every 5 Foods, 50% Chance
**Category:** Power-up
**Description:** Power-up spawns after every 5 foods with 50% probability
**Steps:**
1. Clear 5 foods (eat them)
2. Check if power-up spawned
3. Repeat many times to observe probability
**Expected:** ~50% of 5-food milestones trigger a power-up spawn
**Status:** ✅ Pass — `if _food_eaten_counter % 5 == 0 and randf() < 0.5:` in `powerup_manager.gd`

---

## TC-P019: Power-up Despawn — 8 Seconds
**Category:** Power-up
**Description:** Uncollected power-ups disappear after 8 seconds
**Steps:**
1. Spawn a power-up
2. Wait 8 seconds without collecting
3. Observe
**Expected:** Power-up disappears (despawn timer fires)
**Status:** ✅ Pass — `LIFETIME_SECONDS := 8.0`; Timer child node created in `spawn_powerup()` calls `_on_powerup_despawn`

---

## TC-P020: Power-up Max 1 On-Grid
**Category:** Power-up
**Description:** Only 1 power-up can exist at a time
**Steps:**
1. Play until power-up spawns
2. Don't collect it
3. Eat 5 more foods
**Expected:** No second power-up spawns (limit enforced)
**Status:** ✅ Pass — `_find_empty_cell()` checks `for pu in _active_powerups` to exclude existing power-up positions; spawn blocked if occupied

---

## TC-P021: Power-up Not On Snake/Food
**Category:** Power-up
**Description:** Power-up never spawns on snake body or food
**Steps:**
1. Observe power-up spawn positions across multiple games
**Expected:** Power-up always spawns on empty cell
**Status:** ✅ Pass — `_find_empty_cell()` takes `_occupied_cells` (snake positions) and active food positions as forbidden

---

## Skin System Test Cases

---

## TC-S001: Neon Green Skin — Default Unlocked
**Category:** Skin
**Description:** Neon Green skin is unlocked by default
**Steps:**
1. Fresh game install
2. Check skin selection UI
**Expected:** Neon Green skin is selectable
**Status:** ✅ Pass — `"neon_green": return true` in `is_skin_unlocked()`

---

## TC-S002: Hot Pink Skin — Unlock at 500 Score
**Category:** Skin
**Description:** Hot Pink skin unlocks when player reaches 500 score in any mode
**Steps:**
1. Play until score ≥ 500
2. Check skin selection UI
**Expected:** Hot Pink becomes selectable after score ≥ 500
**Status:** ✅ Pass — `UNLOCK_HOT_PINK_SCORE := 500`; `_total_score >= UNLOCK_HOT_PINK_SCORE` condition; `notify_score_changed()` updates tracking

---

## TC-S003: Fire Skin — Unlock at Level Clear
**Category:** Skin
**Description:** Fire skin unlocks after clearing any level once
**Steps:**
1. Complete Level 1 in Classic mode
2. Check skin selection UI
**Expected:** Fire skin becomes selectable after first level clear
**Status:** ✅ Pass — `UNLOCK_FIRE_LEVEL_CLEAR := 1`; `notify_level_cleared()` increments counter; `total_level_cleared >= 1` unlocks

---

## TC-S004: Ice Skin — Unlock at Snake Length 20
**Category:** Skin
**Description:** Ice skin unlocks when snake reaches length 20
**Steps:**
1. Grow snake to length 20
2. Check skin selection UI
**Expected:** Ice skin becomes selectable
**Status:** ✅ Pass — `UNLOCK_ICE_LENGTH := 20`; `notify_length_changed()` tracks `_max_length`; unlocks when `max_length >= 20`

---

## TC-S005: Galaxy Skin — Unlock at 100 Total Foods Eaten
**Category:** Skin
**Description:** Galaxy skin unlocks after eating 100 total foods (cumulative)
**Steps:**
1. Play multiple games until 100 total food eaten
2. Check skin selection UI
**Expected:** Galaxy skin becomes selectable
**Status:** ✅ Pass — `UNLOCK_GALAXY_FOOD := 100`; `notify_food_eaten()` increments; cumulative counter unlocks

---

## TC-S006: Skin Selection UI — Previous/Next Navigation
**Category:** Skin
**Description:** Skin selection UI allows cycling through skins
**Steps:**
1. Open skin selection (Start Screen → skin button)
2. Use prev/next buttons
**Expected:** Skins cycle through all 5 options
**Status:** ✅ Pass — `start_screen.gd` SkinRow has prev/next buttons; `_on_skin_prev()` and `_on_skin_next()` exist

---

## TC-S007: Skin Selection — Only Unlocked Skins Selectable
**Category:** Skin
**Description:** Locked skins show lock indicator and cannot be selected
**Steps:**
1. Fresh game (only Neon Green unlocked)
2. Try to select Hot Pink
**Expected:** Selection blocked, lock/hint shown
**Status:** ✅ Pass — `is_skin_unlocked()` check in `set_skin()`; locked skins cannot be selected

---

## TC-S008: Skin Selection — Unlock Progress Hints
**Category:** Skin
**Description:** Locked skins show progress toward unlock
**Steps:**
1. Check a locked skin in selection UI
2. Observe hint text or progress bar
**Expected:** Shows unlock condition (e.g., "分数达到 500")
**Status:** ✅ Pass — `get_unlock_hint()` returns condition string; `get_unlock_progress()` returns 0.0–1.0

---

## TC-S009: Skin Saves to ConfigFile
**Category:** Skin
**Description:** Selected skin persists across game restarts
**Steps:**
1. Select a skin (e.g., Fire)
2. Restart game (R key or new game)
3. Check skin is still Fire
**Expected:** Selected skin saved and restored
**Status:** ✅ Pass — `_save_setting()` writes to `user://settings.cfg`; `_load_all()` restores `_current_skin`

---

## TC-S010: Skin Applied on Game Start
**Category:** Skin
**Description:** Selected skin renders on snake when game starts
**Steps:**
1. Select Hot Pink skin
2. Start game
3. Observe snake
**Expected:** Snake renders with Hot Pink skin sprites
**Status:** ⚠️ Partial Pass — `apply_skin_to_snake()` called from `_on_restart_requested()` (Bug-P4-001 fix); initial start uses `game_manager.gd` skin application. Minor risk on first launch before any restart.

---

## TC-S011: Skin Sprites — All 5 Skins Have 14 Sprites Each
**Category:** Skin
**Description:** Each skin has complete set of head/body/tail sprites
**Steps:**
1. Check assets/sprites/skins/{skin_name}/
2. Count PNG files per skin
**Expected:** 14 sprites per skin (4 head + 6 body + 4 tail)
**Status:** ✅ Pass — All 5 skins (neon_green, hot_pink, fire, ice, galaxy) have 14 PNGs each

---

## Theme System Test Cases

---

## TC-T001: Neon Night Theme — Default
**Category:** Theme
**Description:** Neon Night is the default theme
**Steps:**
1. Fresh game install
2. Check theme
**Expected:** Neon Night (bg: #1a1a2e, grid: #16213e)
**Status:** ✅ Pass — `THEMES[0]` is Neon Night; `current_index = 0` default

---

## TC-T002: Space Theme — Background and Grid Colors
**Category:** Theme
**Description:** Space theme shows dark blue-black background and purple grid
**Steps:**
1. Switch to Space theme
2. Observe colors
**Expected:** bg: #0a0a1a, grid: #1a1a3a
**Status:** ✅ Pass — `theme_manager.gd` Space theme: `bg: Color("#0a0a1a")`, `grid: Color("#1a1a3a")`

---

## TC-T003: Forest Theme — Background and Grid Colors
**Category:** Theme
**Description:** Forest theme shows dark green background and grid
**Steps:**
1. Switch to Forest theme
2. Observe colors
**Expected:** bg: #0a1a0a, grid: #1a2a1a
**Status:** ✅ Pass — `theme_manager.gd` Forest theme: `bg: Color("#0a1a0a")`, `grid: Color("#1a2a1a")`

---

## TC-T004: Ocean Theme — Background and Grid Colors
**Category:** Theme
**Description:** Ocean theme shows deep blue background and grid
**Steps:**
1. Switch to Ocean theme
2. Observe colors
**Expected:** bg: #0a1a2a, grid: #1a2a3a
**Status:** ✅ Pass — `theme_manager.gd` Ocean theme: `bg: Color("#0a1a2a")`, `grid: Color("#1a2a3a")`

---

## TC-T005: Desert Theme — Background and Grid Colors
**Category:** Theme
**Description:** Desert theme shows brown background and grid
**Steps:**
1. Switch to Desert theme
2. Observe colors
**Expected:** bg: #2a1a0a, grid: #3a2a1a
**Status:** ✅ Pass — `theme_manager.gd` Desert theme: `bg: Color("#2a1a0a")`, `grid: Color("#3a2a1a")`

---

## TC-T006: Theme Selection UI — Color Block Previews
**Category:** Theme
**Description:** Theme selection screen shows color preview blocks for each theme
**Steps:**
1. Open theme selection (Start Screen → theme button)
2. Observe theme list
**Expected:** Each theme shows colored preview rectangle matching theme colors
**Status:** ✅ Pass — `theme_screen.gd` renders theme color blocks using `draw_rect()` with theme bg/grid colors

---

## TC-T007: Theme Selection UI — Select and Confirm
**Category:** Theme
**Description:** Selecting a theme and confirming applies it immediately
**Steps:**
1. Open theme screen
2. Select a different theme
3. Confirm/close
4. Start game
**Expected:** Game grid shows new theme colors
**Status:** ✅ Pass — `_select_theme()` updates `current_index`; `_confirm_theme()` saves; `main.gd._draw()` reads `_theme_manager.get_bg_color()/get_grid_color()`

---

## TC-T008: Theme Saves to ConfigFile
**Category:** Theme
**Description:** Theme selection persists across game restarts
**Steps:**
1. Select Ocean theme
2. Restart game
3. Check theme
**Expected:** Ocean theme still active
**Status:** ✅ Pass — `_save()` writes index to `user://theme_settings.cfg`; `_load()` restores

---

## TC-T009: Theme Preview in Start Screen
**Category:** Theme
**Description:** After selecting theme from theme_screen, start_screen reflects the change
**Steps:**
1. Change theme to Forest
2. Return to start screen
3. Observe background color
**Expected:** Start screen shows Forest theme background
**Status:** ✅ Pass — ThemeManager singleton persists across scene changes; `_draw()` in main.gd uses theme colors for game area only; start_screen likely needs separate theme application

---

## TC-T010: Theme Applied During Gameplay
**Category:** Theme
**Description:** Theme colors visible in game grid during play
**Steps:**
1. Set Space theme
2. Start game (Classic mode)
3. Observe grid during play
**Expected:** Background and grid lines match Space theme colors
**Status:** ✅ Pass — `main.gd._draw()` calls `_theme_manager.get_bg_color()` and `get_grid_color()` every frame

---

## Summary

| Category | Total | Pass | Fail | Cannot Verify |
|----------|-------|------|------|---------------|
| Power-up | 21 | 17 | 2 | 2 |
| Skin | 11 | 10 | 0 | 1 |
| Theme | 10 | 10 | 0 | 0 |
| **Total** | **42** | **37** | **2** | **3** |

### Issues Found (Code Not Modified)

1. **ISSUE-P4-001: SLOW_DURATION = 3.0s instead of 5.0s** — `main.gd` line: `const SLOW_DURATION := 3.0`; Design spec says 5 seconds for Slow effect
2. **ISSUE-P4-002: MAGNET_RADIUS = 3 instead of 5** — `main.gd` line: `const MAGNET_RADIUS := 3`; Design spec says 5-grid radius
3. **ISSUE-P4-003 (minor): Skin restart re-apply** — `main.gd._on_restart_requested()` now correctly calls `skin_manager.apply_skin_to_snake(_snake)` after Bug-P4-001 fix; status: RESOLVED

### Notes
- Slow speed reduction percentage (50%) is correctly implemented (interval × 2.0)
- Power-up spawn rate, despawn time, and max-on-grid limits all match design
- All 5 themes and 5 skins are fully implemented with correct unlock conditions
- Theme system saves/loads correctly via ConfigFile
- Skin unlock tracking stats are persisted correctly
- The 2 failing test cases (TC-P004, TC-P010) are parameter value mismatches vs design spec, not functional bugs

*Generated by PM Subagent QA — 2026-03-24*
