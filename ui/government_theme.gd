extends RefCounted

const BACKGROUND := Color("071827")
const PANEL := Color("10283b")
const SURFACE := Color("18374b")
const BORDER := Color("426779")
const TEXT := Color("edf4f5")
const MUTED := Color("b7cad0")
const ACCENT := Color("37d3b0")

static func _box(fill: Color, border: Color = BORDER, radius: int = 5) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

static func create() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = 16
	theme.set_color("font_color", "Label", TEXT)
	for type in ["Button", "OptionButton"]:
		for state in ["normal", "hover", "pressed", "disabled"]:
			var fill := SURFACE
			if state == "hover":
				fill = Color("245166")
			elif state == "pressed":
				fill = Color("12695e")
			elif state == "disabled":
				fill = Color("1b303b")
			theme.set_stylebox(state, type, _box(fill))
		for item in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			theme.set_color(item, type, TEXT)
		theme.set_color("font_disabled_color", type, MUTED.darkened(0.25))
	var focus := _box(Color(0, 0, 0, 0), ACCENT)
	focus.draw_center = false
	focus.set_border_width_all(2)
	theme.set_stylebox("focus", "Button", focus)
	theme.set_stylebox("focus", "LineEdit", focus)
	for type in ["LineEdit", "TextEdit"]:
		theme.set_stylebox("normal", type, _box(Color("0a2233")))
		theme.set_color("font_color", type, TEXT)
		theme.set_color("font_placeholder_color", type, MUTED)
	theme.set_stylebox("panel", "ItemList", _box(Color("0a2233")))
	theme.set_stylebox("selected", "ItemList", _box(Color("15594f"), ACCENT))
	theme.set_color("font_color", "ItemList", TEXT)
	theme.set_color("font_selected_color", "ItemList", TEXT)
	theme.set_stylebox("panel", "TabContainer", _box(PANEL, BORDER, 2))
	theme.set_stylebox("tab_unselected", "TabContainer", _box(Color("10283b"), BORDER, 2))
	theme.set_stylebox("tab_hovered", "TabContainer", _box(Color("234b5b"), ACCENT, 2))
	theme.set_stylebox("tab_selected", "TabContainer", _box(Color("12695e"), ACCENT, 2))
	theme.set_color("font_selected_color", "TabContainer", TEXT)
	theme.set_color("font_unselected_color", "TabContainer", MUTED)
	theme.set_color("font_hovered_color", "TabContainer", TEXT)
	return theme
