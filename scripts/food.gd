extends Area2D

## Food that the snake can eat — Phase 3: sprite-based with animated timed food, lifetime support

signal food_eaten
signal food_spawned(position: Vector2i)
signal food_expired

const GRID_SIZE := 20
const CELL_SIZE := 32
const GRID_OFFSET := Vector2(0, 40)

enum FoodType { NORMAL, GOLD, BLUE, TIMED }

# Preload food sprites
const FOOD_SPRITES := {
	FoodType.NORMAL: preload("res://assets/sprites/food/food_normal.png"),
	FoodType.GOLD:   preload("res://assets/sprites/food/food_gold.png"),
	FoodType.BLUE:   preload("res://assets/sprites/food/food_blue.png"),
}

var _grid_position := Vector2i.ZERO
var _collision_shape: CollisionShape2D
var _sprite: Sprite2D
var _animated_sprite: AnimatedSprite2D
var _food_type: FoodType = FoodType.NORMAL

# Lifetime
var _lifetime: float = -1.0
var _lifetime_timer: Timer

func _ready() -> void:
	_collision_shape = $CollisionShape2D

func spawn(occupied_cells: Array[Vector2i], food_type: FoodType = FoodType.NORMAL) -> bool:
	_food_type = food_type
	
	# Set up the appropriate sprite for food type
	_setup_sprite(food_type)
	
	# Find a random empty cell
	var empty_cells: Array[Vector2i] = []
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var cell := Vector2i(x, y)
			if not cell in occupied_cells:
				empty_cells.append(cell)
	
	if empty_cells.size() > 0:
		var random_index := randi() % empty_cells.size()
		_grid_position = empty_cells[random_index]
		_update_position()
		food_spawned.emit(_grid_position)
		return true
	else:
		# Grid full → game over (emit signal with no position)
		food_spawned.emit(Vector2i(-1, -1))
		return false

func set_lifetime(seconds: float) -> void:
	_lifetime = seconds
	_lifetime_timer = Timer.new()
	_lifetime_timer.name = "LifetimeTimer"
	_lifetime_timer.one_shot = true
	_lifetime_timer.wait_time = seconds
	_lifetime_timer.timeout.connect(_on_lifetime_expired)
	add_child(_lifetime_timer)
	_lifetime_timer.start()

func _on_lifetime_expired() -> void:
	# Expired without being eaten — disappear silently
	food_expired.emit()
	queue_free()

func _setup_sprite(food_type: FoodType) -> void:
	# Remove existing sprites
	if _sprite and is_instance_valid(_sprite):
		_sprite.queue_free()
		_sprite = null
	if _animated_sprite and is_instance_valid(_animated_sprite):
		_animated_sprite.queue_free()
		_animated_sprite = null
	
	if food_type == FoodType.TIMED:
		# Use AnimatedSprite2D for timed food (blink on/off)
		_animated_sprite = AnimatedSprite2D.new()
		var frames := SpriteFrames.new()
		frames.add_animation("blink")
		# Load timed food sprites as frames
		var tex_on := preload("res://assets/sprites/food/food_timed.png")
		var tex_off := preload("res://assets/sprites/food/food_timed_off.png")
		frames.add_frame("blink", tex_on, 0)
		frames.add_frame("blink", tex_off, 1)
		_animated_sprite.sprite_frames = frames
		_animated_sprite.animation = "blink"
		_animated_sprite.speed_scale = 4.0  # blink rate
		_animated_sprite.play()
		add_child(_animated_sprite)
		_animated_sprite.position = -Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
	elif food_type == FoodType.GOLD:
		# Gold food: rotation animation
		_animated_sprite = AnimatedSprite2D.new()
		var frames := SpriteFrames.new()
		frames.add_animation("spin")
		var tex := preload("res://assets/sprites/food/food_gold.png")
		for i in range(8):
			frames.add_frame("spin", tex, i)
		_animated_sprite.sprite_frames = frames
		_animated_sprite.animation = "spin"
		_animated_sprite.speed_scale = 2.0
		_animated_sprite.play()
		add_child(_animated_sprite)
		_animated_sprite.position = -Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
	elif food_type == FoodType.BLUE:
		# Blue food: fast pulse
		_animated_sprite = AnimatedSprite2D.new()
		var frames := SpriteFrames.new()
		frames.add_animation("pulse")
		var tex := preload("res://assets/sprites/food/food_blue.png")
		for i in range(2):
			frames.add_frame("pulse", tex, i)
		_animated_sprite.sprite_frames = frames
		_animated_sprite.animation = "pulse"
		_animated_sprite.speed_scale = 3.0
		_animated_sprite.play()
		add_child(_animated_sprite)
		_animated_sprite.position = -Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
	else:
		_sprite = Sprite2D.new()
		_sprite.texture = FOOD_SPRITES.get(food_type, FOOD_SPRITES[FoodType.NORMAL])
		_sprite.centered = false
		add_child(_sprite)
		_sprite.position = Vector2.ZERO

func _update_position() -> void:
	position = Vector2(_grid_position.x * CELL_SIZE + CELL_SIZE / 2,
					   _grid_position.y * CELL_SIZE + CELL_SIZE / 2) + GRID_OFFSET
	# Adjust sprite positions to center them
	if _sprite and is_instance_valid(_sprite):
		_sprite.position = -Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
	if _animated_sprite and is_instance_valid(_animated_sprite):
		_animated_sprite.position = -Vector2(CELL_SIZE / 2, CELL_SIZE / 2)

func get_grid_position() -> Vector2i:
	return _grid_position

func set_grid_position(new_pos: Vector2i) -> void:
	_grid_position = new_pos
	_update_position()

func set_food_type(type: int) -> void:
	_food_type = type as FoodType

func get_food_type() -> int:
	return _food_type as int

func _on_area_entered(area: Area2D) -> void:
	# Validate that the collision is from the snake's head area
	var parent := area.get_parent()
	if parent and parent.has_method("get_head_position"):
		food_eaten.emit()
