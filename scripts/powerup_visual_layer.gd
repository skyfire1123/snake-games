extends Node2D

## PowerUpVisualLayer — Phase 4 Sprint 2
## Renders overlay effects for active power-ups on the snake.
## Attach to main.gd as a child Node2D named "PowerUpVisualLayer".

const CELL_SIZE := 32
const GRID_OFFSET := Vector2(0, 40)

var _main: Node  # Reference to main.gd
var _snake: Node  # Reference to snake.gd

# Visual state
var _shield_active := false
var _ghost_active := false
var _magnet_active := false
var _double_points_active := false
var _slow_active := false

# Cached head position for drawing
var _head_grid_pos := Vector2i.ZERO

# Sparkle particles for double points
var _sparkle_timers: Array[Timer] = []

func _ready() -> void:
	_main = get_parent()
	_snake = _main.get_node_or_null("Snake")

func set_main_ref(main_node: Node) -> void:
	_main = main_node
	_snake = _main.get_node_or_null("Snake")

func _process(_delta: float) -> void:
	if not _main or not is_instance_valid(_main):
		return
	if not _main.has_method("is_ghost_active"):
		return

	_shield_active = _main.has_shield
	_ghost_active = _main.is_ghost_active()
	_magnet_active = _main.is_magnet_active()
	_double_points_active = _main.is_double_points_active()
	_slow_active = _main.is_slow_active()

	# Update head grid pos from snake
	if _snake and _snake.has_method("get_head_position"):
		_head_grid_pos = _snake.call("get_head_position")

	queue_redraw()

func _draw() -> void:
	var head_center := Vector2(_head_grid_pos.x * CELL_SIZE + CELL_SIZE / 2,
							   _head_grid_pos.y * CELL_SIZE + CELL_SIZE / 2) + GRID_OFFSET

	# Ghost: semi-transparent snake
	if _ghost_active:
		# Draw ghost overlay on head
		var ghost_color := Color(1.0, 1.0, 1.0, 0.4)
		var radius := CELL_SIZE * 0.45
		draw_circle(head_center, radius, ghost_color)
		# Faded aura
		var aura_color := Color(1.0, 1.0, 1.0, 0.15)
		draw_circle(head_center, radius * 1.4, aura_color)

	# Shield: blue bubble around head
	if _shield_active:
		var shield_color := Color(0.27, 0.53, 1.0, 0.25)
		var shield_border := Color(0.4, 0.7, 1.0, 0.6)
		var radius := CELL_SIZE * 0.65
		draw_circle(head_center, radius, shield_color)
		draw_arc(head_center, radius, 0, TAU, 32, shield_border, 2.0, true)
		# Small shield shimmer dots
		for i in range(6):
			var angle := (TAU * i) / 6.0
			var dot_pos := head_center + Vector2(cos(angle), sin(angle)) * radius
			draw_circle(dot_pos, 3.0, Color(0.6, 0.85, 1.0, 0.8))

	# Magnet: gold glow around head
	if _magnet_active:
		var glow_color := Color(1.0, 0.84, 0.0, 0.2)
		var glow_border := Color(1.0, 0.9, 0.3, 0.5)
		var radius := CELL_SIZE * 0.75
		draw_circle(head_center, radius, glow_color)
		draw_arc(head_center, radius, 0, TAU, 24, glow_border, 2.0, true)
		# Magnet field lines (small arcs)
		for i in range(4):
			var angle := (TAU * i) / 4.0 + sin(Time.get_ticks_msec() * 0.005 + i) * 0.2
			var inner := radius * 0.5
			var outer := radius * 0.9
			var p1 := head_center + Vector2(cos(angle), sin(angle)) * inner
			var p2 := head_center + Vector2(cos(angle), sin(angle)) * outer
			draw_line(p1, p2, Color(1.0, 0.9, 0.3, 0.4), 1.5, true)

	# Double points: "2X" text or sparkles around snake
	if _double_points_active:
		var sparkle_count := 8
		var t := Time.get_ticks_msec() * 0.003
		for i in range(sparkle_count):
			var angle := (TAU * i) / sparkle_count + t
			var dist := CELL_SIZE * 0.7 + sin(t * 2.0 + i) * 5.0
			var sparkle_pos := head_center + Vector2(cos(angle), sin(angle)) * dist
			var sparkle_color := Color(1.0, 0.85, 0.2, 0.7 + 0.3 * sin(t * 3.0 + i))
			draw_circle(sparkle_pos, 3.0 + sin(t * 4.0 + i) * 1.0, sparkle_color)

	# Slow: blue trail dots behind snake segments
	if _slow_active:
		if _snake and _snake.has_method("get_body_positions"):
			var positions: Array[Vector2i] = _snake.call("get_body_positions")
			var trail_color := Color(0.3, 0.7, 1.0, 0.35)
			# Draw trail behind each segment (offset from body)
			for idx in range(1, positions.size()):
				var seg_pos := Vector2(positions[idx].x * CELL_SIZE + CELL_SIZE / 2,
									   positions[idx].y * CELL_SIZE + CELL_SIZE / 2) + GRID_OFFSET
				var alpha := 0.3 * (1.0 - float(idx) / float(positions.size()))
				var dot_color := Color(0.3, 0.7, 1.0, alpha)
				var dot_size := maxf(2.0, 5.0 - idx * 0.4)
				draw_circle(seg_pos, dot_size, dot_color)
