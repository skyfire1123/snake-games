extends Node

## Entry point — loads start screen, then transitions to main game with chosen mode

var _main_scene: PackedScene
var _start_screen: Node

func _ready() -> void:
	_main_scene = preload("res://scenes/main.tscn")
	var ss_scene: PackedScene = preload("res://scenes/start_screen.tscn")
	_start_screen = ss_scene.instantiate()
	add_child(_start_screen)
	_start_screen.mode_selected.connect(_on_mode_selected)

func _on_mode_selected(mode: String, challenge_type: String = "time") -> void:
	_start_screen.queue_free()
	var main: Node2D = _main_scene.instantiate()
	add_child(main)
	main.start_with_mode(mode, challenge_type)
