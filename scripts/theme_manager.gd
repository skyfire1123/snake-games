extends Node

## ThemeManager — singleton for game color themes
## Persists selected theme via user://theme_settings.cfg

const SAVE_PATH := "user://theme_settings.cfg"

const THEMES := [
	{
		"name": "Neon Night",
		"bg": Color("#1a1a2e"),
		"grid": Color("#16213e"),
	},
	{
		"name": "Space",
		"bg": Color("#0a0a1a"),
		"grid": Color("#1a1a3a"),
	},
	{
		"name": "Forest",
		"bg": Color("#0a1a0a"),
		"grid": Color("#1a2a1a"),
	},
	{
		"name": "Ocean",
		"bg": Color("#0a1a2a"),
		"grid": Color("#1a2a3a"),
	},
	{
		"name": "Desert",
		"bg": Color("#2a1a0a"),
		"grid": Color("#3a2a1a"),
	},
]

var current_index: int = 0

func _ready() -> void:
	_load()

func get_bg_color() -> Color:
	return THEMES[current_index]["bg"]

func get_grid_color() -> Color:
	return THEMES[current_index]["grid"]

func get_theme_name() -> String:
	return THEMES[current_index]["name"]

func set_theme(index: int) -> void:
	current_index = clampi(index, 0, THEMES.size() - 1)
	_save()

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("theme", "index", current_index)
	cfg.save(SAVE_PATH)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		current_index = clampi(cfg.get_value("theme", "index", 0), 0, THEMES.size() - 1)
