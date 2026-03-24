extends Area2D

## Food that the snake can eat

signal food_eaten
signal food_spawned(position: Vector2i)

const GRID_SIZE := 20
const CELL_SIZE := 32
const FOOD_COLOR := Color("#f87171")

var _grid_position := Vector2i.ZERO
var _collision_shape: CollisionShape2D
var _sprite: ColorRect

func _ready() -> void:
	_collision_shape = $CollisionShape2D
	_sprite = $Sprite

func spawn(occupied_cells: Array[Vector2i]) -> void:
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

func _update_position() -> void:
	position = Vector2(_grid_position.x * CELL_SIZE + CELL_SIZE / 2, 
					   _grid_position.y * CELL_SIZE + CELL_SIZE / 2)

func get_grid_position() -> Vector2i:
	return _grid_position

func _on_area_entered(area: Area2D) -> void:
	food_eaten.emit()
