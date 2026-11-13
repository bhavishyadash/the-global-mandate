extends SceneTree

const World = preload("res://simulation/world.gd")
const Demographics = preload("res://simulation/demographics.gd")
const Registry = preload("res://simulation/world_registry.gd")

func _initialize() -> void:
	var model = Demographics.new()
	var groups = World.Politics.new()
	assert(groups.population_counts(0) == [0, 0, 0])
	assert(groups.population_counts(1) == [1, 0, 0])
	assert(groups.population_counts(2) == [1, 1, 0])
	assert(groups.population_counts(7) == [3, 3, 1])
	assert(groups.population_counts(-1).is_empty() and groups.population_counts(10000000001).is_empty())
	for population in [3, 11, 9999999, 10000000000]:
		var allocation: Array = groups.population_counts(population)
		assert(allocation.size() == 3 and allocation[0] + allocation[1] + allocation[2] == population)
	for group in groups.groups:
		group.share = 0.333333
	assert(groups.population_counts(2) == [1, 1, 0])
	groups.groups[0].share = NAN
	assert(groups.population_counts(100).is_empty())
	var rules := {"birth_rate_tenths": 100, "death_rate_tenths": 50, "migration_rate_tenths": -20}
	assert(model.configure(rules))
	var before: Dictionary = model.export_state()
	assert(not model.configure({"birth_rate_tenths": NAN, "death_rate_tenths": 0, "migration_rate_tenths": 0}))
	assert(model.export_state() == before)
	for leap in [false, true]:
		assert(model.configure(rules))
		var totals := {"births": 0, "deaths": 0, "migration": 0}
		for day in range(366 if leap else 365):
			var flow: Dictionary = model.advance(1000, leap)
			for key in totals:
				totals[key] += flow[key]
			assert(flow.population == 1000 + flow.births - flow.deaths + flow.migration)
		assert(totals == {"births": 10, "deaths": 5, "migration": -2})
		assert(model.fractions == {"births": 0, "deaths": 0, "migration": 0})
	assert(model.configure(rules))
	for day in range(120):
		model.advance(1000, false)
	var restored = Demographics.new()
	assert(restored.import_state(JSON.parse_string(JSON.stringify(model.export_state()))))
	for day in range(400):
		var leap := day >= 245
		assert(model.advance(1000, leap) == restored.advance(1000, leap))
	assert(model.export_state() == restored.export_state())
	var invalid: Dictionary = model.export_state()
	invalid.fractions.births = Demographics.DENOMINATOR
	var valid_before: Dictionary = model.export_state()
	assert(not model.import_state(invalid) and model.export_state() == valid_before)
	assert(model.configure({"birth_rate_tenths": 1000, "death_rate_tenths": 0, "migration_rate_tenths": 0}))
	for day in range(20):
		var at_cap: Dictionary = model.advance(Demographics.MAX_POPULATION, false)
		assert(at_cap.population == Demographics.MAX_POPULATION and at_cap.births == 0)
	assert(model.advance(0, false).population == 0)
	var scenario: Dictionary = World.Scenario.read_file("res://data/scenarios/usa_sandbox.json")
	var source: Dictionary = preload("res://ui/us_reference.gd").read()
	assert(scenario.country.population == source.population.value and int(scenario.date.year) == 2025 and int(scenario.date.month) == 10 and int(scenario.date.day) == 1)
	assert(World.Scenario.validate(scenario).is_empty())
	var invalid_scenario: Dictionary = scenario.duplicate(true)
	invalid_scenario.population_rules.birth_rate_tenths = 1001
	assert(not World.Scenario.validate(invalid_scenario).is_empty())
	var original = World.new()
	assert(original.apply_scenario(scenario).is_empty())
	assert(original.country.annual_revenue == 5234617000000.0)
	assert(original.country.annual_revenue == source.budget.receipts_millions * 1000000.0)
	assert(original.country.annual_spending == 6039633000000.0)
	assert(absf(original.country.annual_spending + original.debt_interest() - source.budget.outlays_millions * 1000000.0) < 1.0)
	assert(absf(original.debt_interest() - 970359000000.0) < 1.0)
	assert(absf(original.annual_balance() + 1775375000000.0) < 1.0)
	assert(original.country.treasury == 890825093623.0 and original.country.debt == 30200000000000.0)
	assert(absf(original.service_target("Health", original.country.spending_categories.Health) - 50.0) < 0.01)
	assert(not original.preview_category_spending("Health", 2000000000000.0).is_empty())
	var original_health: float = original.country.spending_categories.Health
	assert(original.set_category_spending("Health", original_health + 1000000.0))
	assert(original.country.spending_categories.Health == original_health + 1000000.0)
	assert(original.set_category_spending("Health", original_health))
	var bad_calibration: Dictionary = scenario.duplicate(true)
	bad_calibration.country.fiscal_calibration.interest_rate = -1
	assert(not World.Scenario.validate(bad_calibration).is_empty())
	for day in range(120):
		original.advance_day()
	var saved: Dictionary = JSON.parse_string(JSON.stringify(original.export_snapshot()))
	var resumed = World.new()
	assert(resumed.import_snapshot(saved).is_empty())
	var bad_saved: Dictionary = saved.duplicate(true)
	bad_saved.country.fiscal_calibration.service_baselines.Health = 0
	assert(not resumed.import_snapshot(bad_saved).is_empty())
	for day in range(500):
		original.advance_day()
		resumed.advance_day()
	assert(original.country.population == resumed.country.population and original.demographics.export_state() == resumed.demographics.export_state())
	assert(original.country.population == int(source.population.value))
	var legacy: Dictionary = saved.duplicate(true)
	legacy.version = 23
	legacy.erase("demographics")
	var old = World.new()
	assert(old.import_snapshot(legacy).is_empty())
	var old_population: int = old.country.population
	for day in range(365):
		old.advance_day()
	assert(old.country.population == old_population and old.demographics.rules == Demographics.default_rules())
	var invalid_save: Dictionary = saved.duplicate(true)
	invalid_save.demographics.fractions.migration = Demographics.DENOMINATOR
	var old_snapshot: Dictionary = old.export_snapshot()
	assert(not old.import_snapshot(invalid_save).is_empty() and old.export_snapshot() == old_snapshot)
	var forecast_world = World.new()
	assert(forecast_world.apply_scenario(scenario).is_empty())
	var snapshot: Dictionary = forecast_world.export_snapshot()
	var forecast: Dictionary = forecast_world.forecast_fiscal(365)
	assert(not forecast.is_empty() and forecast_world.export_snapshot() == snapshot)
	for day in range(365):
		forecast_world.advance_day()
	assert(forecast.population == forecast_world.country.population)
	assert(is_equal_approx(forecast.approval, forecast_world.country.approval))
	var coastal: Dictionary = World.Scenario.read_file("res://data/scenarios/coastal_test.json")
	coastal.date = scenario.date.duplicate(true)
	var shared = Registry.new()
	assert(shared.initialize([scenario, coastal]).is_empty())
	var shared_before: Dictionary = shared.export_snapshot()
	var shared_projection: Dictionary = shared.forecast_fiscal("usa_sandbox", 60)
	assert(not shared_projection.is_empty() and shared.export_snapshot() == shared_before)
	for day in range(60):
		shared.advance_day()
	assert(shared_projection.population == shared.country_snapshot("usa_sandbox").country.population)
	assert(shared.country_snapshot("coastal_republic").country.population > 8000000)
	assert(shared.country_snapshot("usa_sandbox").date == shared.country_snapshot("coastal_republic").date)
	print("Demographic model checks passed")
	quit(0)
