## 全局 DEBUG 日志系统
## 正式打包时把 DEBUG_MODE 设为 false 即可关闭所有 debug 输出

extends Node

const DEBUG_MODE := true  # 改成 false 即可关闭所有 debug 日志

const LOG_FILE := "user://debug.log"  # 日志写入文件

func _ready() -> void:
	if not DEBUG_MODE:
		return
	# 清空上次日志
	var f := FileAccess.open(LOG_FILE, FileAccess.WRITE)
	if f:
		f.store_string("")
		f.close()
	log("=== 游戏启动 ===")

func log(msg: String, category: String = "general") -> void:
	if not DEBUG_MODE:
		return
	var timestamp := Time.get_datetime_string_from_system()
	var line := "[%s] [%s] %s" % [timestamp, category, msg]
	print(line)
	var file := FileAccess.open(LOG_FILE, FileAccess.APPEND)
	if file:
		file.store_line(line)
		file.close()

func warn(msg: String) -> void:
	if not DEBUG_MODE:
		return
	log("⚠️ " + msg, "WARN")

func error(msg: String) -> void:
	if not DEBUG_MODE:
		return
	log("❌ " + msg, "ERROR")
