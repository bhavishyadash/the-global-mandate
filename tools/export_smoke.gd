extends SceneTree

const World = preload("res://simulation/world.gd")
const WorldMap = preload("res://ui/world_map.gd")

func _initialize() -> void:
	var world = World.new()
	if not world.initialization_error.is_empty() or world.scenario_id != "test_republic" or world.country.get("id") != "test_republic":
		push_error("Packaged scenario did not initialize.")
		quit(1)
		return
	world.advance_day()
	if world.date.day != 2:
		push_error("Packaged simulation did not advance.")
		quit(1)
		return
	var alternate: Variant = World.Scenario.read_file("res://data/scenarios/coastal_test.json")
	if not world.apply_scenario(alternate).is_empty() or world.scenario_id != "coastal_test":
		push_error("Packaged alternate scenario did not initialize.")
		quit(1)
		return
	var usa: Variant = World.Scenario.read_file("res://data/scenarios/usa_sandbox.json")
	if not world.apply_scenario(usa).is_empty() or world.scenario_id != "usa_sandbox":
		push_error("Packaged US sandbox did not initialize.")
		quit(1)
		return
	var map = WorldMap.new()
	if not map.load_map().is_empty() or map.countries.size() < 170:
		push_error("Packaged world map data could not be loaded.")
		quit(1)
		return
	map.free()
	print("Packaged scenario checks passed")
	quit(0)
