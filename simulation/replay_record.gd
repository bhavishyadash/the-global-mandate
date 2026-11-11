extends RefCounted

const World = preload("res://simulation/world.gd")
const Decisions = preload("res://simulation/decisions.gd")
const Replay = preload("res://simulation/replay.gd")
var world: Variant = null
var scenario: Dictionary = {}
var actions: Array = []
var days := 0

func begin(data: Variant) -> String:
	var candidate = World.new()
	if not data is Dictionary:
		return "Scenario must be a dictionary."
	# Normalize the input through its portable JSON representation before the
	# first run, so replay observes the same number types and precision.
	var portable: Variant = JSON.parse_string(JSON.stringify(data))
	var error: String = candidate.apply_scenario(portable)
	if not error.is_empty():
		return error
	world = candidate
	scenario = portable.duplicate(true)
	# Explicitly capture the effective seed even when the scenario used a default.
	scenario.seed = candidate.random_seed_value
	actions = []
	days = 0
	return ""

func decide(request: Variant) -> Dictionary:
	if world == null or actions.size() >= Replay.MAX_ACTIONS:
		return {"ok": false, "code": "recorder_unavailable", "message": "Recorder is unavailable or full."}
	var result: Dictionary = Decisions.execute(world, request)
	# Restrict persisted values to JSON-compatible decision dictionaries.
	if result.code in ["accepted", "unavailable"]:
		actions.append({"day": days, "decision": request.duplicate(true), "code": result.code})
	return result

func advance() -> bool:
	if world == null or days >= Replay.MAX_DAYS:
		return false
	world.advance_day()
	days += 1
	return true

func export_record() -> Dictionary:
	if world == null:
		return {}
	return {"format": 1, "scenario": scenario.duplicate(true), "days": days, "actions": actions.duplicate(true)}

static func reproduce(record: Variant) -> Dictionary:
	if not record is Dictionary or record.size() != 4 or record.get("format") != 1 or not record.get("scenario") is Dictionary or not record.get("actions") is Array or not World._is_whole_number(record.get("days")):
		return {"ok": false, "error": "Invalid reproduction record."}
	if record.days < 0 or record.days > Replay.MAX_DAYS or record.actions.size() > Replay.MAX_ACTIONS or not record.scenario.has("seed"):
		return {"ok": false, "error": "Reproduction record exceeds limits or lacks a seed."}
	var simulation = World.new()
	var error: String = simulation.apply_scenario(record.scenario)
	if not error.is_empty():
		return {"ok": false, "error": error}
	var elapsed := 0
	var previous_day := -1
	for entry in record.actions:
		if not entry is Dictionary or entry.size() != 3 or not World._is_whole_number(entry.get("day")) or not entry.get("decision") is Dictionary or not entry.get("code") is String:
			return {"ok": false, "error": "Invalid recorded action."}
		var target := int(entry.day)
		if target < previous_day or target < 0 or target > int(record.days):
			return {"ok": false, "error": "Recorded actions are out of order."}
		while elapsed < target:
			simulation.advance_day()
			elapsed += 1
		previous_day = target
		var result: Dictionary = Decisions.execute(simulation, entry.decision)
		if result.code != entry.code:
			return {"ok": false, "error": "Recorded decision result differs."}
	while elapsed < int(record.days):
		simulation.advance_day()
		elapsed += 1
	return {"ok": true, "world": simulation}
