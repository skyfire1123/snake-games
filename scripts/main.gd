extends Node2D

## Main game controller

const GRID_SIZE := 20
const CELL_SIZE := 32
const GRID_OFFSET := Vector2(0, 40)  # Offset for HUD space at top

const BG_COLOR := Color("#1a1a2e")
const GRID_COLOR := Color("#16213e")

var _snake: Node2D
var _food: Area2D
var _hud: CanvasLayer
var _move_timer: Timer
var _input_handler: Node2D
var _grid_drawer: Node2D

var _score := 0
var _is_game_over := false
var _occupied_cells: Array[Vector2i] = []

func _ready() -> void:
	_setup_game()

func _setup_game() -> void:
	# Get references
	_snake = $Snake
	_food = $Food
	_hud = $HUD
	_move_timer = $MoveTimer
	_input_handler = $InputHandler
	_grid_drawer = $Grid
	
	# Connect signals
	_food.food_eaten.connect(_on_food_eaten)
	_move_timer.timeout.connect(_on_move_timer_timeout)
	_hud.restart_requested.connect(_on_restart_requested)
	
	# Initialize snake with its container
	_snake.setup($SnakeContainer)
	_snake.initialize(Vector2i(10, 10), Vector2i(1, 0), 3)
	
	# Start game
	_start_game()

func _start_game() -> void:
	_score = 0
	_is_game_over = false
	_hud.hide_game_over()
	_update_occupied_cells()
	_spawn_food()
	_update_hud()
	_set_move_interval()

func _spawn_food() -> void:
	_food.spawn(_occupied_cells)

func _update_occupied_cells() -> void:
	_occupied_cells = _snake.get_body_positions()

func _on_food_eaten() -> void:
	_score += 10
	_snake.grow()
	_update_occupied_cells()
	_spawn_food()
	_update_hud()
	_set_move_interval()

func _on_move_timer_timeout() -> void:
	if _is_game_over:
		return
	
	# Get buffered direction
	var new_direction: Vector2i = _input_handler.get_next_direction()
	
	# Calculate new head position
	var head_pos: Vector2i = _snake.get_head_position()
	var new_head_pos: Vector2i = head_pos + new_direction
	
	# Check wall collision
	if new_head_pos.x < 0 or new_head_pos.x >= GRID_SIZE or new_head_pos.y < 0 or new_head_pos.y >= GRID_SIZE:
		_trigger_game_over()
		return
	
	# Check self collision (exclude tail which will move)
	var body_positions: Array[Vector2i] = _snake.get_body_positions()
	var check_positions: Array[Vector2i] = body_positions.slice(0, body_positions.size() - 1)
	if new_head_pos in check_positions:
		_trigger_game_over()
		return
	
	# Move snake
	_snake.move_to(body_positions, new_direction)
	_input_handler.set_current_direction(new_direction)
	_update_occupied_cells()

func _trigger_game_over() -> void:
	_is_game_over = true
	_move_timer.stop()
	_hud.show_game_over()

func _on_restart_requested() -> void:
	if _is_game_over:
		_setup_game()

func _update_hud() -> void:
	_hud.update_score(_score)
	_hud.update_length(_snake.get_body_positions().size())

func _set_move_interval() -> void:
	var length := int(_snake.get_body_positions().size())
	var interval := maxf(0.3 - length * 0.005, 0.05)
	_move_timer.wait_time = interval

func _draw() -> void:
	# Draw background
	draw_rect(Rect2(GRID_OFFSET, Vector2(GRID_SIZE * CELL_SIZE, GRID_SIZE * CELL_SIZE)), BG_COLOR)
	
	# Draw grid lines
	for i in range(GRID_SIZE + 1):
		# Vertical lines
		draw_line(Vector2(i * CELL_SIZE, 0) + GRID_OFFSET, 
				  Vector2(i * CELL_SIZE, GRID_SIZE * CELL_SIZE) + GRID_OFFSET, 
				  GRID_COLOR, 1.0)
		# Horizontal lines
		draw_line(Vector2(0, i * CELL_SIZE) + GRID_OFFSET, 
				  Vector2(GRID_SIZE * CELL_SIZE, i * CELL_SIZE) + GRID_OFFSET, 
				  GRID_COLOR, 1.0)
