extends SceneTree

const World = preload("res://simulation/world.gd")

func _initialize() -> void:
	var usa: Dictionary = World.Scenario.read_file("res://data/scenarios/usa_sandbox.json")
	var coastal: Dictionary = World.Scenario.read_file("res://data/scenarios/coastal_test.json")
	assert(World.Scenario.validate(usa).is_empty() and World.Scenario.validate(coastal).is_empty())
	var bad_scenario := usa.duplicate(true)
	bad_scenario.politics.groups[0].additional_tax_sensitivity.corporate = NAN
	assert(not World.Scenario.validate(bad_scenario).is_empty())
	var first = World.new()
	var second = World.new()
	assert(first.apply_scenario(usa).is_empty() and second.apply_scenario(coastal).is_empty())
	var first_start: float = first.politics.groups[0].approval
	var second_start: float = second.politics.groups[0].approval
	assert(first.set_additional_tax("consumption", 0.1))
	assert(second.set_additional_tax("consumption", 0.1))
	assert(is_equal_approx(first.politics.groups[0].approval - first_start, -14.0))
	assert(is_equal_approx(second.politics.groups[0].approval - second_start, -11.0))
	var before_corporate: float = first.politics.groups[0].approval
	assert(first.set_additional_tax("corporate", 0.31))
	assert(is_equal_approx(first.politics.groups[0].approval - before_corporate, 2.0))
	var snapshot: Dictionary = JSON.parse_string(JSON.stringify(first.export_snapshot()))
	var restored = World.new()
	assert(restored.import_snapshot(snapshot).is_empty())
	assert(restored.politics.groups[0].additional_tax_sensitivity.corporate == -20.0)
	var invalid := snapshot.duplicate(true)
	invalid.politics.groups[0].erase("additional_tax_sensitivity")
	var before_invalid: Dictionary = restored.export_snapshot()
	assert(not restored.import_snapshot(invalid).is_empty() and restored.export_snapshot() == before_invalid)
	invalid = snapshot.duplicate(true)
	invalid.politics.groups[0].additional_tax_sensitivity.consumption = 1001
	assert(not restored.import_snapshot(invalid).is_empty() and restored.export_snapshot() == before_invalid)
	var legacy := snapshot.duplicate(true)
	legacy.version = 25
	for group in legacy.politics.groups:
		group.erase("additional_tax_sensitivity")
	assert(restored.import_snapshot(legacy).is_empty())
	assert(restored.politics.groups[0].additional_tax_sensitivity == {"consumption": 120.0, "corporate": 10.0})
	var forecast_world = World.new()
	assert(forecast_world.apply_scenario(usa).is_empty())
	var before_forecast: Dictionary = forecast_world.export_snapshot()
	var prediction: Dictionary = forecast_world.forecast_fiscal(90, {"corporate_tax": 0.31})
	assert(not prediction.is_empty() and forecast_world.export_snapshot() == before_forecast)
	assert(forecast_world.set_additional_tax("corporate", 0.31))
	for day in range(90):
		forecast_world.advance_day()
	assert(is_equal_approx(prediction.approval, forecast_world.country.approval))
	print("Political opinion checks passed")
	quit(0)
