extends Node2D

## Main game controller — Phase 2 (levels, speed, modes) + Phase 3 (multi-food, slow effect)

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
var _food_manager: Node2D
var _hud: CanvasLayer
var _move_timer: Timer
var _input_handler: Node2D
var _particle_system: Node2D
var _audio_manager: Node
var _camera: Camera2D

var _score := 0
var _high_score := 0
var _is_game_over := false
var _occupied_cells: Array[Vector2i] = []

# Level progression
var _level := 1
var _food_eaten_this_level: int = 0
var _food_target_this_level: int = 0
var _level_clear_timer: Timer

# Challenge mode
const CHALLENGE_TIME_LIMIT := 60.0
const CHALLENGE_STEP_LIMIT := 200
var _challenge_time_remaining := CHALLENGE_TIME_LIMIT
var _challenge_steps_remaining := CHALLENGE_STEP_LIMIT
var _challenge_timer: Timer

# Phase 3: screen shake
var _shake_duration := 0.0
var _shake_intensity := 0.0
var _original_camera_offset := Vector2.ZERO

# Phase 3: slow effect
const SLOW_DURATION := 3.0
var _slow_timer: float = 0.0
var _base_move_interval: float = 0.3

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# Phase 3: screen shake
	if _shake_duration > 0:
		_process_shake()
		_shake_duration -= delta
		if _shake_duration <= 0:
			_reset_camera()
	
	# Phase 3: slow effect countdown
	if _slow_timer > 0:
		_slow_timer -= delta
		if _slow_timer <= 0:
			_slow_timer = 0
			_apply_speed(false)
			_hud.hide_slow_indicator()

func start_with_mode(mode: String, challenge_type: String = "time") -> void:
	match mode:
		"classic":
			_game_mode = GameMode.CLASSIC
		"endless":
			_game_mode = GameMode.ENDLESS
		"challenge":
			_game_mode = GameMode.CHALLENGE
			_challenge_type = ChallengeType.STEP_LIMIT if challenge_type == "step" else ChallengeType.TIME_LIMIT
	_setup_game()

func _setup_game() -> void:
	_snake = $Snake
	_food_manager = $FoodManager
	_hud = $HUD
	_move_timer = $MoveTimer
	_input_handler = $InputHandler
	_particle_system = $ParticleSystem
	_audio_manager = $AudioManager
	
	# Phase 3: get or create camera for shake
	_camera = get_viewport().get_camera_2d()
	if _camera:
		_original_camera_offset = _camera.offset

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

	# Connect FoodManager signals
	var fm := _food_manager as Node2D
	if fm.has_method("food_eaten_by_type") and not fm.food_eaten_by_type.is_connected(_on_food_eaten_by_type):
		fm.food_eaten_by_type.connect(_on_food_eaten_by_type)
	
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
	_slow_timer = 0.0
	_hud.hide_game_over()
	_hud.hide_level_clear()
	_hud.hide_slow_indicator()
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

func _food_pool_size_for_level(level: int) -> int:
	# Classic: 3-5 simultaneous foods based on level
	return clampi(3 + level / 2, 3, 5)

func _speed_multiplier_for_level(level: int) -> float:
	return 1.0 + level * 0.1

func _spawn_food_for_level() -> void:
	_food_eaten_this_level = 0
	_food_target_this_level = _food_count_for_level(_level)
	
	var pool_size: int
	var replenish: bool
	
	match _game_mode:
		GameMode.CLASSIC:
			pool_size = _food_pool_size_for_level(_level)
			replenish = false  # stop replenishing when level target reached
		GameMode.ENDLESS:
			pool_size = 3
			replenish = true   # always keep 3 foods
		GameMode.CHALLENGE:
			pool_size = 4
			replenish = false  # stop at target
		_:
			pool_size = 3
			replenish = false
	
	_food_manager.initialize(pool_size, pool_size)
	_food_manager.set_occupied_cells(_occupied_cells)
	_food_manager.set_replenish_mode(replenish)
	_food_manager.spawn_initial_pool(pool_size, replenish)

func _update_occupied_cells() -> void:
	_occupied_cells = _snake.get_body_positions()

func _on_food_eaten_by_type(food_type: int, grid_pos: Vector2i) -> void:
	var ftype := food_type as int
	
	# Score
	var pts := _food_manager.get_points_for_type(ftype)
	_score += pts
	
	# Phase 3: slow effect for BLUE food
	if ftype == 2:  # FoodType.BLUE
		_activate_slow_effect()
	
	# Spawn eat particles at food position
	var food_world_pos := Vector2(grid_pos.x * CELL_SIZE + CELL_SIZE / 2,
								   grid_pos.y * CELL_SIZE + CELL_SIZE / 2) + GRID_OFFSET
	_particle_system.spawn_eat_effect(food_world_pos)
	
	# Play eat sound
	_audio_manager.play_eat()
	
	_snake.grow()
	_update_occupied_cells()
	_food_manager.set_occupied_cells(_occupied_cells)
	_update_hud()
	_set_move_interval()

	if _game_mode == GameMode.CLASSIC or _game_mode == GameMode.CHALLENGE:
		_food_eaten_this_level += 1
		if _food_eaten_this_level >= _food_target_this_level:
			_trigger_level_clear()
		else:
			_food_manager.spawn_one_food()
	else:
		# Endless: always replenish
		_food_manager.spawn_one_food()

