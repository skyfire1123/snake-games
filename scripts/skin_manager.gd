extends Node

## SkinManager — loads and caches skin textures, persists player choice and unlock state

const SKINS := ["neon_green", "hot_pink", "fire", "ice", "galaxy"]
const DEFAULT_SKIN := "neon_green"
const SAVE_PATH := "user://settings.cfg"
const SKIN_SECTION := "skin"
const STATS_SECTION := "stats"

const TEXTURE_KEYS := [
	"snake_head_up", "snake_head_down", "snake_head_left", "snake_head_right",
	"snake_body_vertical", "snake_body_horizontal",
	"snake_body_up_left", "snake_body_up_right",
	"snake_body_down_left", "snake_body_down_right",
	"snake_tail_up", "snake_tail_down", "snake_tail_left", "snake_tail_right",
]

# Unlock conditions
const UNLOCK_HOT_PINK_SCORE := 500     # 任意模式分数达到500
const UNLOCK_FIRE_LEVEL_CLEAR := 1     # 通关任意关卡1次
const UNLOCK_ICE_LENGTH := 20          # 任意模式长度达到20
const UNLOCK_GALAXY_FOOD := 100         # 累计吃100个食物

var _current_skin: String = DEFAULT_SKIN
var _cache: Dictionary = {}  # skin_name -> { key -> Texture2D }

# BUG-P4-003: Unlock tracking stats
var _total_score := 0
var _total_level_cleared := 0
var _max_length := 0
var _total_food_eaten := 0

func _ready() -> void:
	_load_all()

func get_skin_names() -> Array:
	return SKINS

func get_current_skin() -> String:
	return _current_skin

func set_skin(skin_name: String) -> void:
	if skin_name in SKINS and is_skin_unlocked(skin_name):
		_current_skin = skin_name
		_save_setting()

## BUG-P4-003: Unlock condition check
func is_skin_unlocked(skin_name: String) -> bool:
	match skin_name:
		"neon_green":  return true  # Always unlocked
		"hot_pink":    return _total_score >= UNLOCK_HOT_PINK_SCORE
		"fire":        return _total_level_cleared >= UNLOCK_FIRE_LEVEL_CLEAR
		"ice":         return _max_length >= UNLOCK_ICE_LENGTH
		"galaxy":      return _total_food_eaten >= UNLOCK_GALAXY_FOOD
	return false

## BUG-P4-003: Get unlock condition description for UI
func get_unlock_hint(skin_name: String) -> String:
	match skin_name:
		"neon_green":  return "默认解锁"
		"hot_pink":    return "任意模式分数达到 %d" % UNLOCK_HOT_PINK_SCORE
		"fire":        return "通关任意关卡 %d 次" % UNLOCK_FIRE_LEVEL_CLEAR
		"ice":         return "任意模式长度达到 %d" % UNLOCK_ICE_LENGTH
		"galaxy":      return "累计吃 %d 个食物" % UNLOCK_GALAXY_FOOD
	return ""

## BUG-P4-003: Progress toward unlock (0.0 to 1.0)
func get_unlock_progress(skin_name: String) -> float:
	match skin_name:
		"neon_green":  return 1.0
		"hot_pink":    return clampf(float(_total_score) / UNLOCK_HOT_PINK_SCORE, 0.0, 1.0)
		"fire":        return clampf(float(_total_level_cleared) / UNLOCK_FIRE_LEVEL_CLEAR, 0.0, 1.0)
		"ice":         return clampf(float(_max_length) / UNLOCK_ICE_LENGTH, 0.0, 1.0)
		"galaxy":      return clampf(float(_total_food_eaten) / UNLOCK_GALAXY_FOOD, 0.0, 1.0)
	return 0.0

## BUG-P4-003: Notify skin manager of game events
func notify_score_changed(score: int) -> void:
	if score > _total_score:
		_total_score = score
		_save_stats()

func notify_length_changed(length: int) -> void:
	if length > _max_length:
		_max_length = length
		_save_stats()

func notify_level_cleared() -> void:
	_total_level_cleared += 1
	_save_stats()

func notify_food_eaten() -> void:
	_total_food_eaten += 1
	_save_stats()

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

func apply_skin_to_snake(snake: Node) -> void:
	if snake == null or not is_instance_valid(snake):
		return
	var textures := get_current_textures()
	if textures.is_empty():
		return
	if snake.has_method("apply_skin"):
		(snake as Node).call("apply_skin", textures)

func _save_setting() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SKIN_SECTION, "selected", _current_skin)
	cfg.save(SAVE_PATH)

func _load_all() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		_current_skin = cfg.get_value(SKIN_SECTION, "selected", DEFAULT_SKIN)
		if not _current_skin in SKINS:
			_current_skin = DEFAULT_SKIN
		_total_score = cfg.get_value(STATS_SECTION, "total_score", 0)
		_total_level_cleared = cfg.get_value(STATS_SECTION, "total_level_cleared", 0)
		_max_length = cfg.get_value(STATS_SECTION, "max_length", 0)
		_total_food_eaten = cfg.get_value(STATS_SECTION, "total_food_eaten", 0)

func _save_stats() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK or FileAccess.file_exists(SAVE_PATH):
		pass
	cfg.set_value(SKIN_SECTION, "selected", _current_skin)
	cfg.set_value(STATS_SECTION, "total_score", _total_score)
	cfg.set_value(STATS_SECTION, "total_level_cleared", _total_level_cleared)
	cfg.set_value(STATS_SECTION, "max_length", _max_length)
	cfg.set_value(STATS_SECTION, "total_food_eaten", _total_food_eaten)
	cfg.save(SAVE_PATH)
