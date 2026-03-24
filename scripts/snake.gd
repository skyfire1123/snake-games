extends Node2D

## Visual representation and logic for the snake — Phase 3: sprite-based

signal segment_added
signal position_updated(positions: Array[Vector2i])

const GRID_SIZE := 20
const CELL_SIZE := 32

# Preload sprite textures
const HEAD_SPRITES := {
	Vector2i(0, -1): preload("res://assets/sprites/snake/snake_head_up.png"),    # UP
	Vector2i(0, 1):  preload("res://assets/sprites/snake/snake_head_down.png"),  # DOWN
	Vector2i(-1, 0): preload("res://assets/sprites/snake/snake_head_left.png"),  # LEFT
	Vector2i(1, 0):  preload("res://assets/sprites/snake/snake_head_right.png"), # RIGHT
}
const BODY_SPRITES := {
	# Straight
	Vector2i(0, 1):  preload("res://assets/sprites/snake/snake_body_vertical.png"),   # vertical
	Vector2i(1, 0):  preload("res://assets/sprites/snake/snake_body_horizontal.png"), # horizontal
	# Corners
	Vector2i(1, -1):  preload("res://assets/sprites/snake/snake_body_down_right.png"),  # turning: prev=UP, next=RIGHT → body goes DOWN then RIGHT → this is down_right
	Vector2i(-1, -1): preload("res://assets/sprites/snake/snake_body_down_left.png"),   # turning: prev=UP, next=LEFT → body goes DOWN then LEFT → down_left
	Vector2i(1, 1):   preload("res://assets/sprites/snake/snake_body_up_right.png"),    # turning: prev=DOWN, next=RIGHT → body goes UP then RIGHT → up_right
	Vector2i(-1, 1):  preload("res://assets/sprites/snake/snake_body_up_left.png"),     # turning: prev=DOWN, next=LEFT → body goes UP then LEFT → up_left
}
const TAIL_SPRITES := {
	Vector2i(0, -1): preload("res://assets/sprites/snake/snake_tail_up.png"),    # tail points UP (last body is below)
	Vector2i(0, 1):  preload("res://assets/sprites/snake/snake_tail_down.png"),   # tail points DOWN (last body is above)
	Vector2i(-1, 0): preload("res://assets/sprites/snake/snake_tail_left.png"),   # tail points LEFT (last body is right)
	Vector2i(1, 0):  preload("res://assets/sprites/snake/snake_tail_right.png"),  # tail points RIGHT (last body is left)
}

var _body_positions: Array[Vector2i] = []
var _direction := Vector2i(1, 0)  # Initial direction: RIGHT
var _snake_container: Node2D
var _body_sprites: Array[Sprite2D] = []
var _head_sprite: Sprite2D
var _tail_sprite: Sprite2D

func _ready() -> void:
	pass  # Container set via setup() by main.gd

func setup(container: Node2D) -> void:
	_snake_container = container
	_create_snake_visuals()

func _create_snake_visuals() -> void:
	# Clear existing visuals
	_clear_visuals()
	
	# Create initial segments
	for i in range(_body_positions.size()):
		var sprite := Sprite2D.new()
		sprite.texture = _get_texture_for_segment(i)
		sprite.centered = false
		_snake_container.add_child(sprite)
		_body_sprites.append(sprite)
		
		if i == 0:
			_head_sprite = sprite
		elif i == _body_positions.size() - 1:
			_tail_sprite = sprite
		
		_update_segment_position(sprite, _body_positions[i])

func _clear_visuals() -> void:
	for sp in _body_sprites:
		if is_instance_valid(sp):
			sp.queue_free()
	_body_sprites.clear()
	_head_sprite = null
	_tail_sprite = null

func initialize(start_pos: Vector2i, direction: Vector2i, length: int) -> void:
	_direction = direction
	_body_positions.clear()
	
	# Create initial body positions (head at start, body extending backward)
	for i in range(length):
		_body_positions.append(start_pos - direction * i)
	
	_create_snake_visuals()
	position_updated.emit(_body_positions)

