extends CanvasLayer

## HUD — Phase 2: score, length, level, mode, high score, timer/steps

signal restart_requested

var _score_label: Label
var _length_label: Label
var _level_label: Label
var _mode_label: Label
var _high_score_label: Label
var _timer_label: Label
var _steps_label: Label
var _game_over_label: Label
var _restart_hint: Label
var _level_clear_label: Label

func _ready() -> void:
	var hbox := $VBoxContainer/HBoxContainer
	_score_label      = hbox.get_node_or_null("ScoreLabel")
	_length_label     = hbox.get_node_or_null("LengthLabel")
	_level_label      = hbox.get_node_or_null("LevelLabel")
	_mode_label       = hbox.get_node_or_null("ModeLabel")
	_high_score_label = hbox.get_node_or_null("HighScoreLabel")
	_timer_label      = hbox.get_node_or_null("TimerLabel")
	_steps_label      = hbox.get_node_or_null("StepsLabel")
	var vbox := $VBoxContainer
	_game_over_label  = vbox.get_node_or_null("GameOverLabel")
	_restart_hint     = vbox.get_node_or_null("RestartHint")
	_level_clear_label = vbox.get_node_or_null("LevelClearLabel")

	_set_visible(_game_over_label, false)
	_set_visible(_restart_hint, false)
	_set_visible(_level_clear_label, false)
	_set_visible(_high_score_label, false)
	_set_visible(_timer_label, false)
	_set_visible(_steps_label, false)

func _set_visible(node: Node, v: bool) -> void:
	if node:
		node.visible = v

func update_score(score: int) -> void:
	if _score_label:
		_score_label.text = "SCORE: %d" % score

func update_length(length: int) -> void:
	if _length_label:
		_length_label.text = "LENGTH: %d" % length

func update_level(level: int) -> void:
	if _level_label:
		_level_label.text = "LEVEL: %d" % level

func update_mode(mode: String) -> void:
	if _mode_label:
		_mode_label.text = "MODE: %s" % mode

func update_high_score(hs: int) -> void:
	if _high_score_label:
		_high_score_label.text = "BEST: %d" % hs
		_high_score_label.visible = true

func update_timer(seconds: float) -> void:
	if _timer_label:
		_timer_label.text = "TIME: %d" % int(ceil(seconds))
		_timer_label.visible = true

func update_steps(steps: int) -> void:
	if _steps_label:
		_steps_label.text = "STEPS: %d" % steps
		_steps_label.visible = true

func show_level_clear(level: int) -> void:
	if _level_clear_label:
		_level_clear_label.text = "LEVEL %d CLEAR!" % level
		_level_clear_label.visible = true

func hide_level_clear() -> void:
	_set_visible(_level_clear_label, false)

func show_game_over() -> void:
	_set_visible(_game_over_label, true)
	_set_visible(_restart_hint, true)

func hide_game_over() -> void:
	_set_visible(_game_over_label, false)
	_set_visible(_restart_hint, false)

# BUG-005 fix: removed dead _input(event) — restart is handled by restart_requested signal
