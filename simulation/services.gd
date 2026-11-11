extends RefCounted

# Fictional calibration values for the test country, not real-world statistics.
const BASELINE := {"Health": 330000000.0, "Education": 275000000.0, "Security": 220000000.0, "Infrastructure": 165000000.0, "Administration": 110000000.0}
const BASE_POPULATION := 10000000.0
const RESPONSE_DAYS := 180.0
const GROUP_SENSITIVITIES := [0.35, 0.25, 0.15]
var levels := {"Health": 50.0, "Education": 50.0, "Security": 50.0, "Infrastructure": 50.0, "Administration": 50.0}

func target(category: String, spending: float, population: int, administration_bonus: float = 0.0) -> float:
	if not BASELINE.has(category) or population <= 0:
		return 0.0
	var baseline_for_population: float = BASELINE[category] * population / BASE_POPULATION
	return clampf(50.0 * spending / baseline_for_population + (administration_bonus if category == "Administration" else 0.0), 0.0, 100.0)

func advance_day(categories: Dictionary, population: int, administration_bonus: float = 0.0) -> void:
	for category in BASELINE:
		var desired := target(category, float(categories[category]), population, administration_bonus)
		levels[category] += (desired - levels[category]) / RESPONSE_DAYS

func group_bonuses() -> Array:
	var average := 0.0
	for category in BASELINE:
		average += float(levels[category]) / BASELINE.size()
	var bonuses: Array = []
	for sensitivity in GROUP_SENSITIVITIES:
		bonuses.append((average - 50.0) * sensitivity)
	return bonuses

func export_state() -> Dictionary:
	return {"levels": levels.duplicate(true)}

func import_state(state: Variant) -> bool:
	if not state is Dictionary or not state.get("levels") is Dictionary or state.levels.size() != BASELINE.size():
		return false
	for category in BASELINE:
		var value: Variant = state.levels.get(category)
		if not (value is float or value is int) or not is_finite(float(value)) or value < 0.0 or value > 100.0:
			return false
	levels = state.levels.duplicate(true)
	return true
