extends RefCounted

# Local-only, deliberately excludes file paths, hardware IDs and event text.
# Steps are user-provided and should be reviewed before sharing a report.
static func report(world: Variant, steps: String) -> Dictionary:
	if world == null or steps.length() > 4000:
		return {}
	var events: Array = []
	for event in world.event_records:
		events.append({"date": event.date.duplicate() if event.date is Dictionary else null, "category": event.category, "cause": event.cause, "severity": event.severity})
	return {"format": 1, "game_version": ProjectSettings.get_setting("application/config/version", "unknown"), "engine_version": Engine.get_version_info().string, "save_version": world.export_snapshot().version, "scenario_id": world.scenario_id, "seed": world.random_seed_value, "random_state": world.random_state, "date": world.date.duplicate(), "steps": steps, "events": events}

static func write_new(path: String, report_data: Dictionary) -> String:
	if report_data.is_empty() or FileAccess.file_exists(path):
		return "Report is invalid or a file already exists at that path."
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return "Could not open the report file."
	file.store_string(JSON.stringify(report_data, "  "))
	file.flush()
	var error := file.get_error()
	file.close()
	return "" if error == OK else "Could not finish writing the report."
