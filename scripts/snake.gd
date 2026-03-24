extends Node2D

## Visual representation and logic for the snake

signal segment_added
signal position_updated(positions: Array[Vector2i])

const GRID_SIZE := 20
const CELL_SIZE := 32
const HEAD_COLOR := Color("#4ade80")
const BODY_COLOR := Color("#22c55e")
const TAIL_COLOR := Color("#16a34a")

var _body_positions: Array[Vector2i] = []
var _direction := Vector2i(1, 0)  # Initial direction: RIGHT
var _snake_container: Node2D
var _head_rect: ColorRect
var _body_segments: Array[ColorRect] = []
var _tail_rect: ColorRect

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
		var segment := ColorRect.new()
		segment.size = Vector2(CELL_SIZE - 2, CELL_SIZE - 2)
		_update_segment_color(segment, i)
		_snake_container.add_child(segment)
		_body_segments.append(segment)
		
		if i == 0:
			_head_rect = segment
		elif i == _body_positions.size() - 1:
			_tail_rect = segment
		
		_update_segment_position(segment, _body_positions[i])

func _clear_visuals() -> void:
	for seg in _body_segments:
		if is_instance_valid(seg):
			seg.queue_free()
	_body_segments.clear()
	_head_rect = null
	_tail_rect = null

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
	while _body_segments.size() < _body_positions.size():
		var segment := ColorRect.new()
		segment.size = Vector2(CELL_SIZE - 2, CELL_SIZE - 2)
		_snake_container.add_child(segment)
		_body_segments.append(segment)
		segment_added.emit()
	
	# Update positions and colors
	for i in range(_body_positions.size()):
		if i < _body_segments.size():
			_update_segment_position(_body_segments[i], _body_positions[i])
			_update_segment_color(_body_segments[i], i)
	
	# Set head and tail references
	if _body_segments.size() > 0:
		_head_rect = _body_segments[0]
		_tail_rect = _body_segments[_body_segments.size() - 1]
	
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
	var segment := ColorRect.new()
	segment.size = Vector2(CELL_SIZE - 2, CELL_SIZE - 2)
	_snake_container.add_child(segment)
	_body_segments.append(segment)
	
	_update_segment_position(segment, tail_pos)
	_update_segment_color(segment, _body_positions.size() - 1)
	_tail_rect = segment
	
	segment_added.emit()

func get_body_positions() -> Array[Vector2i]:
	return _body_positions

func get_direction() -> Vector2i:
	return _direction

func get_head_position() -> Vector2i:
	if _body_positions.size() > 0:
		return _body_positions[0]
	return Vector2i(10, 10)

func _update_segment_position(segment: ColorRect, grid_pos: Vector2i) -> void:
	var world_pos := Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE)
	segment.position = world_pos + Vector2(1, 1)

func _update_segment_color(segment: ColorRect, index: int) -> void:
	if index == 0:
		segment.color = HEAD_COLOR
	elif index == _body_positions.size() - 1:
		segment.color = TAIL_COLOR
	else:
		segment.color = BODY_COLOR
