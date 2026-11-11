extends SceneTree

const World = preload("res://simulation/world.gd")
const Decisions = preload("res://simulation/decisions.gd")
const SAVE := "res://tests/stress_test_save.json"

func _initialize() -> void:
	for suffix in ["", ".tmp", ".bak", ".invalid", ".bak.previous"]:
		if FileAccess.file_exists(SAVE + suffix):
			push_error("Stress-test save already exists: " + SAVE + suffix)
			quit(1)
			return
	var continuous = World.new()
	var resumed = World.new()
	for day in range(3650):
		_step(continuous, day)
		_step(resumed, day)
		if day == 1824:
			assert(resumed.save_game(SAVE).is_empty())
			var loaded = World.new()
			assert(loaded.load_game(SAVE).is_empty())
			resumed = loaded
		assert(continuous.date == resumed.date)
		assert(continuous.random_state == resumed.random_state)
		assert(is_equal_approx(continuous.country.treasury, resumed.country.treasury))
		assert(is_equal_approx(continuous.country.debt, resumed.country.debt))
		assert(is_equal_approx(continuous.country.approval, resumed.country.approval))
		assert(continuous.country.treasury >= 0.0 and continuous.country.debt >= 0.0)
		assert(is_finite(continuous.country.treasury) and is_finite(continuous.country.debt))
		assert(continuous.country.approval >= 0.0 and continuous.country.approval <= 100.0)
		assert(continuous.events.size() <= continuous.MAX_EVENTS)
		assert(continuous.events.size() == continuous.event_records.size())
	assert(continuous.politics.election_count >= 2)
	assert(World._valid_event_records(continuous.event_records, continuous.events))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
	print("Long-run stress checks passed")
	quit(0)

func _step(world: Variant, day: int) -> void:
	if day % 30 == 0:
		var rate := float(world.next_random_u32() % 61) / 100.0
		var spending := float(500 + world.next_random_u32() % 1501) * 1000000.0
		assert(Decisions.execute(world, {"id": "set_income_tax", "args": {"rate": rate}}).ok)
		assert(Decisions.execute(world, {"id": "set_total_spending", "args": {"amount": spending}}).ok)
	if day % 400 == 0:
		assert(Decisions.execute(world, {"id": "issue_directive", "args": {"kind": "reporting"}}).ok)
	if day % 400 == 200:
		assert(Decisions.execute(world, {"id": "revoke_directive", "args": {}}).ok)
	if day % 365 == 0:
		assert(Decisions.execute(world, {"id": "start_talks", "args": {"partner": "maritime", "proposal": "cooperation"}}).ok)
	world.advance_day()
