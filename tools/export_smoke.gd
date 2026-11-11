extends SceneTree

const World = preload("res://simulation/world.gd")

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
	print("Packaged scenario checks passed")
	quit(0)
