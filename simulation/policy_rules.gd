extends RefCounted

const DEFAULT_PATH := "res://data/rules/baseline_policy_v1.json"
static var _cached: Dictionary = {}

static func defaults() -> Dictionary:
	if _cached.is_empty():
		var file := FileAccess.open(DEFAULT_PATH, FileAccess.READ)
		if file != null:
			var data: Variant = JSON.parse_string(file.get_as_text())
			if valid(data):
				_cached = data.duplicate(true)
	return _cached.duplicate(true)

static func valid(data: Variant) -> bool:
	if not data is Dictionary or data.size() != 5 or data.get("version") != 1:
		return false
	for key in ["procurement_annual_cost", "procurement_progress_per_day", "reporting_annual_cost", "reporting_admin_target_bonus"]:
		var value: Variant = data.get(key)
		if not (value is int or value is float) or not is_finite(float(value)):
			return false
	return data.procurement_annual_cost >= 0.0 and data.procurement_annual_cost <= 10000000000.0 and data.reporting_annual_cost >= 0.0 and data.reporting_annual_cost <= 10000000000.0 and data.procurement_progress_per_day >= 1 and data.procurement_progress_per_day <= 100 and float(data.procurement_progress_per_day) == floorf(float(data.procurement_progress_per_day)) and data.reporting_admin_target_bonus >= 0 and data.reporting_admin_target_bonus <= 100
