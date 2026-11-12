extends Control

const LINE := Color("37d3b0")
const GRID := Color("426779")
var samples: Array = []
var metric := "approval"

func _ready() -> void:
	custom_minimum_size = Vector2(0, 140)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_series(data: Array, field: String) -> void:
	samples = data.duplicate(true)
	metric = field
	queue_redraw()

func _draw() -> void:
	var plot := Rect2(Vector2(8, 8), size - Vector2(16, 16))
	if plot.size.x <= 0.0 or plot.size.y <= 0.0:
		return
	for i in range(3):
		var y := plot.position.y + plot.size.y * i / 2.0
		draw_line(Vector2(plot.position.x, y), Vector2(plot.end.x, y), GRID, 1.0)
	if samples.is_empty():
		return
	var low := INF
	var high := -INF
	for sample in samples:
		var value := float(sample[metric])
		low = minf(low, value)
		high = maxf(high, value)
	var scale := maxf(1.0, maxf(absf(low), absf(high)))
	low /= scale
	high /= scale
	var span := high - low
	var points := PackedVector2Array()
	for i in range(samples.size()):
		var x := plot.position.x + (plot.size.x * i / float(samples.size() - 1) if samples.size() > 1 else plot.size.x / 2.0)
		var fraction := (float(samples[i][metric]) / scale - low) / span if span > 0.000001 else 0.5
		points.append(Vector2(x, plot.end.y - fraction * plot.size.y))
	if points.size() > 1:
		draw_polyline(points, LINE, 2.0, true)
	for point in points:
		draw_circle(point, 2.5, LINE)
