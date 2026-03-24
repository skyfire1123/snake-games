extends Node2D

## Manages multiple food items on screen — Phase 3 multi-food system

enum FoodType { NORMAL = 0, GOLD = 1, BLUE = 2, BOMB = 3 }  # Match food.gd values

signal food_eaten_by_type(food_type: int, grid_pos: Vector2i)
signal food_expired(food_type: int, grid_pos: Vector2i)

const SPAWN_WEIGHTS := [55, 25, 12, 8]  # NORMAL, GOLD, BLUE, BOMB

const POINTS := [10, 25, 15, 5]  # Points per type

var _food_pool: Array[Node2D] = []
var _occupied_cells: Array[Vector2i] = []
var _pool_size: int = 3
var _replenish_mode: bool = false
var _target_count: int = 0

var _food_scene: PackedScene

func _ready() -> void:
	_food_scene = preload("res://scenes/food.tscn")

func initialize(pool_size: int, target_count: int) -> void:
	_pool_size = pool_size
	_target_count = target_count
	_clear_pool()

func set_occupied_cells(cells: Array[Vector2i]) -> void:
	_occupied_cells = cells

func set_replenish_mode(replenish: bool) -> void:
	_replenish_mode = replenish

func spawn_initial_pool(count: int, replenish: bool) -> void:
	_replenish_mode = replenish
	_pool_size = count
	_clear_pool()
	for i in range(count):
		_spawn_one_food()

func _clear_pool() -> void:
	for f in _food_pool:
		if is_instance_valid(f):
			f.queue_free()
	_food_pool.clear()

func _spawn_one_food() -> Node2D:
	DebugLog.log("SPAWN_FOOD: pool_size=%d" % _pool_size, "FOOD")
	var food: Node2D = _food_scene.instantiate()
	add_child(food)
	
	var ftype := _weighted_random_type()
	food.set_food_type(ftype)
	food.food_eaten.connect(_on_food_eaten.bind(food))
	food.food_expired.connect(_on_food_expired.bind(food))
	
	# Find empty position
	var empty_pos := _find_empty_cell()
	if empty_pos == Vector2i(-1, -1):
		food.queue_free()
		return food
	
	food.spawn(_occupied_cells)
	_occupied_cells.append(empty_pos)
	_food_pool.append(food)
	return food

func _find_empty_cell() -> Vector2i:
	var GRID_SIZE := 20
	var empty_cells: Array[Vector2i] = []
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var cell := Vector2i(x, y)
			if not cell in _occupied_cells:
				empty_cells.append(cell)
	if empty_cells.size() > 0:
		return empty_cells[randi() % empty_cells.size()]
	return Vector2i(-1, -1)

func _weighted_random_type() -> int:
	var total := 0
	for w in SPAWN_WEIGHTS:
		total += w
	var r := randi() % total
	var cumulative := 0
	for i in range(SPAWN_WEIGHTS.size()):
		cumulative += SPAWN_WEIGHTS[i]
		if r < cumulative:
			return i
	return 0  # NORMAL

func _on_food_eaten(food: Node2D) -> void:
	DebugLog.log("_on_food_eaten called", "FOOD")
	var idx := _food_pool.find(food)
	if idx == -1:
		return
	var ftype: int = food.get_food_type()
	var gpos: Vector2i = food.get_grid_position()
	
	_food_pool.remove_at(idx)
	_occupied_cells.erase(gpos)
	food.queue_free()
	
	food_eaten_by_type.emit(ftype, gpos)
	
	# Replenish if needed
	if _replenish_mode or (_food_pool.size() < _pool_size):
		_spawn_one_food()

func _on_food_expired(food: Node2D) -> void:
	var idx := _food_pool.find(food)
	if idx == -1:
		return
	var ftype: int = food.get_food_type()
	var gpos: Vector2i = food.get_grid_position()
	
	_food_pool.remove_at(idx)
	_occupied_cells.erase(gpos)
	food.queue_free()
	
	food_expired.emit(ftype, gpos)
	
	if _replenish_mode or (_food_pool.size() < _pool_size):
		_spawn_one_food()

func get_points_for_type(ftype: int) -> int:
	if ftype >= 0 and ftype < POINTS.size():
		return POINTS[ftype]
	return 10  # default to NORMAL points
