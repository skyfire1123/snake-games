extends Node

## SkinManager — loads and caches skin textures, persists player choice via ConfigFile

const SKINS := ["neon_green", "hot_pink", "fire", "ice", "galaxy"]
const DEFAULT_SKIN := "neon_green"
const SAVE_PATH := "user://settings.cfg"
const SECTION := "skin"

const TEXTURE_KEYS := [
	"snake_head_up", "snake_head_down", "snake_head_left", "snake_head_right",
	"snake_body_vertical", "snake_body_horizontal",
	"snake_body_up_left", "snake_body_up_right",
	"snake_body_down_left", "snake_body_down_right",
	"snake_tail_up", "snake_tail_down", "snake_tail_left", "snake_tail_right",
]

var _current_skin: String = DEFAULT_SKIN
var _cache: Dictionary = {}  # skin_name -> { key -> Texture2D }

func _ready() -> void:
	_load_setting()

func get_skin_names() -> Array:
	return SKINS

func get_current_skin() -> String:
	return _current_skin

func set_skin(skin_name: String) -> void:
	if skin_name in SKINS:
		_current_skin = skin_name
		_save_setting()

func get_textures(skin_name: String) -> Dictionary:
	if skin_name in _cache:
		return _cache[skin_name]
	var textures: Dictionary = {}
	var base := "res://assets/sprites/skins/" + skin_name + "/"
	for key in TEXTURE_KEYS:
		var path := base + key + ".png"
		if ResourceLoader.exists(path):
			textures[key] = load(path)
	_cache[skin_name] = textures
	return textures

func get_current_textures() -> Dictionary:
	return get_textures(_current_skin)

func _save_setting() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SECTION, "selected", _current_skin)
	cfg.save(SAVE_PATH)

func _load_setting() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		_current_skin = cfg.get_value(SECTION, "selected", DEFAULT_SKIN)
		if not _current_skin in SKINS:
			_current_skin = DEFAULT_SKIN
