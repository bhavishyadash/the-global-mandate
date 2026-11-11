extends Control

signal country_selected(id: String, country_name: String)
signal city_selected(city: Dictionary)
signal selection_cleared
signal hover_changed(text: String)
signal zoom_changed(value: float)

const DATA_PATH := "res://data/map/world_110m.json"
const OCEAN := Color("081b2d")
const LAND := Color("294859")
const BORDER := Color("70929c")
const SELECTED := Color("13a98f")
const HOVER := Color("477a82")
const CITY := Color("f1d39a")
const AVAILABLE := Color("b68b48")
const ACTIVE := Color("158c79")
var countries: Array = []
var cities: Array = []
var selected_id := ""
var selected_city_name := ""
var hovered_id := ""
var hovered_city_name := ""
var city_mode := 0 # 0: major + capitals by zoom; 1: capitals; 2: all; 3: hidden
var layer_mode := 0 # 0: geography; 1: scenario availability
var available_ids: Array = []
var active_id := ""
var map_zoom := 1.0
var pan := Vector2.ZERO
var _pressed := false
var _dragged := false
var _last_mouse := Vector2.ZERO
var _press_origin := Vector2.ZERO
var load_error := ""

func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(0, 360)
	mouse_exited.connect(_clear_hover)
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
		var bounds: Array = []
		var fills: Array = []
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
				var ring_bounds := Rect2(rings[0][0], Vector2.ZERO)
				for point in rings[0]:
					ring_bounds = ring_bounds.expand(point)
				bounds.append(ring_bounds)
				fills.append(_renderable_polygons(rings[0]))
		loaded.append({"id": country.id, "name": country.name, "polygons": polygons, "bounds": bounds, "fills": fills})
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
	# Subtle geographic graticule and frame make the flat map readable at zoom.
	var grid := Color(0.25, 0.50, 0.56, 0.16)
	for longitude in range(-180, 181, 30):
		draw_line(unit_to_screen(Vector2(longitude / 360.0, -0.5)), unit_to_screen(Vector2(longitude / 360.0, 0.5)), grid, 1.0)
	for latitude in range(-60, 61, 30):
		draw_line(unit_to_screen(Vector2(-0.5, latitude / 180.0)), unit_to_screen(Vector2(0.5, latitude / 180.0)), grid, 1.0)
	for country in countries:
		for i in range(country.polygons.size()):
			var polygon: Array = country.polygons[i]
			var unit_bounds: Rect2 = country.bounds[i]
			var screen_bounds := Rect2(unit_to_screen(unit_bounds.position), unit_bounds.size * Vector2(_map_width() * map_zoom, _map_width() * map_zoom / 2.0))
			if not screen_bounds.grow(2.0).intersects(Rect2(Vector2.ZERO, size)):
				continue
			var screen := PackedVector2Array()
			for point in polygon[0]:
				screen.append(unit_to_screen(point))
			if screen.size() >= 3:
				for fill in country.fills[i]:
					var projected := PackedVector2Array()
					for point in fill:
						projected.append(unit_to_screen(point))
					# Projection and pixel precision can collapse tiny rings.
					if not Geometry2D.triangulate_polygon(projected).is_empty():
						draw_colored_polygon(projected, country_fill_color(country.id))
				screen.append(screen[0])
				draw_polyline(screen, Color("a9ebdf") if country.id == selected_id else BORDER, 1.6 if country.id == selected_id else 1.0, true)
	var labels: Array[Rect2] = []
	for city in cities:
		if not _city_visible(city):
			continue
		var location := unit_to_screen(_unit_point(city.point))
		if not Rect2(Vector2.ZERO, size).grow(-3).has_point(location):
			continue
		if city.name == selected_city_name:
			draw_circle(location, 7.0, SELECTED)
		elif city.name == hovered_city_name:
			draw_circle(location, 6.0, Color("f2dfb8"))
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

