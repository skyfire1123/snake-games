extends Node2D
class_name InputHandler

## Handles keyboard input for snake direction — Phase 2 + mobile swipe input (Phase 3)
## Buffers the next direction, applies on next move tick

signal direction_changed(new_direction: Vector2i)

const DIRECTIONS := {
	KEY_UP: Vector2i(0, -1),
	KEY_DOWN: Vector2i(0, 1),
	KEY_LEFT: Vector2i(-1, 0),
	KEY_RIGHT: Vector2i(1, 0),
	KEY_W: Vector2i(0, -1),
	KEY_S: Vector2i(0, 1),
	KEY_A: Vector2i(-1, 0),
	KEY_D: Vector2i(1, 0),
}

var _current_direction := Vector2i(1, 0)  # Initial direction: RIGHT
var _next_direction := Vector2i(1, 0)

# Phase 3: reference to mobile input
var _mobile_input: Node

func _ready() -> void:
	# Buffer initial direction
	_next_direction = _current_direction
	
	# Phase 3: try to connect to mobile input
	_mobile_input = get_parent().get_node_or_null("MobileInput")
	if _mobile_input and _mobile_input.has_signal("direction_changed"):
		_mobile_input.direction_changed.connect(_on_mobile_direction_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var new_dir := _get_direction_from_event(event)
		if new_dir != Vector2i.ZERO:
			# Prevent 180-degree turns
			if new_dir != -_current_direction:
				_next_direction = new_dir

## Phase 3: handle mobile swipe direction
func _on_mobile_direction_changed(new_dir: Vector2i) -> void:
	if new_dir != -_current_direction:
		_next_direction = new_dir

## BUG-003 fix: clear buffered direction on game start/restart
func clear_buffer() -> void:
	_next_direction = _current_direction

## Called by main.gd on each move tick to get buffered direction
func get_next_direction() -> Vector2i:
	return _next_direction

## Update current direction after move tick
func set_current_direction(dir: Vector2i) -> void:
	_current_direction = dir

func _get_direction_from_event(event: InputEventKey) -> Vector2i:
	for key in DIRECTIONS:
		if event.keycode == key:
			return DIRECTIONS[key]
	return Vector2i.ZERO
