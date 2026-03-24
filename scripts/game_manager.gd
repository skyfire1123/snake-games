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
	_theme_screen_scene = preload("res://scenes/theme_screen.tscn")
	_show_start_screen()

func _show_start_screen() -> void:
	var ss_scene: PackedScene = preload("res://scenes/start_screen.tscn")
	_start_screen = ss_scene.instantiate()
	add_child(_start_screen)
	_start_screen.mode_selected.connect(_on_mode_selected)
	_start_screen.theme_requested.connect(_on_theme_requested)

func _on_theme_requested() -> void:
	_start_screen.queue_free()
	var ts: Node = _theme_screen_scene.instantiate()
	add_child(ts)
	ts.theme_confirmed.connect(func():
		ts.queue_free()
		_show_start_screen()
	)

func _on_mode_selected(mode: String, challenge_type: String = "time") -> void:
	_start_screen.queue_free()
	var main: Node2D = _main_scene.instantiate()
	add_child(main)
	# Apply selected skin to snake before game starts
	var snake: Node2D = main.get_node_or_null("Snake")
	if snake and _skin_manager:
		snake.apply_skin(_skin_manager.get_current_textures())
	main.start_with_mode(mode, challenge_type)

