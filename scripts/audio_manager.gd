extends Node

## Audio manager — Phase 3: placeholder sounds for eat, death, level clear, click

# TODO: Replace placeholder audio with actual sound files when available
# Placeholder files are silent/empty .wav files

var _eat_stream: AudioStream
var _death_stream: AudioStream
var _level_clear_stream: AudioStream
var _click_stream: AudioStream

var _eat_player: AudioStreamPlayer
var _death_player: AudioStreamPlayer
var _level_clear_player: AudioStreamPlayer
var _click_player: AudioStreamPlayer

func _ready() -> void:
	_eat_player = AudioStreamPlayer.new()
	_death_player = AudioStreamPlayer.new()
	_level_clear_player = AudioStreamPlayer.new()
	_click_player = AudioStreamPlayer.new()
	
	add_child(_eat_player)
	add_child(_death_player)
	add_child(_level_clear_player)
	add_child(_click_player)
	
	# TODO: Load actual audio files here
	# _eat_stream = preload("res://assets/audio/eat.wav")
	# _death_stream = preload("res://assets/audio/death.wav")
	# _level_clear_stream = preload("res://assets/audio/level_clear.wav")
	# _click_stream = preload("res://assets/audio/click.wav")

func play_eat() -> void:
	# TODO: _eat_player.stream = _eat_stream
	_eat_player.play()

func play_death() -> void:
	# TODO: _death_player.stream = _death_stream
	_death_player.play()

func play_level_clear() -> void:
	# TODO: _level_clear_player.stream = _level_clear_stream
	_level_clear_player.play()

func play_click() -> void:
	# TODO: _click_player.stream = _click_stream
	_click_player.play()
