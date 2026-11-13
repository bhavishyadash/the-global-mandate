extends RefCounted

const Politics = preload("res://simulation/politics.gd")
const Services = preload("res://simulation/services.gd")
const Institutions = preload("res://simulation/institutions.gd")
const Diplomacy = preload("res://simulation/diplomacy.gd")
const Healthcare = preload("res://simulation/healthcare.gd")
const PolicyRules = preload("res://simulation/policy_rules.gd")
const Demographics = preload("res://simulation/demographics.gd")
const DEFAULT_SEED := 12345
const MAX_SEED := 4294967295
const DEFAULT_SPENDING_LIMIT := 10000000000.0
const ABSOLUTE_SPENDING_LIMIT := 100000000000000.0

# One country per scenario; v1 uses original defaults, v2 includes subsystem
# state, v3 adds healthcare, v4 institutions, and v5 baseline policy rules.
const CATEGORIES := ["Health", "Education", "Security", "Infrastructure", "Administration"]

static func read_file(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return null
	return json.data

static func validate(data: Variant) -> String:
	if not data is Dictionary or not _whole(data.get("version")) or data.version < 1 or data.version > 5 or not _id(data.get("id")) or not data.get("description") is String:
		return "Invalid scenario header or unsupported version."
	if not Healthcare.valid_rules(data.get("healthcare_rules") if data.version >= 3 else Healthcare.default_rules()):
		return "Scenario healthcare rules are missing or invalid."
	if not Institutions.valid_rules(data.get("institution_rules") if data.version >= 4 else Institutions.default_rules()):
		return "Scenario institutional rules are missing or invalid."
	if not PolicyRules.valid(data.get("policy_rules") if data.version >= 5 else PolicyRules.defaults()):
		return "Scenario baseline policy rules are missing or invalid."
	if not Demographics.valid_rules(data.get("population_rules", Demographics.default_rules())):
		return "Scenario population rules are invalid."
	if data.has("seed") and (not _whole(data.seed) or data.seed < 0 or data.seed > MAX_SEED):
		return "Scenario seed must be a whole 32-bit unsigned number."
	var date: Variant = data.get("date")
	var c: Variant = data.get("country")
	if not date is Dictionary or not c is Dictionary:
		return "Scenario requires a date and country."
	for key in ["year", "month", "day"]:
		if not _whole(date.get(key)):
			return "Scenario date must contain whole numbers."
	var y := int(date.year)
	var m := int(date.month)
	if y < 1 or y > 9998 or m < 1 or m > 12:
		return "Scenario date is out of range."
	var leap := y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)
	var month_days: Array = [31, 29 if leap else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if date.day < 1 or date.day > month_days[m - 1]:
		return "Scenario day is out of range."
	if not _id(c.get("id")) or not c.get("name") is String or c.name.strip_edges().is_empty() or not _whole(c.get("population")) or c.population <= 0:
		return "Scenario country identity or population is invalid."
	var population_rules: Dictionary = data.get("population_rules", Demographics.default_rules())
	if c.population > Demographics.MAX_POPULATION and (population_rules.birth_rate_tenths != 0 or population_rules.death_rate_tenths != 0 or population_rules.migration_rate_tenths != 0):
		return "Scenario population exceeds the demographic model's supported bound."
	for key in ["treasury", "debt", "annual_revenue", "annual_spending", "income_tax_rate", "consumption_tax_rate", "corporate_tax_rate", "approval"]:
		if not _number(c.get(key)):
			return "Scenario financial values must be finite numbers."
	if not valid_fiscal_calibration(c.get("fiscal_calibration")):
		return "Scenario fiscal calibration is invalid."
	if c.has("nominal_gdp") and (not _number(c.nominal_gdp) or c.nominal_gdp <= 0):
		return "Scenario GDP must be a positive finite value."
	if c.treasury < 0 or c.debt < 0 or c.annual_revenue < 0 or c.annual_spending < 0 or c.annual_spending > spending_limit(c):
		return "Scenario budget is out of range."
	for key in ["income_tax_rate", "consumption_tax_rate", "corporate_tax_rate"]:
		if c[key] < 0.0 or c[key] > 0.60:
			return "Scenario tax rate is out of range."
	if c.approval < 0.0 or c.approval > 100.0:
		return "Scenario approval is out of range."
	var politics = Politics.new()
	var services = Services.new()
	var institutions = Institutions.new()
	if data.version >= 4:
		institutions.configure(data.institution_rules)
	var diplomacy = Diplomacy.new()
	if data.version >= 2:
		if not politics.import_state(data.get("politics")) or not services.import_state(data.get("services")) or not institutions.import_state(data.get("institutions")) or not diplomacy.import_state(data.get("diplomacy")):
			return "Scenario political, service, institutional or diplomatic state is invalid."
	var bonuses: Array = services.group_bonuses()
	for i in range(politics.groups.size()):
		if absf(politics.groups[i].service_bonus - bonuses[i]) > 0.001:
			return "Scenario group approval and service conditions are inconsistent."
	if absf(politics.approval() - float(c.approval)) > 0.001:
		return "Scenario group and national approval are inconsistent."
	var tax_revenue: float = c.income_tax_rate * 2000000000.0 + c.consumption_tax_rate * 1500000000.0 + c.corporate_tax_rate * 1000000000.0
	if c.annual_revenue < tax_revenue:
		return "Scenario revenue cannot be less than modeled tax revenue."
	var categories: Variant = c.get("spending_categories")
	if not categories is Dictionary or categories.size() != CATEGORIES.size():
		return "Scenario spending categories are incomplete."
	var total := 0.0
	for category in CATEGORIES:
		if not _number(categories.get(category)) or categories[category] < 0:
			return "Scenario category amount is invalid."
		total += float(categories[category])
	if absf(total - float(c.annual_spending)) > 0.01:
		return "Scenario categories do not match annual spending."
	return ""

static func spending_limit(country: Dictionary) -> float:
	return float(country.fiscal_calibration.max_spending) if country.has("fiscal_calibration") else DEFAULT_SPENDING_LIMIT

static func valid_fiscal_calibration(value: Variant) -> bool:
	if value == null:
		return true
	if not value is Dictionary or value.size() != 4 or not _number(value.get("max_spending")) or value.max_spending < DEFAULT_SPENDING_LIMIT or value.max_spending > ABSOLUTE_SPENDING_LIMIT or not _number(value.get("interest_rate")) or value.interest_rate < 0 or value.interest_rate > 1 or not _whole(value.get("baseline_population")) or value.baseline_population <= 0 or not value.get("service_baselines") is Dictionary or value.service_baselines.size() != CATEGORIES.size():
		return false
	for category in CATEGORIES:
		if not _number(value.service_baselines.get(category)) or value.service_baselines[category] <= 0 or value.service_baselines[category] > ABSOLUTE_SPENDING_LIMIT:
			return false
	return true

static func _id(value: Variant) -> bool:
	return value is String and not value.is_empty() and value.is_valid_identifier() and value.length() <= 64

static func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

static func _whole(value: Variant) -> bool:
	return _number(value) and float(value) == floorf(float(value))
