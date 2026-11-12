extends RefCounted

const PATH := "res://data/reference/usa_fy2025.json"

static func read() -> Variant:
	if not FileAccess.file_exists(PATH):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(PATH))

static func validate(data: Variant) -> String:
	if not data is Dictionary or not data.get("sources") is Dictionary or not data.get("population") is Dictionary or not data.get("budget") is Dictionary or not data.get("economy") is Dictionary:
		return "US reference data is missing or malformed."
	var sources: Dictionary = data.sources
	var pop: Dictionary = data.population
	var budget: Dictionary = data.budget
	var economy: Dictionary = data.economy
	for key in ["bea", "bls"]:
		if not sources.get(key) is String or not str(sources[key]).begins_with("https://"):
			return "US economic sources are missing."
	if not economy.get("gdp_billions") is float or not is_finite(economy.gdp_billions) or economy.gdp_billions <= 0 or not economy.get("unemployment_percent") is float or not is_finite(economy.unemployment_percent) or economy.unemployment_percent < 0 or economy.unemployment_percent > 100 or not economy.get("gdp_period") is String or not economy.get("unemployment_period") is String:
		return "US economic observations are invalid."
	if not sources.get("census") is String or not sources.get("treasury") is String or not str(sources.census).begins_with("https://") or not str(sources.treasury).begins_with("https://"):
		return "US reference sources are missing."
	if not pop.get("value") is float or pop.value <= 0 or not pop.get("scope") is String or not pop.get("period") is String or pop.get("source") != "census":
		return "US population reference is invalid."
	if not budget.get("functions") is Array or not budget.get("scope") is String or not budget.get("period") is String or budget.get("source") != "treasury":
		return "US budget reference is invalid."
	for key in ["receipts_millions", "outlays_millions", "deficit_millions"]:
		if not budget.get(key) is float or budget[key] < 0 or not is_finite(budget[key]):
			return "US budget total is invalid."
	if absf(budget.outlays_millions - budget.receipts_millions - budget.deficit_millions) > 1:
		return "US budget deficit does not reconcile."
	var total := 0.0
	var names := {}
	for entry in budget.functions:
		if not entry is Dictionary or not entry.get("name") is String or entry.name.is_empty() or names.has(entry.name) or not entry.get("millions") is float or not is_finite(entry.millions):
			return "US budget function is invalid."
		names[entry.name] = true
		total += entry.millions
	# Treasury rounds each function independently to millions.
	if absf(total - budget.outlays_millions) > budget.functions.size() / 2.0:
		return "US budget functions do not reconcile."
	return ""
