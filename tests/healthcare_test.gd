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
	var before: float = restored.healthcare.progress
	assert(restored.vote_healthcare(200000000.0))
	assert(is_equal_approx(restored.healthcare.progress, before / 2.0))
	assert(is_equal_approx(restored.policy_annual_cost(), 200000000.0))
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
	var bad = World.Healthcare.new()
	assert(not bad.import_state({"active": true, "funding": 100000000.0, "progress": 101.0}))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
	print("Healthcare governing checks passed")
	quit(0)
