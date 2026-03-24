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

	# Auto-despawn after LIFETIME_SECONDS (parented to powerup for cleanup)
	var despawn_timer := Timer.new()
	despawn_timer.one_shot = true
	despawn_timer.wait_time = LIFETIME_SECONDS
	powerup.add_child(despawn_timer)
	despawn_timer.timeout.connect(_on_powerup_despawn.bind(powerup))
	despawn_timer.start()

func _create_powerup_node(ptype: PowerUpType) -> Node2D:
	# Create a Node2D with Sprite2D using the actual PNG sprite
	var node := Node2D.new()
	node.set_meta("power_type", ptype)

	var sprite := Sprite2D.new()
	sprite.centered = false
	var sprite_names := ["powerup_shield.png", "powerup_slow.png", "powerup_ghost.png",
						  "powerup_magnet.png", "powerup_double.png", "powerup_shrink.png"]
	if ptype >= 0 and ptype < sprite_names.size():
		var path := "res://assets/sprites/powerups/" + sprite_names[ptype]
		if ResourceLoader.exists(path):
			sprite.texture = load(path)
	node.add_child(sprite)

	# Add an Area2D for collision detection (informational — snake uses ColorRect, not Area2D body)
	var area := Area2D.new()
	area.set_meta("power_type", ptype)
	var shape := CircleShape2D.new()
	shape.radius = _cell_size / 2.0 - 2.0
	var cs := CollisionShape2D.new()
	cs.shape = shape
	area.add_child(cs)
	node.add_child(area)

	# NOTE: Snake uses ColorRect segments (not Area2D physics body), so
	# area_entered/body_entered signals won't fire on snake segments.
	# Collection is handled via collect_powerup_at_grid() from main.gd.

	return node

func collect_powerup(powerup_node: Node2D, area: Area2D, ptype: PowerUpType, grid_pos: Vector2i) -> void:
	if not is_instance_valid(powerup_node):
		return

	var idx := _active_powerups.find(powerup_node)
	if idx >= 0:
		_active_powerups.remove_at(idx)

	_occupied_cells.erase(grid_pos)
	powerup_node.queue_free()
	power_up_collected.emit(ptype, grid_pos)

# Collect powerup by grid position (called from main.gd — snake has no Area2D body)
func collect_powerup_at_grid(grid_pos: Vector2i) -> void:
	var target_pu: Node2D = null
	for pu in _active_powerups:
		if is_instance_valid(pu) and pu.has_meta("grid_pos"):
			var pu_pos: Vector2i = pu.get_meta("grid_pos") as Vector2i
			if pu_pos == grid_pos:
				target_pu = pu
				break
	if target_pu:
		var ptype_int: int = target_pu.get_meta("power_type") as int
		var ptype: PowerUpType = ptype_int as PowerUpType
		var idx := _active_powerups.find(target_pu)
		if idx >= 0:
			_active_powerups.remove_at(idx)
		_occupied_cells.erase(grid_pos)
		target_pu.queue_free()
		power_up_collected.emit(ptype, grid_pos)

func _on_powerup_despawn(powerup_node: Node2D) -> void:
	if not is_instance_valid(powerup_node):
		return

	var grid_pos: Vector2i = powerup_node.get_meta("grid_pos") as Vector2i
	var idx := _active_powerups.find(powerup_node)
	if idx >= 0:
		_active_powerups.remove_at(idx)

	_occupied_cells.erase(grid_pos)
	# Timer is a child of powerup_node, freed automatically by queue_free()
	powerup_node.queue_free()

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
