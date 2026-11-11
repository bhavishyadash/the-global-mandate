extends Control

const COLORS := [Color("35cfaa"), Color("5da5d9"), Color("d7b760"), Color("aa8bd2"), Color("7898ae"), Color("e48c74"), Color("b2c3cc")]
var values: Dictionary = {}
var total := 0.0
var caption := "Current"

func _init() -> void:
	custom_minimum_size = Vector2(250, 250)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_data(items: Dictionary, total_amount: float, label: String) -> void:
	values = items.duplicate()
	total = total_amount
	caption = label
	queue_redraw()

func _draw() -> void:
	var center := size / 2.0
	var radius := minf(size.x, size.y) / 2.0 - 28.0
	var start := -PI / 2.0
	var index := 0
	if total > 0.0:
		for category in values:
			var fraction := float(values[category]) / total
			if fraction > 0.0:
				var finish := start + TAU * fraction
				draw_arc(center, radius, start, finish, maxi(4, ceili(fraction * 120.0)), COLORS[index % COLORS.size()], 30.0, true)
				start = finish
			index += 1
	else:
		draw_arc(center, radius, 0.0, TAU, 80, Color("426779"), 30.0, true)
	var line := "$%.1fM" % (total / 1000000.0)
	var font := ThemeDB.fallback_font
	var size_line := font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
	var size_caption := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
	draw_string(font, center + Vector2(-size_line.x / 2.0, 2.0), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("edf4f5"))
	draw_string(font, center + Vector2(-size_caption.x / 2.0, 25.0), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b7cad0"))
