extends Node2D

## Visual representation and logic for the snake — Phase 4: skin system

signal segment_added
signal position_updated(positions: Array[Vector2i])

const GRID_SIZE := 20
const CELL_SIZE := 32
const GRID_OFFSET := Vector2(0, 40)

# Skin textures — populated at runtime by apply_skin()
var _head_textures: Dictionary = {}   # Vector2i dir -> Texture2D
var _body_textures: Dictionary = {}   # Vector2i key -> Texture2D
var _tail_textures: Dictionary = {}   # Vector2i dir -> Texture2D

var _body_positions: Array[Vector2i] = []
var _direction := Vector2i(1, 0)  # Initial direction: RIGHT
var _snake_container: Node2D
var _body_sprites: Array[Sprite2D] = []
var _head_sprite: Sprite2D
var _tail_sprite: Sprite2D

# Phase 4: Ghost transparency
var _ghost_modulate := Color(1.0, 1.0, 1.0, 1.0)
var _target_ghost_modulate := Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	_load_default_skin()

func _load_default_skin() -> void:
	# Fallback: load from assets/sprites/snake/ (original sprites)
	var base := "res://assets/sprites/snake/"
	_head_textures = {
		Vector2i(0, -1): load(base + "snake_head_up.png"),
		Vector2i(0, 1):  load(base + "snake_head_down.png"),
		Vector2i(-1, 0): load(base + "snake_head_left.png"),
		Vector2i(1, 0):  load(base + "snake_head_right.png"),
	}
	_body_textures = {
		Vector2i(0, 1):   load(base + "snake_body_vertical.png"),
		Vector2i(1, 0):   load(base + "snake_body_horizontal.png"),
		Vector2i(1, -1):  load(base + "snake_body_down_right.png"),
		Vector2i(-1, -1): load(base + "snake_body_down_left.png"),
		Vector2i(1, 1):   load(base + "snake_body_up_right.png"),
		Vector2i(-1, 1):  load(base + "snake_body_up_left.png"),
	}
	_tail_textures = {
		Vector2i(0, -1): load(base + "snake_tail_up.png"),
		Vector2i(0, 1):  load(base + "snake_tail_down.png"),
		Vector2i(-1, 0): load(base + "snake_tail_left.png"),
		Vector2i(1, 0):  load(base + "snake_tail_right.png"),
	}

func apply_skin(textures: Dictionary) -> void:
	# textures: { "snake_head_up": Texture2D, ... } from SkinManager
	_head_textures = {
		Vector2i(0, -1): textures.get("snake_head_up"),
		Vector2i(0, 1):  textures.get("snake_head_down"),
		Vector2i(-1, 0): textures.get("snake_head_left"),
		Vector2i(1, 0):  textures.get("snake_head_right"),
	}
	_body_textures = {
		Vector2i(0, 1):   textures.get("snake_body_vertical"),
		Vector2i(1, 0):   textures.get("snake_body_horizontal"),
		Vector2i(1, -1):  textures.get("snake_body_down_right"),
		Vector2i(-1, -1): textures.get("snake_body_down_left"),
		Vector2i(1, 1):   textures.get("snake_body_up_right"),
		Vector2i(-1, 1):  textures.get("snake_body_up_left"),
	}
	_tail_textures = {
		Vector2i(0, -1): textures.get("snake_tail_up"),
		Vector2i(0, 1):  textures.get("snake_tail_down"),
		Vector2i(-1, 0): textures.get("snake_tail_left"),
		Vector2i(1, 0):  textures.get("snake_tail_right"),
	}
	# Refresh visuals if already spawned
	for i in range(_body_sprites.size()):
		if is_instance_valid(_body_sprites[i]):
			_body_sprites[i].texture = _get_texture_for_segment(i)

func _process(delta: float) -> void:
	if _ghost_modulate != _target_ghost_modulate:
		_ghost_modulate = _ghost_modulate.lerp(_target_ghost_modulate, delta * 8.0)
		if absf(_ghost_modulate.a - _target_ghost_modulate.a) < 0.01:
			_ghost_modulate = _target_ghost_modulate
		_apply_ghost_modulate()

func set_ghost_mode(active: bool) -> void:
	if active:
		_target_ghost_modulate = Color(1.0, 1.0, 1.0, 0.4)
	else:
		_target_ghost_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _apply_ghost_modulate() -> void:
	for sp in _body_sprites:
		if is_instance_valid(sp):
			sp.modulate = _ghost_modulate

func setup(container: Node2D) -> void:
	_snake_container = container
	_create_snake_visuals()

func _create_snake_visuals() -> void:
	_clear_visuals()
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
	for i in range(length):
		_body_positions.append(start_pos - direction * i)
	_create_snake_visuals()
	position_updated.emit(_body_positions)

func move_to(new_positions: Array[Vector2i], new_direction: Vector2i) -> void:
	_direction = new_direction
	_body_positions = new_positions
	while _body_sprites.size() < _body_positions.size():
		var sprite := Sprite2D.new()
		sprite.centered = false
		_snake_container.add_child(sprite)
		_body_sprites.append(sprite)
		segment_added.emit()
	for i in range(_body_positions.size()):
		if i < _body_sprites.size():
			_update_segment_position(_body_sprites[i], _body_positions[i])
			_body_sprites[i].texture = _get_texture_for_segment(i)
	if _body_sprites.size() > 0:
		_head_sprite = _body_sprites[0]
		_tail_sprite = _body_sprites[_body_sprites.size() - 1]
	position_updated.emit(_body_positions)

func grow() -> void:
	var tail_pos: Vector2i
	if _body_positions.size() >= 2:
		tail_pos = _body_positions[_body_positions.size() - 1] + (_body_positions[_body_positions.size() - 1] - _body_positions[_body_positions.size() - 2])
	else:
		tail_pos = _body_positions[0] + _direction
	_body_positions.append(tail_pos)
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
	while _body_sprites.size() > _body_positions.size():
		var last := _body_sprites.pop_back()
		if is_instance_valid(last):
			last.queue_free()
	_tail_sprite = _body_sprites[_body_sprites.size() - 1] if _body_sprites.size() > 0 else null
	position_updated.emit(_body_positions)

func _update_segment_position(sprite: Sprite2D, grid_pos: Vector2i) -> void:
	sprite.position = Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE) + GRID_OFFSET

func _get_texture_for_segment(index: int) -> Texture2D:
	if index == 0:
		return _head_textures.get(_direction, _head_textures.get(Vector2i(1, 0)))
	elif index == _body_positions.size() - 1:
		var prev_pos: Vector2i = _body_positions[index - 1]
		var tail_pos: Vector2i = _body_positions[index]
		var facing := prev_pos - tail_pos
		return _tail_textures.get(facing, _tail_textures.get(Vector2i(1, 0)))
	else:
		var prev_pos: Vector2i = _body_positions[index - 1]
		var next_pos: Vector2i = _body_positions[index + 1]
		var dir_to_prev := prev_pos - _body_positions[index]
		var dir_to_next := next_pos - _body_positions[index]
		if dir_to_prev == -dir_to_next:
			return _body_textures.get(dir_to_next, _body_textures.get(Vector2i(1, 0)))
		else:
			return _body_textures.get(dir_to_next, _body_textures.get(Vector2i(1, 0)))
