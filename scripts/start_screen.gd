extends Control

## Start screen with game mode selection — Phase 2: challenge sub-type selection + Phase 3: audio

signal mode_selected(mode: String, challenge_type: String)

# Phase 3: audio manager reference (set by main.gd or parent)
var _audio_manager: Node

func _ready() -> void:
	$VBoxContainer/ClassicButton.pressed.connect(_on_classic_pressed)
	$VBoxContainer/EndlessButton.pressed.connect(_on_endless_pressed)
	$VBoxContainer/ChallengeButton.pressed.connect(_on_challenge_time_pressed)
	$VBoxContainer/ChallengeStepButton.pressed.connect(_on_challenge_step_pressed)
	
	# Try to get audio manager from parent
	_audio_manager = get_parent().get_node_or_null("AudioManager")

func _play_click() -> void:
	if _audio_manager and is_instance_valid(_audio_manager):
		_audio_manager.play_click()

func _on_classic_pressed() -> void:
	_play_click()
	mode_selected.emit("classic", "time")

func _on_endless_pressed() -> void:
	_play_click()
	mode_selected.emit("endless", "time")

func _on_challenge_time_pressed() -> void:
	_play_click()
	mode_selected.emit("challenge", "time")

func _on_challenge_step_pressed() -> void:
	_play_click()
	mode_selected.emit("challenge", "step")
