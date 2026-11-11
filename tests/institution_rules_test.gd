extends SceneTree

const World = preload("res://simulation/world.gd")

func _initialize() -> void:
	var scenario: Dictionary = World.Scenario.read_file(World.DEFAULT_SCENARIO)
	scenario.version = 4
	scenario.healthcare_rules = World.Healthcare.default_rules()
	scenario.institution_rules = World.Institutions.default_rules()
	scenario.institution_rules.review_day = 10
	scenario.institution_rules.injunction_day = 3
	scenario.institution_rules.implementation_days = 20
	scenario.institution_rules.cases.reporting.within_authority = false
	scenario.institution_rules.cases.override.within_authority = true
	var world = World.new()
	assert(world.apply_scenario(scenario).is_empty())
	assert(world.issue_directive("reporting"))
	for day in range(3):
		world.advance_day()
	assert(world.institutions.status == "injunction" and world.institutions.progress == 2)
	var saved: Dictionary = world.export_snapshot()
	var restored = World.new()
	assert(restored.import_snapshot(saved).is_empty())
	var forecast: Dictionary = restored.forecast_fiscal(7)
	for day in range(7):
		restored.advance_day()
	assert(restored.institutions.status == "struck_down")
	assert(is_equal_approx(restored.country.treasury, forecast.cash))
	assert(restored.issue_directive("override"))
	for day in range(20):
		restored.advance_day()
	assert(restored.institutions.status == "implemented" and restored.institutions.progress == 20)
	assert(not restored.reporting_effect_active())
	var bad: Dictionary = saved.duplicate(true)
	bad.institution_rules.injunction_day = 10
	var before: Dictionary = restored.export_snapshot()
	assert(not restored.import_snapshot(bad).is_empty())
	assert(restored.export_snapshot() == before)
	var old := World.new()
	var legacy: Dictionary = old.export_snapshot()
	legacy.version = 18
	legacy.erase("institution_rules")
	assert(restored.import_snapshot(legacy).is_empty())
	assert(restored.institutions.rules.review_day == 30)
	print("Institution rule checks passed")
	quit(0)
