extends Control

signal country_selected(id: String, country_name: String)
signal city_selected(city: Dictionary)

const DATA_PATH := "res://data/map/world_110m.json"
const OCEAN := Color("081b2d")
const LAND := Color("294859")
const BORDER := Color("70929c")
const SELECTED := Color("13a98f")
const CITY := Color("f1d39a")
var countries: Array = []
var cities: Array = []
var selected_id := ""
var selected_city_name := ""
var map_zoom := 1.0
var pan := Vector2.ZERO
var _pressed := false
var _dragged := false
var _last_mouse := Vector2.ZERO
var load_error := ""

func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(0, 450)
	load_error = load_map()
	queue_redraw()

func load_map() -> String:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return "World map data could not be opened."
	var data: Variant = JSON.parse_string(file.get_as_text())
	if not data is Dictionary or data.get("version") != 1 or not data.get("countries") is Array or not data.get("cities") is Array:
		return "World map data is invalid."
	var loaded: Array = []
	for country in data.countries:
		if not country is Dictionary or not country.get("id") is String or not country.get("name") is String or not country.get("polygons") is Array:
			return "A country record is invalid."
		var polygons: Array = []
		for polygon in country.polygons:
			var rings: Array = []
			for ring in polygon:
				var points := PackedVector2Array()
				for point in ring:
					points.append(_unit_point(point))
				# GeoJSON closes rings by repeating the first coordinate. Godot's
				# polygon triangulation expects the closing edge to be implicit.
				if points.size() > 3 and points[0] == points[points.size() - 1]:
					points.remove_at(points.size() - 1)
				if points.size() >= 3:
					rings.append(points)
			if not rings.is_empty():
				polygons.append(rings)
		loaded.append({"id": country.id, "name": country.name, "polygons": polygons})
	countries = loaded
	cities = data.cities.duplicate(true)
	return ""

static func _unit_point(point: Array) -> Vector2:
	return Vector2(float(point[0]) / 360.0, -float(point[1]) / 180.0)

func _map_width() -> float:
	return maxf(1.0, minf(size.x - 24.0, (size.y - 24.0) * 2.0))

func unit_to_screen(point: Vector2) -> Vector2:
	var width := _map_width() * map_zoom
	return size / 2.0 + pan + Vector2(point.x * width, point.y * width / 2.0)

