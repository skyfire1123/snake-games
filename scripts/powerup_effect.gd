extends Node

## PowerUpEffect — Phase 4: Handles temporary power-up effects on the snake
## Attached to the Snake node; provides methods called by main.gd

# Shield: blocks 1 death then clears
var has_shield := false

# Ghost: pass through walls for N seconds
var is_ghost := false
var _ghost_timer: float = 0.0
const GHOST_DURATION := 3.0

# Magnet: food attracted within 3-grid radius for N seconds
var is_magnet := false
var _magnet_timer: float = 0.0
const MAGNET_DURATION := 5.0
const MAGNET_RADIUS := 3  # grid cells

# Double points: 2x score for N seconds
var is_double_points := false
var _double_points_timer: float = 0.0
const DOUBLE_POINTS_DURATION := 10.0

# Slow: handled in main.gd via _slow_timer
# (no separate effect needed here, just flag for snake reference)

func _process(delta: float) -> void:
	# Ghost countdown
	if _ghost_timer > 0:
		_ghost_timer -= delta
		if _ghost_timer <= 0:
			_ghost_timer = 0
			is_ghost = false

	# Magnet countdown
	if _magnet_timer > 0:
		_magnet_timer -= delta
		if _magnet_timer <= 0:
			_magnet_timer = 0
			is_magnet = false

	# Double points countdown
	if _double_points_timer > 0:
		_double_points_timer -= delta
		if _double_points_timer <= 0:
			_double_points_timer = 0
			is_double_points = false

func apply_shield() -> void:
	has_shield = true

func apply_ghost() -> void:
	is_ghost = true
	_ghost_timer = GHOST_DURATION

func apply_magnet() -> void:
	is_magnet = true
	_magnet_timer = MAGNET_DURATION

func apply_double_points() -> void:
	is_double_points = true
	_double_points_timer = DOUBLE_POINTS_DURATION

func apply_shrink(body_positions: Array[Vector2i]) -> Array[Vector2i]:
	# Remove up to 3 segments from tail, minimum length 3
	var min_length := 3
	var shrink_count := mini(3, body_positions.size() - min_length)
	if shrink_count > 0:
		return body_positions.slice(0, body_positions.size() - shrink_count)
	return body_positions

func is_effect_active(effect_name: String) -> bool:
	match effect_name:
		"shield":   return has_shield
		"ghost":    return is_ghost
		"magnet":   return is_magnet
		"double":   return is_double_points
	return false

func get_magnet_radius() -> int:
	return MAGNET_RADIUS

func clear_shield() -> void:
	has_shield = false

func get_remaining_time(effect_name: String) -> float:
	match effect_name:
		"ghost":   return _ghost_timer
		"magnet":  return _magnet_timer
		"double":  return _double_points_timer
	return 0.0
