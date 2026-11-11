extends RefCounted

const PATH := "res://data/map/scenario_bindings.json"

static func read() -> Variant:
	var file := FileAccess.open(PATH, FileAccess.READ)
	return JSON.parse_string(file.get_as_text()) if file != null else null

# Validate the entire registry before using any binding. No country is ever
# associated with a scenario based on a partial or invalid catalog.
static func validate(data: Variant, countries: Array, scenarios: Array) -> String:
	if not data is Dictionary or data.size() != 2 or data.get("version") != 1 or not data.get("bindings") is Array or data.bindings.size() > 250:
		return "Map scenario registry is missing or invalid."
	var map_ids := {}
	for country in countries:
		if country is Dictionary and country.get("id") is String:
			map_ids[country.id] = true
	var seen_map := {}
	var seen_scenario := {}
	for binding in data.bindings:
		if not binding is Dictionary or binding.size() != 4 or not binding.get("map_id") is String or not binding.get("scenario_id") is String or not binding.get("country_id") is String or not binding.get("short_name") is String:
			return "Map scenario binding has invalid fields."
		if not map_ids.has(binding.map_id) or binding.short_name.strip_edges().is_empty() or binding.short_name.length() > 60 or seen_map.has(binding.map_id) or seen_scenario.has(binding.scenario_id):
			return "Map scenario binding has unknown or duplicate IDs."
		var found := false
		for scenario in scenarios:
			if not scenario is Dictionary or not scenario.get("path") is String:
				continue
			if scenario.get("id") == binding.scenario_id:
				var loaded: Variant = load_scenario(scenario.get("path", ""))
				if loaded is Dictionary and loaded.get("id") == binding.scenario_id and loaded.get("country") is Dictionary and loaded.country.get("id") == binding.country_id:
					found = true
				break
		if not found:
			return "Map binding does not match a valid built-in scenario and country."
		seen_map[binding.map_id] = true
		seen_scenario[binding.scenario_id] = true
	return ""

static func load_scenario(path: String) -> Variant:
	const World = preload("res://simulation/world.gd")
	var data: Variant = World.Scenario.read_file(path)
	return data if World.Scenario.validate(data).is_empty() else null
