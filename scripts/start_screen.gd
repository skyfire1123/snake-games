extends Control

## Start screen with game mode selection + skin picker — Phase 4 Sprint 4

signal mode_selected(mode: String, challenge_type: String)
signal theme_requested

var _audio_manager: Node
var _skin_manager: Node

const SKIN_LABELS := {
	"neon_green": "Neon Green",
	"hot_pink":   "Hot Pink",
	"fire":       "Fire",
	"ice":        "Ice",
	"galaxy":     "Galaxy",
}

func _ready() -> void:
	$VBoxContainer/ClassicButton.pressed.connect(_on_classic_pressed)
	$VBoxContainer/EndlessButton.pressed.connect(_on_endless_pressed)
	$VBoxContainer/ChallengeButton.pressed.connect(_on_challenge_time_pressed)
	$VBoxContainer/ChallengeStepButton.pressed.connect(_on_challenge_step_pressed)
	$VBoxContainer/SkinRow/PrevSkinButton.pressed.connect(_on_prev_skin)
	$VBoxContainer/SkinRow/NextSkinButton.pressed.connect(_on_next_skin)
	$VBoxContainer/ThemeButton.pressed.connect(_on_theme_pressed)

	_audio_manager = get_parent().get_node_or_null("AudioManager")
	_skin_manager = get_parent().get_node_or_null("SkinManager")

	_refresh_skin_label()

func _play_click() -> void:
	if _audio_manager and is_instance_valid(_audio_manager):
		_audio_manager.play_click()

func _refresh_skin_label() -> void:
	if not _skin_manager:
		return
	var skin_name := _skin_manager.get_current_skin()
	$VBoxContainer/SkinRow/SkinLabel.text = SKIN_LABELS.get(skin_name, skin_name)

func _on_prev_skin() -> void:
	_play_click()
	if not _skin_manager:
		return
	var skins: Array = _skin_manager.get_skin_names()
	var idx: int = skins.find(_skin_manager.get_current_skin())
	idx = (idx - 1 + skins.size()) % skins.size()
	_skin_manager.set_skin(skins[idx])
	_refresh_skin_label()

func _on_next_skin() -> void:
	_play_click()
	if not _skin_manager:
		return
	var skins: Array = _skin_manager.get_skin_names()
	var idx: int = skins.find(_skin_manager.get_current_skin())
	idx = (idx + 1) % skins.size()
	_skin_manager.set_skin(skins[idx])
	_refresh_skin_label()

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
