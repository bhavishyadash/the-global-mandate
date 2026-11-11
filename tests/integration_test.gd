extends SceneTree

const World = preload("res://simulation/world.gd")
const TEST_SAVE := "res://tests/integration_test_save.json"

func _initialize() -> void:
	# Never overwrite an existing file, including a leftover from an interrupted test.
	for suffix in ["", ".bak", ".invalid", ".bak.previous", ".tmp"]:
		if FileAccess.file_exists(TEST_SAVE + suffix):
			push_error("Integration test save already exists: " + TEST_SAVE + suffix)
			quit(1)
			return
	var world = World.new()
	assert(world.set_income_tax(0.60))
	assert(is_equal_approx(world.country.approval, 8.0))
	assert(world.vote_procurement())
	for day in range(100):
		world.advance_day()
	assert(world.politics.procurement_progress == 100)
	assert(is_equal_approx(world.policy_annual_cost(), 10000000.0))
	assert(is_equal_approx(world.annual_balance(), 890000000.0))
	assert(world.save_game(TEST_SAVE).is_empty())
	var restored = World.new()
	assert(restored.load_game(TEST_SAVE).is_empty())
	while restored.date.year < 2030:
		restored.advance_day()
	assert(restored.politics.election_count == 1)
	assert(restored.politics.parties[0].seats == 8)
	assert(restored.politics.votes_for_repeal() > 50)
	assert(restored.vote_procurement_repeal())
	assert(is_equal_approx(restored.policy_annual_cost(), 0.0))
	assert(is_equal_approx(restored.annual_balance(), 900000000.0))
	assert(restored.save_game(TEST_SAVE).is_empty())
	var final_world = World.new()
	assert(final_world.load_game(TEST_SAVE).is_empty())
	assert(not final_world.politics.procurement_policy)
	assert(final_world.politics.election_count == 1)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE + ".bak"))
	# Multi-year deficit crosses a leap year and a save/load boundary while
	# accumulated interest changes daily. Check the accounting identity daily.
	var long_run = World.new()
	long_run.country.treasury = 0.0
	assert(long_run.set_annual_spending(2000000000.0))
	var cumulative := 0.0
	var resumed = World.new()
	for day in range(1461):
		var divisor := 366.0 if World.is_leap_year(long_run.date.year) else 365.0
		cumulative += long_run.annual_balance() / divisor
		long_run.advance_day()
		assert(absf(long_run.country.treasury - long_run.country.debt - cumulative) < 0.1)
		if day == 730:
			assert(long_run.save_game(TEST_SAVE).is_empty())
			assert(resumed.load_game(TEST_SAVE).is_empty())
		elif day > 730:
			resumed.advance_day()
	assert(long_run.date.year == 2030 and long_run.politics.election_count == 1)
	assert(resumed.date == long_run.date)
	assert(absf(resumed.country.debt - long_run.country.debt) < 0.1)
	assert(absf(resumed.country.approval - long_run.country.approval) < 0.001)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("Integrated scenario checks passed")
	quit(0)
