extends Node2D

## FoodManager — Phase 3: manages a pool of 3-5 simultaneous food items

signal food_eaten_by_type(food_type: int, position: Vector2i)
signal food_expired(food_type: int, position: Vector2i)

const GRID_SIZE := 20
const CELL_SIZE := 32
const GRID_OFFSET := Vector2(0, 40)

# Food types matching food.gd FoodType enum
enum FoodType { NORMAL, GOLD, BLUE, TIMED }

# Spawn weights: NORMAL=55%, GOLD=25%, BLUE=12%, BOMB(=TIMED)=8%
const SPAWN_WEIGHTS := {
	FoodType.NORMAL: 55,
	FoodType.GOLD:   25,
	FoodType.BLUE:   12,
	FoodType.TIMED:   8,
}

# Points per type
const POINTS := {
	FoodType.NORMAL: 10,
	FoodType.GOLD:   25,
	FoodType.BLUE:   15,
	FoodType.TIMED:    5,
}

# Timed food lifetimes (seconds)
const LIFETIME := {
	FoodType.GOLD:  8.0,
	FoodType.BLUE:  6.0,
	FoodType.TIMED: 4.0,
}

var _active_foods: Array[Node2D] = []
var _food_scene: PackedScene
var _occupied_cells: Array[Vector2i] = []
var _min_foods: int = 3
var _max_foods: int = 5
var _replenish_mode: bool = true  # true = always top up (endless); false = stop at target (classic)

# Direct getter for active foods (more reliable than get_children() for magnet attraction)
func get_foods() -> Array[Node2D]:
	return _active_foods

func _ready() -> void:
	_food_scene = preload("res://scenes/food.tscn")

func initialize(min_foods: int, max_foods: int) -> void:
	_min_foods = clampi(min_foods, 3, 5)
	_max_foods = clampi(max_foods, 3, 5)

func clear_all() -> void:
	for food in _active_foods:
		if is_instance_valid(food):
			food.queue_free()
	_active_foods.clear()

func set_occupied_cells(cells: Array[Vector2i]) -> void:
	_occupied_cells = cells

func set_replenish_mode(replenish: bool) -> void:
	_replenish_mode = replenish

func spawn_initial_pool(count: int, replenish: bool = true) -> void:
	_replenish_mode = replenish
	clear_all()
	for i in range(count):
		spawn_one_food()

func spawn_one_food() -> void:
	if _active_foods.size() >= _max_foods:
		return
	
	var ftype := _choose_random_type()
	var food := _instantiate_food(ftype)
	if food:
		_active_foods.append(food)
		add_child(food)
		DebugLog.log_msg("SPAWN_FOOD: type=%d active=%d" % [ftype, _active_foods.size()], "FOOD")

func _instantiate_food(ftype: FoodType) -> Node2D:
	var instance: Node2D = _food_scene.instantiate()
	
	# Collect all occupied positions (snake body + other foods)
	var forbidden: Array[Vector2i] = _occupied_cells.duplicate()
	for f in _active_foods:
		if is_instance_valid(f) and f.has_method("get_grid_position"):
			forbidden.append(f.get_grid_position())
	
	var spawned: bool = instance.call("spawn", forbidden, ftype)
	if not spawned:
		instance.queue_free()
		return null
	
	# Set lifetime for timed/gold/blue types
	var lifetime: float = LIFETIME.get(ftype, -1.0)
	if lifetime > 0:
		instance.call("set_lifetime", lifetime)
	
	# Connect signals
	if not instance.food_eaten.is_connected(_on_food_eaten_internal):
		instance.food_eaten.connect(_on_food_eaten_internal.bind(instance))
	if instance.has_signal("food_expired") and not instance.food_expired.is_connected(_on_food_expired_internal):
		instance.food_expired.connect(_on_food_expired_internal.bind(instance))
	
	return instance

func _choose_random_type() -> FoodType:
	var total_weight := 0
	for w in SPAWN_WEIGHTS.values():
		total_weight += w
	
	var roll := randi() % total_weight
	var cumulative := 0
	for ftype in SPAWN_WEIGHTS.keys():
		cumulative += SPAWN_WEIGHTS[ftype]
		if roll < cumulative:
			return ftype as FoodType
	return FoodType.NORMAL

func _on_food_eaten_internal(food: Node2D) -> void:
	if not is_instance_valid(food):
		return
	
	var grid_pos: Vector2i = food.call("get_grid_position")
	var ftype_val: int = food.call("get_food_type")
	
	# Remove from active list
	var idx := _active_foods.find(food)
	if idx >= 0:
		_active_foods.remove_at(idx)
	
	food.queue_free()
	food_eaten_by_type.emit(ftype_val, grid_pos)

func _on_food_expired_internal(food: Node2D) -> void:
	if not is_instance_valid(food):
		return
	
	var idx := _active_foods.find(food)
	if idx >= 0:
		_active_foods.remove_at(idx)
	
	food.queue_free()

func get_active_count() -> int:
	return _active_foods.size()

func get_active_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for f in _active_foods:
		if is_instance_valid(f) and f.has_method("get_grid_position"):
			positions.append(f.call("get_grid_position"))
	return positions

func get_points_for_type(ftype: int) -> int:
	var v = POINTS.get(ftype, 10)
	return v as int
