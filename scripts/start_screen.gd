extends Control

## Start screen with game mode selection — Phase 2: challenge sub-type selection

signal mode_selected(mode: String, challenge_type: String)

func _ready() -> void:
	$VBoxContainer/ClassicButton.pressed.connect(_on_classic_pressed)
	$VBoxContainer/EndlessButton.pressed.connect(_on_endless_pressed)
	$VBoxContainer/ChallengeButton.pressed.connect(_on_challenge_time_pressed)
	$VBoxContainer/ChallengeStepButton.pressed.connect(_on_challenge_step_pressed)

func _on_classic_pressed() -> void:
	mode_selected.emit("classic", "time")

func _on_endless_pressed() -> void:
	mode_selected.emit("endless", "time")

func _on_challenge_time_pressed() -> void:
	mode_selected.emit("challenge", "time")

func _on_challenge_step_pressed() -> void:
	mode_selected.emit("challenge", "step")
