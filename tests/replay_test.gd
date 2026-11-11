extends SceneTree

const World = preload("res://simulation/world.gd")
const Replay = preload("res://simulation/replay.gd")
const Record = preload("res://simulation/replay_record.gd")

func _initialize() -> void:
	var scenario: Variant = World.Scenario.read_file(World.DEFAULT_SCENARIO)
	var original_scenario: Dictionary = scenario.duplicate(true)
	var actions := [
		{"day": 0, "decision": {"id": "set_income_tax", "args": {"rate": 0.3}}},
		{"day": 0, "decision": {"id": "issue_directive", "args": {"kind": "reporting"}}},
		{"day": 20, "decision": {"id": "start_talks", "args": {"partner": "maritime", "proposal": "cooperation"}}},
		{"day": 120, "decision": {"id": "set_category_spending", "args": {"category": "Health", "amount": 400000000.0}}},
	]
	var a: Dictionary = Replay.run(scenario, actions, 366)
	var b: Dictionary = Replay.run(scenario, actions, 366)
	assert(scenario == original_scenario)
	assert(a.ok and b.ok)
	assert(a.world.date == b.world.date and a.world.country == b.world.country)
	assert(a.world.politics.export_state() == b.world.politics.export_state())
	assert(a.world.institutions.export_state() == b.world.institutions.export_state())
	assert(a.world.diplomacy.export_state() == b.world.diplomacy.export_state())
	assert(a.world.services.export_state() == b.world.services.export_state())
	assert(a.world.fiscal == b.world.fiscal and a.world.events == b.world.events)
	assert(a.world.event_records == b.world.event_records)
	assert(a.world.next_random_u32() == b.world.next_random_u32())
	var changed_seed: Dictionary = scenario.duplicate(true)
	changed_seed.seed = 67890
	var seeded: Dictionary = Replay.run(changed_seed, [], 0)
	var baseline_seed: Dictionary = Replay.run(scenario, [], 0)
	assert(seeded.ok and baseline_seed.ok and seeded.world.next_random_u32() != baseline_seed.world.next_random_u32())
	assert(not Replay.run(scenario, actions, 20).ok)
	assert(not Replay.run(scenario, [{"day": 1, "decision": {"id": "unknown", "args": {}}}], 2).ok)
	assert(not Replay.run(scenario, [{"day": 0, "decision": {"id": "set_income_tax", "args": {"rate": 0.9}}}], 1).ok)
	assert(not Replay.run(scenario, [{"day": 2, "decision": {}}, {"day": 1, "decision": {}}], 3).ok)
	assert(not Replay.run(scenario, [], Replay.MAX_DAYS + 1).ok)
	assert(Replay.run(scenario, [], 0).ok)
	var coastal: Variant = World.Scenario.read_file("res://data/scenarios/coastal_test.json")
	var coastal_run: Dictionary = Replay.run(coastal, [], 365)
	assert(coastal_run.ok and coastal_run.world.scenario_id == "coastal_test")
	assert(coastal_run.world.country.population == 8000000)
	var recorder = Record.new()
	assert(recorder.begin(scenario).is_empty())
	assert(recorder.decide({"id": "vote_healthcare", "args": {"funding": 100000000.0}}).ok)
	for day in range(25):
		assert(recorder.advance())
	assert(recorder.decide({"id": "set_healthcare_appropriation", "args": {"fraction": 0.5}}).ok)
	assert(not recorder.decide({"id": "set_healthcare_appropriation", "args": {"fraction": 0.5}}).ok)
	var record: Dictionary = recorder.export_record()
	assert(record.scenario.version == scenario.version and record.scenario.seed == World.Scenario.DEFAULT_SEED)
	var round_trip: Variant = JSON.parse_string(JSON.stringify(record))
	var reproduction: Dictionary = Record.reproduce(round_trip)
	assert(reproduction.ok)
	assert(reproduction.world.export_snapshot() == recorder.world.export_snapshot())
	var minority: Dictionary = scenario.duplicate(true)
	minority.politics.parties[0].seats = 20
	minority.politics.parties[1].seats = 20
	minority.politics.parties[2].seats = 60
	var rejection = Record.new()
	assert(rejection.begin(minority).is_empty())
	assert(rejection.decide({"id": "vote_healthcare", "args": {"funding": 200000000.0}}).ok)
	assert(not rejection.decide({"id": "set_healthcare_appropriation", "args": {"fraction": 0.5}}).ok)
	assert("failed" in rejection.world.events[0])
	var replayed_rejection: Dictionary = Record.reproduce(JSON.parse_string(JSON.stringify(rejection.export_record())))
	assert(replayed_rejection.ok and replayed_rejection.world.export_snapshot() == rejection.world.export_snapshot())
	var tampered: Dictionary = record.duplicate(true)
	tampered.actions[0].code = "unavailable"
	assert(not Record.reproduce(tampered).ok)
	tampered = record.duplicate(true)
	tampered.actions[1].day = -1
	assert(not Record.reproduce(tampered).ok)
	tampered = record.duplicate(true)
	tampered.scenario.erase("seed")
	assert(not Record.reproduce(tampered).ok)
	print("Replay checks passed")
	quit(0)
