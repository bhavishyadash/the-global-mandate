extends SceneTree

const World = preload("res://simulation/world.gd")
const Diagnostics = preload("res://simulation/diagnostics.gd")
const REPORT := "res://tests/diagnostic_test_report.json"

func _initialize() -> void:
	if FileAccess.file_exists(REPORT):
		push_error("Diagnostic test report already exists.")
		quit(1)
		return
	var world = World.new()
	world.add_event("Private example text", "finance", "test_failure", "warning")
	assert(world.event_records[0].cause == "test_failure" and world.event_records[0].severity == "warning")
	var snapshot: Dictionary = world.export_snapshot()
	var loaded = World.new()
	assert(loaded.import_snapshot(snapshot).is_empty())
	assert(loaded.event_records == world.event_records)
	var invalid: Dictionary = snapshot.duplicate(true)
	invalid.event_records[0].severity = "bad"
	assert(not loaded.import_snapshot(invalid).is_empty())
	assert(loaded.event_records == world.event_records)
	var legacy: Dictionary = snapshot.duplicate(true)
	legacy.version = 16
	for event in legacy.event_records:
		event.erase("severity")
		event.erase("cause")
	assert(loaded.import_snapshot(legacy).is_empty())
	assert(loaded.event_records[0].cause == "legacy_unknown")
	var report: Dictionary = Diagnostics.report(world, "Advance one day")
	assert(report.scenario_id == world.scenario_id and report.seed == world.random_seed_value)
	assert(report.steps == "Advance one day" and report.events[0].cause == "test_failure")
	report.events[0].date.year = 1900
	assert(world.event_records[0].date.year == 2026)
	assert("Private example text" not in JSON.stringify(report))
	assert(Diagnostics.report(world, "x".repeat(4001)).is_empty())
	assert(Diagnostics.write_new(REPORT, report).is_empty())
	assert(not Diagnostics.write_new(REPORT, report).is_empty())
	assert(JSON.parse_string(FileAccess.get_file_as_string(REPORT)).steps == "Advance one day")
	assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(REPORT)) == OK)
	print("Diagnostic checks passed")
	quit(0)