func move_to(new_positions: Array[Vector2i], new_direction: Vector2i) -> void:
	_direction = new_direction
	_body_positions = new_positions
	
	# Ensure we have enough visual segments
	while _body_sprites.size() < _body_positions.size():
		var sprite := Sprite2D.new()
		sprite.centered = false
		_snake_container.add_child(sprite)
		_body_sprites.append(sprite)
		segment_added.emit()
	
	# Update positions and textures
	for i in range(_body_positions.size()):
		if i < _body_sprites.size():
			_update_segment_position(_body_sprites[i], _body_positions[i])
			_body_sprites[i].texture = _get_texture_for_segment(i)
	
	# Set head and tail references
	if _body_sprites.size() > 0:
		_head_sprite = _body_sprites[0]
		_tail_sprite = _body_sprites[_body_sprites.size() - 1]
	
	position_updated.emit(_body_positions)

func grow() -> void:
	# Add new position at the end (will be adjusted on next move)
	var tail_pos: Vector2i
	if _body_positions.size() >= 2:
		tail_pos = _body_positions[_body_positions.size() - 1] + (_body_positions[_body_positions.size() - 1] - _body_positions[_body_positions.size() - 2])
	else:
		tail_pos = _body_positions[0] + _direction
	
	_body_positions.append(tail_pos)
	
	# Add new visual segment
	var sprite := Sprite2D.new()
	sprite.centered = false
	_snake_container.add_child(sprite)
	_body_sprites.append(sprite)
	
	_update_segment_position(sprite, tail_pos)
	sprite.texture = _get_texture_for_segment(_body_positions.size() - 1)
	_tail_sprite = sprite
	
	segment_added.emit()

func get_body_positions() -> Array[Vector2i]:
	return _body_positions

func get_direction() -> Vector2i:
	return _direction

func get_head_position() -> Vector2i:
	if _body_positions.size() > 0:
		return _body_positions[0]
	return Vector2i(10, 10)

func get_head_sprite() -> Sprite2D:
	return _head_sprite

func shrink_to(new_positions: Array[Vector2i]) -> void:
	_body_positions = new_positions
	# Remove excess visual segments
	while _body_sprites.size() > _body_positions.size():
		var last := _body_sprites.pop_back()
		if is_instance_valid(last):
			last.queue_free()
	_tail_sprite = _body_sprites[_body_sprites.size() - 1] if _body_sprites.size() > 0 else null
	position_updated.emit(_body_positions)

const GRID_OFFSET := Vector2(0, 40)

func _update_segment_position(sprite: Sprite2D, grid_pos: Vector2i) -> void:
	var world_pos := Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE) + GRID_OFFSET
	sprite.position = world_pos

func _get_texture_for_segment(index: int) -> Texture2D:
	if index == 0:
		# Head: use direction-facing sprite
		return HEAD_SPRITES.get(_direction, HEAD_SPRITES[Vector2i(1, 0)])
	elif index == _body_positions.size() - 1:
		# Tail: sprite faces away from previous body segment
		var prev_pos: Vector2i = _body_positions[index - 1]
		var tail_pos: Vector2i = _body_positions[index]
		var facing := prev_pos - tail_pos  # direction the tail is pointing
		return TAIL_SPRITES.get(facing, TAIL_SPRITES[Vector2i(1, 0)])
	else:
		# Body: straight or corner based on prev/next positions
		var prev_pos: Vector2i = _body_positions[index - 1]
		var next_pos: Vector2i = _body_positions[index + 1]
		
		# Direction from prev to current, and current to next
		var dir_to_prev := prev_pos - _body_positions[index]
		var dir_to_next := next_pos - _body_positions[index]
		
		# If straight (same direction both ways)
		if dir_to_prev == -dir_to_next:
			# Straight segment
			# Use the direction of travel (dir_to_next)
			return BODY_SPRITES.get(dir_to_next, BODY_SPRITES[Vector2i(1, 0)])
		else:
			# Corner: determine corner type from direction changes
			# dir_to_prev is the direction we came FROM (opposite of travel)
			# dir_to_next is the direction we're going TO
			# For corner sprites we store the diagonal direction
			# snake_body_up_right means: body connects UP and RIGHT
			return BODY_SPRITES.get(dir_to_next, BODY_SPRITES[Vector2i(1, 0)])
