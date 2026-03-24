extends Node2D

## Main game controller — Phase 2 (levels, speed, modes)

const GRID_SIZE := 20
const CELL_SIZE := 32
const GRID_OFFSET := Vector2(0, 40)

const BG_COLOR := Color("#1a1a2e")
const GRID_COLOR := Color("#16213e")

# Game modes
enum GameMode { CLASSIC, ENDLESS, CHALLENGE }

# Challenge mode sub-types
enum ChallengeType { TIME_LIMIT, STEP_LIMIT }

var _game_mode: GameMode = GameMode.CLASSIC
var _challenge_type: ChallengeType = ChallengeType.TIME_LIMIT

var _snake: Node2D
var _food: Area2D
var _hud: CanvasLayer
var _move_timer: Timer
var _input_handler: Node2D

var _score := 0
var _high_score := 0
var _is_game_over := false
var _occupied_cells: Array[Vector2i] = []

# Level progression
var _level := 1
var _food_remaining := 0
var _level_clear_timer: Timer

# Challenge mode
const CHALLENGE_TIME_LIMIT := 60.0
const CHALLENGE_STEP_LIMIT := 200
var _challenge_time_remaining := CHALLENGE_TIME_LIMIT
var _challenge_steps_remaining := CHALLENGE_STEP_LIMIT
var _challenge_timer: Timer

func _ready() -> void:
	_setup_game()

func start_with_mode(mode: String) -> void:
	match mode:
		"classic":
			_game_mode = GameMode.CLASSIC
		"endless":
			_game_mode = GameMode.ENDLESS
		"challenge":
			_game_mode = GameMode.CHALLENGE
	_setup_game()

func _setup_game() -> void:
	_snake = $Snake
	_food = $Food
	_hud = $HUD
	_move_timer = $MoveTimer
	_input_handler = $InputHandler

	# Level clear timer (one-shot, shows "LEVEL CLEAR" briefly)
	if not has_node("LevelClearTimer"):
		_level_clear_timer = Timer.new()
		_level_clear_timer.name = "LevelClearTimer"
		_level_clear_timer.one_shot = true
		_level_clear_timer.wait_time = 1.5
		add_child(_level_clear_timer)
		_level_clear_timer.timeout.connect(_on_level_clear_timer_timeout)
	else:
		_level_clear_timer = $LevelClearTimer

	# Challenge timer (counts down each second)
	if not has_node("ChallengeTimer"):
		_challenge_timer = Timer.new()
		_challenge_timer.name = "ChallengeTimer"
		_challenge_timer.one_shot = false
		_challenge_timer.wait_time = 1.0
		add_child(_challenge_timer)
		_challenge_timer.timeout.connect(_on_challenge_timer_tick)
	else:
		_challenge_timer = $ChallengeTimer

	# Connect signals (guard against double-connect)
	if not _food.food_eaten.is_connected(_on_food_eaten):
		_food.food_eaten.connect(_on_food_eaten)
	if not _move_timer.timeout.is_connected(_on_move_timer_timeout):
		_move_timer.timeout.connect(_on_move_timer_timeout)
	if not _hud.restart_requested.is_connected(_on_restart_requested):
		_hud.restart_requested.connect(_on_restart_requested)

	_snake.setup($SnakeContainer)
	_snake.initialize(Vector2i(10, 10), Vector2i(1, 0), 3)

	_start_game()

func _start_game() -> void:
	_score = 0
	_level = 1
	_is_game_over = false
	_hud.hide_game_over()
	_hud.hide_level_clear()
	_update_occupied_cells()
	_spawn_food_for_level()
	_update_hud()
	_set_move_interval()
	_move_timer.start()

	if _game_mode == GameMode.CHALLENGE:
		_challenge_time_remaining = CHALLENGE_TIME_LIMIT
		_challenge_steps_remaining = CHALLENGE_STEP_LIMIT
		_challenge_timer.start()
	else:
		_challenge_timer.stop()

func _food_count_for_level(level: int) -> int:
	return 10 + level * 5

func _speed_multiplier_for_level(level: int) -> float:
	return 1.0 + level * 0.1

func _spawn_food_for_level() -> void:
	_food_remaining = _food_count_for_level(_level)
	_spawn_food()

func _spawn_food() -> void:
	_food.spawn(_occupied_cells)

func _update_occupied_cells() -> void:
	_occupied_cells = _snake.get_body_positions()

func _on_food_eaten() -> void:
	_score += 10
	_snake.grow()
	_update_occupied_cells()
	_update_hud()
	_set_move_interval()

	if _game_mode == GameMode.CLASSIC:
		_food_remaining -= 1
		if _food_remaining <= 0:
			_trigger_level_clear()
		else:
			_spawn_food()
	else:
		# Endless / Challenge: just keep spawning
		_spawn_food()

