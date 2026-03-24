extends Control

## Theme selection screen with previews

signal theme_confirmed

const GRID_SIZE := 20
const CELL_SIZE := 32
const GRID_OFFSET := Vector2(0, 40)
const PREVIEW_SIZE := 80
const PREVIEW_CELLS := 5

var _theme_manager: Node
var _selected_index: int = 0
var _buttons: Array[Button] = []
var _previews: Array[Control] = []

func _ready() -> void:
	_theme_manager = get_node_or_null("/root/ThemeManager")
	if _theme_manager:
		_selected_index = _theme_manager.current_index
	_build_ui()
	$BackButton.pressed.connect(_on_back_pressed)

func _build_ui() -> void:
	var themes = _theme_manager.THEMES if _theme_manager else []
	var list: VBoxContainer = $ScrollContainer/ThemeList
	for i in range(themes.size()):
		var theme_data = themes[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)

		# Mini preview canvas
		var preview := ColorRect.new()
		preview.custom_minimum_size = Vector2(PREVIEW_SIZE, PREVIEW_SIZE)
		preview.color = theme_data["bg"]
		# Draw grid lines via a child Control with _draw
		var grid_overlay := _make_preview_overlay(theme_data["bg"], theme_data["grid"])
		preview.add_child(grid_overlay)
		_previews.append(preview)

		# Theme name button
		var btn := Button.new()
		btn.text = theme_data["name"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 18)
		var idx := i  # capture for closure
		btn.pressed.connect(func(): _select_theme(idx))
		_buttons.append(btn)

		row.add_child(preview)
		row.add_child(btn)
		list.add_child(row)

	_refresh_button_styles()

func _make_preview_overlay(bg: Color, grid: Color) -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Store colors as metadata so _draw can access them
	c.set_meta("bg", bg)
	c.set_meta("grid", grid)
	c.draw.connect(func(): _draw_preview(c))
	return c

func _draw_preview(c: Control) -> void:
	var bg: Color = c.get_meta("bg")
	var grid: Color = c.get_meta("grid")
	var sz := PREVIEW_SIZE
	c.draw_rect(Rect2(0, 0, sz, sz), bg)
	var step := sz / float(PREVIEW_CELLS)
	for i in range(PREVIEW_CELLS + 1):
		c.draw_line(Vector2(i * step, 0), Vector2(i * step, sz), grid, 1.0)
		c.draw_line(Vector2(0, i * step), Vector2(sz, i * step), grid, 1.0)

func _select_theme(index: int) -> void:
	_selected_index = index
	if _theme_manager:
		_theme_manager.set_theme(index)
	_refresh_button_styles()

func _refresh_button_styles() -> void:
	for i in range(_buttons.size()):
		var btn := _buttons[i]
		if i == _selected_index:
			btn.add_theme_color_override("font_color", Color("#00ff88"))
			btn.add_theme_color_override("font_hover_color", Color("#00ff88"))
		else:
			btn.remove_theme_color_override("font_color")
			btn.remove_theme_color_override("font_hover_color")

func _on_back_pressed() -> void:
	theme_confirmed.emit()
