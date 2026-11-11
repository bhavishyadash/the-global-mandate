extends SceneTree

const World = preload("res://simulation/world.gd")
const SAVE := "res://tests/healthcare_test_save.json"

func _initialize() -> void:
	for suffix in ["", ".bak", ".invalid", ".bak.previous", ".tmp"]:
		if FileAccess.file_exists(SAVE + suffix):
			push_error("Healthcare test save already exists: " + SAVE + suffix)
			quit(1)
			return
	var world = World.new()
	var preview: Dictionary = world.preview_healthcare(100000000.0)
	assert(preview.votes == 70 and preview.passes and not world.healthcare.active)
	assert(world.preview_healthcare(75000000.0).is_empty())
	var baseline: float = world.annual_balance()
	assert(world.vote_healthcare(100000000.0))
	assert(is_equal_approx(world.annual_balance(), baseline - 100000000.0))
	assert(not world.set_healthcare_appropriation(-0.1))
	assert(not world.set_healthcare_appropriation(1.1))
	var funding_preview: Dictionary = world.preview_healthcare_appropriation(0.5)
	assert(funding_preview.votes == 70 and funding_preview.passes)
	assert(funding_preview.positions[0].support and funding_preview.positions[1].support and not funding_preview.positions[2].support)
	assert(is_equal_approx(funding_preview.annual_cost, 50000000.0))
	assert(is_equal_approx(funding_preview.annual_balance, baseline - 50000000.0))
	assert(is_equal_approx(funding_preview.daily_progress, 100.0 / 240.0))
	assert(world.healthcare.appropriation == 1.0)
	assert(world.set_healthcare_appropriation(0.5))
	assert(is_equal_approx(world.policy_annual_cost(), 50000000.0))
	assert(is_equal_approx(world.preview_healthcare(200000000.0).annual_cost, 100000000.0))
	var paused_progress: float = world.healthcare.progress
	assert(world.set_healthcare_appropriation(0.0))
	world.advance_day()
	assert(world.healthcare.progress == paused_progress and world.healthcare.health_bonus() == 0.0)
	assert(world.set_healthcare_appropriation(0.5))
	var model = World.Healthcare.new()
	model.active = true
	model.funding = 100000000.0
	model.advance_day(0.0)
	assert(model.progress == 0.0)
	model.advance_day(25.0)
	assert(is_equal_approx(model.progress, 100.0 / 240.0))
	for day in range(30):
		world.advance_day()
	assert(world.healthcare.progress > 0.0 and world.healthcare.progress < 100.0)
	assert(world.fiscal.policy > 0.0 and world.healthcare.health_bonus() > 0.0)
	assert(world.save_game(SAVE).is_empty())
	var restored = World.new()
	assert(restored.load_game(SAVE).is_empty())
	assert(is_equal_approx(restored.healthcare.progress, world.healthcare.progress))
	assert(restored.healthcare.appropriation == 0.5)
	var before: float = restored.healthcare.progress
	assert(restored.vote_healthcare(200000000.0))
	assert(is_equal_approx(restored.healthcare.progress, before / 2.0))
	assert(is_equal_approx(restored.policy_annual_cost(), 100000000.0))
	var forecast: Dictionary = restored.forecast_fiscal(30)
	assert(restored.healthcare.progress < before)
	for day in range(30):
		restored.advance_day()
	assert(is_equal_approx(restored.country.treasury, forecast.cash))
	assert(is_equal_approx(restored.country.debt, forecast.debt))
	assert(restored.repeal_healthcare())
	assert(not restored.healthcare.active and restored.healthcare.progress == 0.0)
	assert(is_zero_approx(restored.policy_annual_cost()))
	var rejected = World.new()
	rejected.politics.parties[0].seats = 20
	rejected.politics.parties[1].seats = 20
	rejected.politics.parties[2].seats = 60
	assert(not rejected.vote_healthcare(100000000.0))
	assert(not rejected.healthcare.active and is_zero_approx(rejected.policy_annual_cost()))
	var minority = World.new()
	assert(minority.vote_healthcare(100000000.0))
	minority.politics.parties[0].seats = 20
	minority.politics.parties[1].seats = 20
	minority.politics.parties[2].seats = 60
	assert(not minority.preview_healthcare_appropriation(0.5).passes)
	assert(not minority.set_healthcare_appropriation(0.5))
	assert(minority.healthcare.appropriation == 1.0 and is_equal_approx(minority.policy_annual_cost(), 100000000.0))
	assert("failed" in minority.events[0])
	assert(minority.set_healthcare_appropriation(0.75))
	assert(minority.healthcare.appropriation == 0.75)
	assert(not minority.set_healthcare_appropriation(0.75))
	var bad = World.Healthcare.new()
	assert(not bad.import_state({"active": true, "funding": 100000000.0, "progress": 101.0}))
	assert(not bad.import_state({"active": true, "funding": 100000000.0, "progress": 10.0, "appropriation": 2.0}))
	var old_data: Dictionary = world.export_snapshot()
	old_data.version = 15
	old_data.healthcare.erase("appropriation")
	var old_file := FileAccess.open(SAVE, FileAccess.WRITE)
	old_file.store_string(JSON.stringify(old_data))
	old_file.close()
	var migrated = World.new()
	assert(migrated.load_game(SAVE).is_empty())
	assert(migrated.healthcare.active and migrated.healthcare.appropriation == 1.0)
	for day in range(240):
		migrated.advance_day()
	var funded_health: float = migrated.services.levels.Health
	var funded_approval: float = migrated.country.approval
	assert(migrated.healthcare.progress == 100.0)
	assert(migrated.set_healthcare_appropriation(0.0))
	for day in range(60):
		migrated.advance_day()
	assert(migrated.services.levels.Health < funded_health)
	assert(migrated.country.approval < funded_approval)
	var custom: Dictionary = World.Scenario.read_file(World.DEFAULT_SCENARIO)
	custom.version = 3
	custom.healthcare_rules = World.Healthcare.default_rules()
	custom.healthcare_rules.funding_options = [20000000.0, 40000000.0, 80000000.0]
	custom.healthcare_rules.reform_proposal_max = 40000000.0
	custom.healthcare_rules.opposition_proposal_min = 80000000.0
	custom.healthcare_rules.days_at_normal_capacity = 60.0
	custom.healthcare_rules.target_per_100m = 10.0
	var configured = World.new()
	assert(configured.apply_scenario(custom).is_empty())
	assert(not configured.vote_healthcare(100000000.0))
	assert(configured.preview_healthcare(40000000.0).votes == 70)
	assert(configured.vote_healthcare(40000000.0))
	var expected: Dictionary = configured.forecast_fiscal(30)
	var configured_snapshot: Dictionary = configured.export_snapshot()
	var configured_loaded = World.new()
	assert(configured_loaded.import_snapshot(configured_snapshot).is_empty())
	for day in range(30):
		configured_loaded.advance_day()
	assert(is_equal_approx(configured_loaded.healthcare.progress, 50.0))
	assert(is_equal_approx(configured_loaded.country.treasury, expected.cash))
	assert(is_equal_approx(configured_loaded.healthcare.health_bonus(), 2.0))
	var invalid_rules: Dictionary = configured_snapshot.duplicate(true)
	invalid_rules.healthcare_rules.days_at_normal_capacity = 0
	var intact: Dictionary = configured_loaded.export_snapshot()
	assert(not configured_loaded.import_snapshot(invalid_rules).is_empty())
	assert(configured_loaded.export_snapshot() == intact)
	custom.healthcare_rules.funding_options = [1, 1, 2]
	assert(not configured_loaded.apply_scenario(custom).is_empty())
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
	print("Healthcare governing checks passed")
	quit(0)
