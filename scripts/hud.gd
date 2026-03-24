extends CanvasLayer

## HUD displaying score and length

signal restart_requested

var _score_label: Label
var _length_label: Label
var _game_over_label: Label
var _restart_hint: Label

func _ready() -> void:
	var vbox := $VBoxContainer
	_score_label = vbox.get_node_or_null("ScoreLabel")
	_length_label = vbox.get_node_or_null("LengthLabel")
	_game_over_label = vbox.get_node_or_null("GameOverLabel")
	_restart_hint = vbox.get_node_or_null("RestartHint")
	
	if _game_over_label:
		_game_over_label.visible = false
	if _restart_hint:
		_restart_hint.visible = false

func update_score(score: int) -> void:
	if _score_label:
		_score_label.text = "SCORE: %d" % score

func update_length(length: int) -> void:
	if _length_label:
		_length_label.text = "LENGTH: %d" % length

func show_game_over() -> void:
	if _game_over_label:
		_game_over_label.visible = true
	if _restart_hint:
		_restart_hint.visible = true

func hide_game_over() -> void:
	if _game_over_label:
		_game_over_label.visible = false
	if _restart_hint:
		_restart_hint.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		restart_requested.emit()