func _trigger_level_clear() -> void:
	_move_timer.stop()
	_hud.show_level_clear(_level)
	_level_clear_timer.start()

func _on_level_clear_timer_timeout() -> void:
	_level += 1
	_hud.hide_level_clear()
	_snake.initialize(Vector2i(10, 10), Vector2i(1, 0), 3)
	_update_occupied_cells()
	_spawn_food_for_level()
	_update_hud()
	_set_move_interval()
	_move_timer.start()

func _on_move_timer_timeout() -> void:
	if _is_game_over:
		return

	var new_direction: Vector2i = _input_handler.get_next_direction()
	var head_pos: Vector2i = _snake.get_head_position()
	var new_head_pos: Vector2i = head_pos + new_direction

	# Wall handling
	if _game_mode == GameMode.ENDLESS:
		# Wrap around
		new_head_pos.x = posmod(new_head_pos.x, GRID_SIZE)
		new_head_pos.y = posmod(new_head_pos.y, GRID_SIZE)
	else:
		# Classic / Challenge: wall = death
		if new_head_pos.x < 0 or new_head_pos.x >= GRID_SIZE or new_head_pos.y < 0 or new_head_pos.y >= GRID_SIZE:
			_trigger_game_over()
			return

	# Self collision
	var body_positions: Array[Vector2i] = _snake.get_body_positions()
	var check_positions: Array[Vector2i] = body_positions.slice(0, body_positions.size() - 1)
	if new_head_pos in check_positions:
		_trigger_game_over()
		return

	# Build new positions array with wrapped/clamped head
	var new_positions: Array[Vector2i] = []
	new_positions.append(new_head_pos)
	for i in range(body_positions.size() - 1):
		new_positions.append(body_positions[i])

	_snake.move_to(new_positions, new_direction)
	_input_handler.set_current_direction(new_direction)
	_update_occupied_cells()

	# Challenge step tracking
	if _game_mode == GameMode.CHALLENGE and _challenge_type == ChallengeType.STEP_LIMIT:
		_challenge_steps_remaining -= 1
		_hud.update_steps(_challenge_steps_remaining)
		if _challenge_steps_remaining <= 0:
			_trigger_game_over()

func _trigger_game_over() -> void:
	_is_game_over = true
	_move_timer.stop()
	_challenge_timer.stop()
	if _score > _high_score:
		_high_score = _score
	_hud.show_game_over()
	if _game_mode == GameMode.ENDLESS:
		_hud.update_high_score(_high_score)

func _on_restart_requested() -> void:
	if _is_game_over:
		_snake.setup($SnakeContainer)
		_snake.initialize(Vector2i(10, 10), Vector2i(1, 0), 3)
		_start_game()

func _on_challenge_timer_tick() -> void:
	if _game_mode != GameMode.CHALLENGE:
		return
	if _challenge_type == ChallengeType.TIME_LIMIT:
		_challenge_time_remaining -= 1.0
		_hud.update_timer(_challenge_time_remaining)
		if _challenge_time_remaining <= 0:
			_trigger_game_over()

func _update_hud() -> void:
	_hud.update_score(_score)
	_hud.update_length(_snake.get_body_positions().size())
	_hud.update_level(_level)
	_hud.update_mode(_game_mode_name())
	if _game_mode == GameMode.ENDLESS:
		_hud.update_high_score(_high_score)

func _game_mode_name() -> String:
	match _game_mode:
		GameMode.CLASSIC:   return "CLASSIC"
		GameMode.ENDLESS:   return "ENDLESS"
		GameMode.CHALLENGE: return "CHALLENGE"
	return ""

func _set_move_interval() -> void:
	var length := int(_snake.get_body_positions().size())
	var base_interval := maxf(0.3 - length * 0.005, 0.05)
	var mult := _speed_multiplier_for_level(_level) if _game_mode == GameMode.CLASSIC else 1.0
	_move_timer.wait_time = base_interval * (1.0 / mult)

func _draw() -> void:
	draw_rect(Rect2(GRID_OFFSET, Vector2(GRID_SIZE * CELL_SIZE, GRID_SIZE * CELL_SIZE)), BG_COLOR)
	for i in range(GRID_SIZE + 1):
		draw_line(Vector2(i * CELL_SIZE, 0) + GRID_OFFSET,
				  Vector2(i * CELL_SIZE, GRID_SIZE * CELL_SIZE) + GRID_OFFSET,
				  GRID_COLOR, 1.0)
		draw_line(Vector2(0, i * CELL_SIZE) + GRID_OFFSET,
				  Vector2(GRID_SIZE * CELL_SIZE, i * CELL_SIZE) + GRID_OFFSET,
				  GRID_COLOR, 1.0)
