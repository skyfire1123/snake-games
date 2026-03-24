## 全局 DEBUG 日志系统
## 正式打包时把 DEBUG_MODE 设为 false 即可关闭所有 debug 输出

extends Node

const DEBUG_MODE := true  # 改成 false 即可关闭所有 debug 日志

const LOG_FILE := "user://debug.log"  # 日志写入文件

func _ready() -> void:
	if not DEBUG_MODE:
		return
	# 清空上次日志
	var f := FileAccess.open(LOG_FILE, FileAccess.WRITE_READ)
	if f:
		f.store_string("")
		f.close()

func log_msg(msg: String, category: String = "general") -> void:
	if not DEBUG_MODE:
		return
	var timestamp := Time.get_datetime_string_from_system()
	var line := "[%s] [%s] %s" % [timestamp, category, msg]
	print(line)
	# 写入文件（追加模式用 READ_WRITE + seek_end）
	var f := FileAccess.open(LOG_FILE, FileAccess.READ_WRITE)
	if f:
		f.seek_end()
		f.store_line(line)
		f.close()

func warn_msg(msg: String, category: String = "WARN") -> void:
	if not DEBUG_MODE:
		return
	log_msg("⚠️ " + msg, category)

func error_msg(msg: String, category: String = "ERROR") -> void:
	if not DEBUG_MODE:
		return
	log_msg("❌ " + msg, category)
