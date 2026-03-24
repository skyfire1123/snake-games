extends Control

## Start screen with game mode selection

signal mode_selected(mode: String)

func _ready() -> void:
	$VBoxContainer/ClassicButton.pressed.connect(_on_classic_pressed)
	$VBoxContainer/EndlessButton.pressed.connect(_on_endless_pressed)
	$VBoxContainer/ChallengeButton.pressed.connect(_on_challenge_pressed)

func _on_classic_pressed() -> void:
	mode_selected.emit("classic")

func _on_endless_pressed() -> void:
	mode_selected.emit("endless")

func _on_challenge_pressed() -> void:
	mode_selected.emit("challenge")
