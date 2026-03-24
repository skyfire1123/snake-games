extends Node2D

## PowerUpManager — Phase 4: Spawns and manages power-ups on the grid

# Power-up types
enum PowerUpType { SHIELD, SLOW, GHOST, MAGNET, DOUBLE_POINTS, SHRINK }

# Color for each type (used for placeholder sprites)
const TYPE_COLORS := {
	PowerUpType.SHIELD:         Color("#4488FF"),
	PowerUpType.SLOW:          Color("#44FFFF"),
	PowerUpType.GHOST:         Color("#FFFFFF"),
	PowerUpType.MAGNET:        Color("#FFD700"),
	PowerUpType.DOUBLE_POINTS: Color("#FF44AA"),
	PowerUpType.SHRINK:        Color("#AA44FF"),
}

# Effect durations in seconds
const EFFECT_DURATION := {
	PowerUpType.SHIELD:        9999.0,  # Until hit
	PowerUpType.SLOW:          5.0,
	PowerUpType.GHOST:         3.0,
	PowerUpType.MAGNET:        5.0,
	PowerUpType.DOUBLE_POINTS: 10.0,
	PowerUpType.SHRINK:        0.0,  # Instant
}

# Lifetime before despawn
const LIFETIME_SECONDS := 8.0

signal power_up_collected(power_type: PowerUpType, grid_pos: Vector2i)

var _active_powerups: Array[Node2D] = []
var _occupied_cells: Array[Vector2i] = []
var _grid_size := 20
var _cell_size := 32
var _grid_offset := Vector2(0, 40)
var _food_eaten_counter := 0

func _ready() -> void:
	pass

func set_occupied_cells(cells: Array[Vector2i]) -> void:
	_occupied_cells = cells

func get_occupied_cells() -> Array[Vector2i]:
	return _occupied_cells

func on_food_eaten() -> void:
	_food_eaten_counter += 1
	if _food_eaten_counter % 5 == 0 and randf() < 0.5:
		spawn_random_powerup()

func spawn_random_powerup() -> void:
	var ptype: PowerUpType = randi() % PowerUpType.size()
	spawn_powerup(ptype)

func spawn_powerup(ptype: PowerUpType) -> void:
	var powerup := _create_powerup_node(ptype)
	var grid_pos := _find_empty_cell()
	if grid_pos == Vector2i(-1, -1):
		powerup.queue_free()
		return

	add_child(powerup)
	powerup.position = Vector2(grid_pos.x * _cell_size, grid_pos.y * _cell_size) + _grid_offset
	powerup.set_meta("grid_pos", grid_pos)
	powerup.set_meta("power_type", ptype)

	_active_powerups.append(powerup)
	_occupied_cells.append(grid_pos)

	# Auto-despawn after LIFETIME_SECONDS
	var despawn_timer := Timer.new()
	despawn_timer.one_shot = true
	despawn_timer.wait_time = LIFETIME_SECONDS
	add_child(despawn_timer)
	despawn_timer.timeout.connect(_on_powerup_despawn.bind(powerup, despawn_timer))
	despawn_timer.start()

func _create_powerup_node(ptype: PowerUpType) -> Node2D:
	# Create a Node2D with a ColorRect placeholder sprite
	var node := Node2D.new()
	node.set_meta("power_type", ptype)

	var cr := ColorRect.new()
	cr.color = TYPE_COLORS[ptype]
	var margin := 4.0
	cr.size = Vector2(_cell_size - margin * 2, _cell_size - margin * 2)
	cr.position = Vector2(margin, margin)
	node.add_child(cr)

	# Add an Area2D for collision detection
	var area := Area2D.new()
	area.set_meta("power_type", ptype)
	var shape := CircleShape2D.new()
	shape.radius = _cell_size / 2.0 - 2.0
	var cs := CollisionShape2D.new()
	cs.shape = shape
	area.add_child(cs)
	node.add_child(area)

	area.body_entered.connect(_on_powerup_body_entered.bind(node, area))

	return node

func _on_powerup_body_entered(body: Node2D, powerup_node: Node2D, area: Area2D) -> void:
	# Only snake head triggers collection
	if not body.has_method("get_head_position"):
		return

	var head_pos: Vector2i = body.get_head_position()
	var ptype: PowerUpType = powerup_node.get_meta("power_type") as PowerUpType
	var grid_pos: Vector2i = powerup_node.get_meta("grid_pos") as Vector2i

	if head_pos == grid_pos:
		collect_powerup(powerup_node, area, ptype, grid_pos)

func collect_powerup(powerup_node: Node2D, area: Area2D, ptype: PowerUpType, grid_pos: Vector2i) -> void:
	if not is_instance_valid(powerup_node):
		return

	var idx := _active_powerups.find(powerup_node)
	if idx >= 0:
		_active_powerups.remove_at(idx)

	_occupied_cells.erase(grid_pos)
	powerup_node.queue_free()
	power_up_collected.emit(ptype, grid_pos)

func _on_powerup_despawn(powerup_node: Node2D, timer: Timer) -> void:
	if not is_instance_valid(powerup_node):
		timer.queue_free()
		return

	var grid_pos: Vector2i = powerup_node.get_meta("grid_pos") as Vector2i
	var idx := _active_powerups.find(powerup_node)
	if idx >= 0:
		_active_powerups.remove_at(idx)

	_occupied_cells.erase(grid_pos)
	powerup_node.queue_free()
	timer.queue_free()

func _find_empty_cell() -> Vector2i:
	var forbidden: Array[Vector2i] = _occupied_cells.duplicate()
	for pu in _active_powerups:
		if is_instance_valid(pu) and pu.has_meta("grid_pos"):
			forbidden.append(pu.get_meta("grid_pos"))

	var empty_cells: Array[Vector2i] = []
	for x in range(_grid_size):
		for y in range(_grid_size):
			var cell := Vector2i(x, y)
			if not cell in forbidden:
				empty_cells.append(cell)

	if empty_cells.size() > 0:
		return empty_cells[randi() % empty_cells.size()]
	return Vector2i(-1, -1)

func get_active_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for pu in _active_powerups:
		if is_instance_valid(pu) and pu.has_meta("grid_pos"):
			positions.append(pu.get_meta("grid_pos"))
	return positions

func clear_all() -> void:
	for pu in _active_powerups:
		if is_instance_valid(pu):
			pu.queue_free()
	_active_powerups.clear()