func screen_to_unit(point: Vector2) -> Vector2:
	var width := _map_width() * map_zoom
	var relative := point - size / 2.0 - pan
	return Vector2(relative.x / width, relative.y / (width / 2.0))

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), OCEAN)
	if not load_error.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(18, 30), load_error, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
		return
	for country in countries:
		for polygon in country.polygons:
			var screen := PackedVector2Array()
			for point in polygon[0]:
				screen.append(unit_to_screen(point))
			if screen.size() >= 3:
				# Some tiny or simplified coastline rings become degenerate at the
				# current scale. Avoid submitting an untriangulatable fill.
				for fill in _renderable_polygons(screen):
					draw_colored_polygon(fill, SELECTED if country.id == selected_id else LAND)
				screen.append(screen[0])
				draw_polyline(screen, BORDER, 1.0, true)
	var labels: Array[Rect2] = []
	for city in cities:
		if not _city_visible(city):
			continue
		var location := unit_to_screen(_unit_point(city.point))
		if not Rect2(Vector2.ZERO, size).grow(-3).has_point(location):
			continue
		if city.name == selected_city_name:
			draw_circle(location, 7.0, SELECTED)
		draw_circle(location, 3.2 if city.capital else 2.4, CITY)
		if map_zoom < 1.7:
			continue
		var label_rect := Rect2(location + Vector2(6, -13), Vector2(ThemeDB.fallback_font.get_string_size(city.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 4, 16))
		var collision := false
		for existing in labels:
			if existing.intersects(label_rect):
				collision = true
				break
		if not collision:
			labels.append(label_rect)
			draw_string(ThemeDB.fallback_font, location + Vector2(6, 1), city.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("f5f3e9"))

static func _renderable_polygons(points: PackedVector2Array) -> Array:
	if not Geometry2D.triangulate_polygon(points).is_empty():
		return [points]
	# Some source rings self-touch. A union can repair those rings; retain the
	# original outline and hit-test geometry if no valid fill can be made.
	var result: Array = []
	for polygon in Geometry2D.merge_polygons(points, points):
		if not Geometry2D.triangulate_polygon(polygon).is_empty():
			result.append(polygon)
	return result

func _city_visible(city: Dictionary) -> bool:
	return city.major or (map_zoom >= 1.5 and city.capital) or map_zoom >= 3.0

func country_at(point: Vector2) -> Dictionary:
	var unit := screen_to_unit(point)
	for country in countries:
		for polygon in country.polygons:
			if not Geometry2D.is_point_in_polygon(unit, polygon[0]):
				continue
			var inside_hole := false
			for i in range(1, polygon.size()):
				if Geometry2D.is_point_in_polygon(unit, polygon[i]):
					inside_hole = true
					break
			if not inside_hole:
				return {"id": country.id, "name": country.name}
	return {}

func _city_at(point: Vector2) -> Dictionary:
	var nearest: Dictionary = {}
	var distance := 7.0
	for city in cities:
		if _city_visible(city):
			var candidate: float = unit_to_screen(_unit_point(city.point)).distance_to(point)
			if candidate <= distance:
				distance = candidate
				nearest = city
	return nearest.duplicate(true)

func select_at(point: Vector2) -> void:
	var city := _city_at(point)
	selected_city_name = city.get("name", "")
	var country := country_at(point)
	selected_id = country.get("id", "")
	if not country.is_empty():
		country_selected.emit(country.id, country.name)
	if not city.is_empty():
		city_selected.emit(city)
	queue_redraw()

func focus_city(city: Dictionary) -> void:
	selected_id = city.get("country", "")
	selected_city_name = city.name
	_focus_unit(_unit_point(city.point), 3.5)
	city_selected.emit(city.duplicate(true))

func focus_country(country: Dictionary) -> void:
	selected_id = country.id
	selected_city_name = ""
	var largest := Rect2()
	var largest_area := -1.0
	for polygon in country.polygons:
		var ring: PackedVector2Array = polygon[0]
		var bounds := Rect2(ring[0], Vector2.ZERO)
		for point in ring:
			bounds = bounds.expand(point)
		var area := bounds.size.x * bounds.size.y
		if area > largest_area:
			largest = bounds
			largest_area = area
	if largest_area >= 0.0:
		var width := _map_width()
		var zoom_x := size.x / maxf(1.0, largest.size.x * width * 1.5)
		var zoom_y := size.y / maxf(1.0, largest.size.y * width * 0.75)
		_focus_unit(largest.get_center(), clampf(minf(zoom_x, zoom_y), 1.0, 6.0))
	country_selected.emit(country.id, country.name)

func _focus_unit(point: Vector2, zoom: float) -> void:
	map_zoom = zoom
	var width := _map_width() * map_zoom
	pan = -Vector2(point.x * width, point.y * width / 2.0)
	_clamp_pan()
	queue_redraw()

func zoom_at(point: Vector2, factor: float) -> void:
	var before := screen_to_unit(point)
	map_zoom = clampf(map_zoom * factor, 1.0, 8.0)
	var width := _map_width() * map_zoom
	pan = point - size / 2.0 - Vector2(before.x * width, before.y * width / 2.0)
	_clamp_pan()
	queue_redraw()

func reset_view() -> void:
	map_zoom = 1.0
	pan = Vector2.ZERO
	queue_redraw()

func _clamp_pan() -> void:
	var width := _map_width() * map_zoom
	var limit := Vector2(maxf(0.0, (width - size.x) / 2.0 + 20.0), maxf(0.0, (width / 2.0 - size.y) / 2.0 + 20.0))
	pan = pan.clamp(-limit, limit)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_LEFT: pan.x += 40.0
			KEY_RIGHT: pan.x -= 40.0
			KEY_UP: pan.y += 40.0
			KEY_DOWN: pan.y -= 40.0
			KEY_PLUS, KEY_EQUAL: zoom_at(size / 2.0, 1.25)
			KEY_MINUS: zoom_at(size / 2.0, 0.8)
			KEY_HOME: reset_view()
			_: return
		_clamp_pan()
		queue_redraw()
		accept_event()
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			zoom_at(event.position, 1.25 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.8)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_pressed = true
				_dragged = false
				_last_mouse = event.position
			else:
				if _pressed and not _dragged:
					select_at(event.position)
				_pressed = false
	elif event is InputEventMouseMotion and _pressed:
		var delta: Vector2 = event.position - _last_mouse
		if delta.length() > 1.0:
			_dragged = true
		pan += delta
		_last_mouse = event.position
		_clamp_pan()
		queue_redraw()
