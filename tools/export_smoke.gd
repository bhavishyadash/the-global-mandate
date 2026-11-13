extends SceneTree

const World = preload("res://simulation/world.gd")
const WorldMap = preload("res://ui/world_map.gd")
const MapScenarioRegistry = preload("res://ui/map_scenario_registry.gd")
const Registry = preload("res://simulation/world_registry.gd")
const LawCatalogData = preload("res://ui/law_catalog_data.gd")
const USReference = preload("res://ui/us_reference.gd")

func _initialize() -> void:
	if not USReference.validate(USReference.read()).is_empty():
		push_error("Packaged US historical reference could not be loaded.")
		quit(1)
		return
	if not LawCatalogData.validate(LawCatalogData.read()).is_empty():
		push_error("Packaged law catalogue could not be loaded.")
		quit(1)
		return
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
	if absf(world.annual_balance() + 1992500000000.0) > 1.0:
		push_error("Packaged US federal baseline does not reconcile.")
		quit(1)
		return
	if not FileAccess.file_exists("res://data/reference/usa_fy2026.json"):
		push_error("Packaged FY2026 fiscal provenance is missing.")
		quit(1)
		return
	world.advance_day()
	if world.country.population != int(USReference.read().population.value):
		push_error("Packaged US sandbox population differs from its source reference.")
		quit(1)
		return
	var registry = Registry.new()
	alternate.date = usa.date.duplicate(true)
	if not registry.initialize([usa, alternate]).is_empty():
		push_error("Packaged world lab could not initialize.")
		quit(1)
		return
	registry.advance_day()
	if registry.country_snapshot("usa_sandbox").date.day != 13 or registry.country_snapshot("coastal_republic").date.day != 13:
		push_error("Packaged world lab did not advance together.")
		quit(1)
		return
	var map = WorldMap.new()
	if not map.load_map().is_empty() or map.countries.size() < 170:
		push_error("Packaged world map data could not be loaded.")
		quit(1)
		return
	var scenarios := [{"id": "usa_sandbox", "path": "res://data/scenarios/usa_sandbox.json"}]
	if not MapScenarioRegistry.validate(MapScenarioRegistry.read(), map.countries, scenarios).is_empty():
		push_error("Packaged map scenario bindings could not be loaded.")
		quit(1)
		return
	map.free()
	print("Packaged scenario checks passed")
	quit(0)
