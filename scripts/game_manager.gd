extends Node

## Entry point — loads start screen, then transitions to main game with chosen mode

var _main_scene: PackedScene
var _start_screen: Node
var _skin_manager: Node
var _theme_screen_scene: PackedScene

func _ready() -> void:
	# Create SkinManager as a persistent child (survives scene transitions)
	var sm_script := preload("res://scripts/skin_manager.gd")
	_skin_manager = Node.new()
	_skin_manager.name = "SkinManager"
	_skin_manager.set_script(sm_script)
	add_child(_skin_manager)

	_main_scene = preload("res://scenes/main.tscn")
	if _main_scene == null:
		push_error("[GM] FATAL: Failed to preload main.tscn!")
	_theme_screen_scene = preload("res://scenes/theme_screen.tscn")
	if _theme_screen_scene == null:
		push_error("[GM] FATAL: Failed to preload theme_screen.tscn!")
	_show_start_screen()

func _show_start_screen() -> void:
	var ss_scene: PackedScene = preload("res://scenes/start_screen.tscn")
	_start_screen = ss_scene.instantiate()
	add_child(_start_screen)
	_start_screen.mode_selected.connect(_on_mode_selected)
	_start_screen.theme_requested.connect(_on_theme_requested)

## BUG FIX: _on_mode_selected 和 _on_theme_requested 中的 queue_free()
## 现在使用实例变量 self._start_screen 正确引用节点

func _on_theme_requested() -> void:
	_start_screen.queue_free()
	var ts: Node = _theme_screen_scene.instantiate()
	add_child(ts)
	ts.theme_confirmed.connect(func():
		ts.queue_free()
		_show_start_screen()
	)

func _on_mode_selected(mode: String, challenge_type: String = "time") -> void:
	if _main_scene == null:
		push_error("[GM] ERROR: _main_scene is null! Preload failed.")
		_main_scene = preload("res://scenes/main.tscn")
		push_error("[GM] Retry preload result: ", _main_scene)
		if _main_scene == null:
			return
	var main: Node2D = _main_scene.instantiate()
	add_child(main)
	# Apply selected skin to snake before game starts
	var snake: Node2D = main.get_node_or_null("Snake")
	if snake and _skin_manager:
		_skin_manager.apply_skin_to_snake(snake)
	_start_screen.queue_free()
	main.start_with_mode(mode, challenge_type)