func _activate_slow_effect() -> void:
	_slow_timer = SLOW_DURATION
	_apply_speed(true)
	_hud.show_slow_indicator(SLOW_DURATION)

func _apply_speed(slowed: bool) -> void:
	var length := int(_snake.get_body_positions().size())
	var base_interval := maxf(0.3 - length * 0.005, 0.05)
	var mult := _speed_multiplier_for_level(_level) if _game_mode == GameMode.CLASSIC else 1.0
	var interval := base_interval * (1.0 / mult)
	
	if slowed:
		interval *= 1.43  # 30% slower
	
	_base_move_interval = interval
	_move_timer.wait_time = interval

func _trigger_level_clear() -> void:
	_move_timer.stop()
	_hud.show_level_clear(_level)
	_audio_manager.play_level_clear()
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
	_food_manager.set_occupied_cells(_occupied_cells)

	# Check if head is on any food position
	var food_positions: Array[Vector2i] = _food_manager.get_active_positions()
	if new_head_pos in food_positions:
		# FoodManager handles the actual eat (via collision), but we need to
		# ensure the food at this position emits food_eaten.
		# The collision detection via Area2D should handle it automatically,
		# but we trigger it manually as a fallback.
		_trigger_food_at(new_head_pos)

	# Challenge step tracking
	if _game_mode == GameMode.CHALLENGE and _challenge_type == ChallengeType.STEP_LIMIT:
		_challenge_steps_remaining -= 1
		_hud.update_steps(_challenge_steps_remaining)
		if _challenge_steps_remaining <= 0:
			_trigger_game_over()

func _trigger_food_at(pos: Vector2i) -> void:
	# Find food at position and trigger eat
	var foods: Array = _food_manager.get_children()
	for f in foods:
		if is_instance_valid(f) and f.has_method("get_grid_position"):
			if f.call("get_grid_position") == pos:
				f.food_eaten.emit()
				break

func _trigger_game_over() -> void:
	_is_game_over = true
	_move_timer.stop()
	_challenge_timer.stop()
	if _score > _high_score:
		_high_score = _score
	_hud.show_game_over()
	if _game_mode == GameMode.ENDLESS:
		_hud.update_high_score(_high_score)
	
	# Phase 3: spawn death particles at snake head
	var head_pos: Vector2i = _snake.get_head_position()
	var head_world_pos := Vector2(head_pos.x * CELL_SIZE + CELL_SIZE / 2, head_pos.y * CELL_SIZE + CELL_SIZE / 2)
	_particle_system.spawn_death_effect(head_world_pos)
	
	# Phase 3: screen shake
	_trigger_screen_shake(4.0, 0.3)
	
	# Phase 3: play death sound
	_audio_manager.play_death()

func _trigger_screen_shake(intensity: float, duration: float) -> void:
	_shake_intensity = intensity
	_shake_duration = duration

func _process_shake() -> void:
	if _shake_duration > 0 and _camera:
		var shake_offset := Vector2(
			randf_range(-_shake_intensity, _shake_intensity),
			randf_range(-_shake_intensity, _shake_intensity)
		)
		_camera.offset = _original_camera_offset + shake_offset

func _reset_camera() -> void:
	if _camera:
		_camera.offset = _original_camera_offset

func _on_restart_requested() -> void:
	if _is_game_over:
		_reset_camera()
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
	# Food eaten / target
	var eaten := _food_eaten_this_level
	var target := _food_target_this_level
	_hud.update_food_count(eaten, target)

func _game_mode_name() -> String:
	match _game_mode:
		GameMode.CLASSIC:   return "CLASSIC"
		GameMode.ENDLESS:   return "ENDLESS"
		GameMode.CHALLENGE:
			if _challenge_type == ChallengeType.STEP_LIMIT:
				return "CHALLENGE-STEP"
			else:
				return "CHALLENGE-TIME"
	return ""

func _set_move_interval() -> void:
	var length := int(_snake.get_body_positions().size())
	var base_interval := maxf(0.3 - length * 0.005, 0.05)
	var mult := _speed_multiplier_for_level(_level) if _game_mode == GameMode.CLASSIC else 1.0
	var interval := base_interval * (1.0 / mult)
	
	if _slow_timer > 0:
		interval *= 1.43  # 30% slower
	
	_base_move_interval = interval
	_move_timer.wait_time = interval

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R and _is_game_over:
		_on_restart_requested()

func _draw() -> void:
	draw_rect(Rect2(GRID_OFFSET, Vector2(GRID_SIZE * CELL_SIZE, GRID_SIZE * CELL_SIZE)), BG_COLOR)
	for i in range(GRID_SIZE + 1):
		draw_line(Vector2(i * CELL_SIZE, 0) + GRID_OFFSET,
				  Vector2(i * CELL_SIZE, GRID_SIZE * CELL_SIZE) + GRID_OFFSET,
				  GRID_COLOR, 1.0)
		draw_line(Vector2(0, i * CELL_SIZE) + GRID_OFFSET,
				  Vector2(GRID_SIZE * CELL_SIZE, i * CELL_SIZE) + GRID_OFFSET,
				  GRID_COLOR, 1.0)
