extends Node2D

## Mobile/virtual joystick input handler — Phase 3
## Detects swipe gestures and converts them to snake directions

class_name MobileInput

signal direction_changed(new_direction: Vector2i)

const SWIPE_THRESHOLD := 20.0  # minimum drag distance to register a direction
const MAX_TOUCH_COUNT := 1

var _touch_start := Vector2.ZERO
var _last_drag_position := Vector2.ZERO
var _is_dragging := false

func _ready() -> void:
	# Enable to catch all unhandled input
	process_priority = 10

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			# Touch started
			_touch_start = event.position
			_last_drag_position = event.position
			_is_dragging = true
		else:
			# Touch ended
			_is_dragging = false
	elif event is InputEventScreenDrag and _is_dragging:
		var drag := event as InputEventScreenDrag
		var delta := drag.position - _touch_start
		
		if delta.length() > SWIPE_THRESHOLD:
			var direction := _get_direction_from_vector(delta)
			if direction != Vector2i.ZERO:
				direction_changed.emit(direction)
				# Reset touch to prevent repeated emissions
				_touch_start = drag.position

func _get_direction_from_vector(vec: Vector2) -> Vector2i:
	var abs_x := absf(vec.x)
	var abs_y := absf(vec.y)
	
	if abs_x > abs_y:
		# Horizontal swipe
		if vec.x > 0:
			return Vector2i(1, 0)   # RIGHT
		else:
			return Vector2i(-1, 0)  # LEFT
	else:
		# Vertical swipe
		if vec.y > 0:
			return Vector2i(0, 1)   # DOWN
		else:
			return Vector2i(0, -1)  # UP
