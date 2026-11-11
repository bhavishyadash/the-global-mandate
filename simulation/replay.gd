extends RefCounted

const World = preload("res://simulation/world.gd")
const Decisions = preload("res://simulation/decisions.gd")
const MAX_DAYS := 3660
const MAX_ACTIONS := 1000

# Entries are {"day": zero-based day offset, "decision": {"id", "args"}}.
# Same-day actions execute in supplied order before that day's tick. The
# created world is private until success; errors never modify the caller.
static func run(scenario: Variant, actions: Variant, days: int) -> Dictionary:
	if days < 0 or days > MAX_DAYS or not actions is Array or actions.size() > MAX_ACTIONS:
		return {"ok": false, "error": "Invalid replay length or action list."}
	var previous := -1
	for entry in actions:
		if not entry is Dictionary or entry.size() != 2 or not entry.get("decision") is Dictionary or not World._is_whole_number(entry.get("day")):
			return {"ok": false, "error": "Invalid replay entry."}
		var day := int(entry.day)
		if day < previous or day < 0 or day >= days:
			return {"ok": false, "error": "Replay days must be ordered and within the run."}
		previous = day
	var simulation = World.new()
	var scenario_error: String = simulation.apply_scenario(scenario)
	if not scenario_error.is_empty():
		return {"ok": false, "error": scenario_error}
	var index := 0
	for day in range(days):
		while index < actions.size() and int(actions[index].day) == day:
			var result: Dictionary = Decisions.execute(simulation, actions[index].decision)
			if not result.ok:
				return {"ok": false, "error": "Decision %d at day %d: %s" % [index, day, result.code]}
			index += 1
		simulation.advance_day()
	return {"ok": true, "world": simulation}
