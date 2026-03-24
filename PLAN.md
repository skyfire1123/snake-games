# Snake Game Phase 2 Plan

## Tasks

### 1. Start Screen
- **Status:** pending
- **Targets:** scenes/start_screen.tscn, scripts/start_screen.gd, project.godot
- **Goal:** Add a start screen with Classic / Endless / Challenge buttons
- **Requirements:** Buttons emit signal with selected mode, project.godot main scene = start_screen.tscn

### 2. Level Progression + Speed System
- **Status:** pending
- **Targets:** scripts/main.gd, scripts/hud.gd, scenes/hud.tscn
- **Goal:** Level up when all food eaten, speed multiplier per level, HUD shows LEVEL/MODE
- **Requirements:** Level N: food=10+N*5, speed_mult=1.0+N*0.1; base interval=max(0.3+len*0.005,0.05); actual=base*(1/mult)

### 3. Endless Mode
- **Status:** pending
- **Targets:** scripts/main.gd, scripts/hud.gd, scenes/hud.tscn
- **Goal:** Wall wrap, continuous scoring, high score display
- **Requirements:** No death on wall contact, wrap position, show HIGH SCORE in HUD

### 4. Challenge Mode Framework + HUD
- **Status:** pending
- **Targets:** scripts/main.gd, scripts/hud.gd, scenes/hud.tscn
- **Goal:** Time/step limit framework, TIMER/STEPS in HUD
- **Requirements:** Challenge mode shows timer or steps remaining