func set_scenario_layer(mode: int, available: Array, active: String) -> void:
	if mode not in [0, 1]:
		return
	if layer_mode == mode and available_ids == available and active_id == active:
		return
	layer_mode = mode
	available_ids = available.duplicate()
	active_id = active if active in available_ids else ""
	queue_redraw()

func country_fill_color(id: String) -> Color:
	if layer_mode == 1:
		var base := ACTIVE if id == active_id else (AVAILABLE if id in available_ids else LAND)
		return base.lightened(0.14) if id == hovered_id else base
	return SELECTED if id == selected_id else (HOVER if id == hovered_id else LAND)

func _city_visible(city: Dictionary) -> bool:
	match city_mode:
		1: return city.capital
		2: return true
		3: return false
	return city.major or (map_zoom >= 1.5 and city.capital) or map_zoom >= 3.0

func set_city_mode(mode: int) -> void:
	if mode < 0 or mode > 3:
		return
	city_mode = mode
	_clear_hover()
	queue_redraw()

func country_at(point: Vector2) -> Dictionary:
	var unit := screen_to_unit(point)
	for country in countries:
		for index in range(country.polygons.size()):
			var polygon: Array = country.polygons[index]
			if not country.bounds[index].grow(0.00001).has_point(unit):
				continue
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
	var distance := 9.0
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
	selected_id = city.get("country", "") if not city.is_empty() else country.get("id", "")
	if not country.is_empty():
		country_selected.emit(country.id, country.name)
	if not city.is_empty():
		city_selected.emit(city)
	elif country.is_empty():
		selection_cleared.emit()
	queue_redraw()

func clear_selection() -> void:
	selected_id = ""
	selected_city_name = ""
	selection_cleared.emit()
	queue_redraw()

func focus_selection() -> void:
	if not selected_city_name.is_empty():
		for city in cities:
			if city.name == selected_city_name and city.country == selected_id:
				focus_city(city)
				return
	for country in countries:
		if country.id == selected_id:
			focus_country(country)
			return

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
	zoom_changed.emit(map_zoom)

func zoom_at(point: Vector2, factor: float) -> void:
	var before := screen_to_unit(point)
	map_zoom = clampf(map_zoom * factor, 1.0, 8.0)
	var width := _map_width() * map_zoom
	pan = point - size / 2.0 - Vector2(before.x * width, before.y * width / 2.0)
	_clamp_pan()
	queue_redraw()
	zoom_changed.emit(map_zoom)

func reset_view() -> void:
	map_zoom = 1.0
	pan = Vector2.ZERO
	queue_redraw()
	zoom_changed.emit(map_zoom)

func _clear_hover() -> void:
	if hovered_id.is_empty() and hovered_city_name.is_empty():
		return
	hovered_id = ""
	hovered_city_name = ""
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	hover_changed.emit("")
	queue_redraw()

func _update_hover(point: Vector2) -> void:
	var city := _city_at(point)
	var country := country_at(point)
	var next_id: String = city.get("country", "") if not city.is_empty() else country.get("id", "")
	var next_city: String = city.get("name", "")
	if next_id == hovered_id and next_city == hovered_city_name:
		return
	hovered_id = next_id
	hovered_city_name = next_city
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not next_id.is_empty() or not next_city.is_empty() else Control.CURSOR_ARROW
	hover_changed.emit("City: " + next_city if not next_city.is_empty() else ("Country: " + country.name if not country.is_empty() else ""))
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
				grab_focus()
				if event.double_click:
					_pressed = false
					select_at(event.position)
					focus_selection()
					accept_event()
					return
				_pressed = true
				_dragged = false
				_last_mouse = event.position
				_press_origin = event.position
			else:
				if _pressed and not _dragged:
					select_at(event.position)
				_pressed = false
	elif event is InputEventMouseMotion:
		if _pressed:
			var delta: Vector2 = event.position - _last_mouse
			if not _dragged and event.position.distance_to(_press_origin) >= 7.0:
				_dragged = true
				delta = event.position - _press_origin
			if _dragged:
				pan += delta
				_clamp_pan()
				queue_redraw()
			_last_mouse = event.position
		else:
			_update_hover(event.position)
