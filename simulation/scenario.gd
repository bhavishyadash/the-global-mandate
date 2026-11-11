extends RefCounted

# This initial schema configures one country only. Politics, institutions,
# services and diplomacy still start with their documented test defaults.
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
	if not data is Dictionary or data.get("version") != 1 or not _id(data.get("id")) or not data.get("description") is String:
		return "Invalid scenario header or unsupported version."
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
	for key in ["treasury", "debt", "annual_revenue", "annual_spending", "income_tax_rate", "consumption_tax_rate", "corporate_tax_rate", "approval"]:
		if not _number(c.get(key)):
			return "Scenario financial values must be finite numbers."
	if c.treasury < 0 or c.debt < 0 or c.annual_revenue < 0 or c.annual_spending < 0 or c.annual_spending > 10000000000.0:
		return "Scenario budget is out of range."
	for key in ["income_tax_rate", "consumption_tax_rate", "corporate_tax_rate"]:
		if c[key] < 0.0 or c[key] > 0.60:
			return "Scenario tax rate is out of range."
	# Other systems currently initialize at neutral service and political values.
	if c.approval != 50.0:
		return "Starting approval must match the current neutral political baseline."
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

static func _id(value: Variant) -> bool:
	return value is String and not value.is_empty() and value.is_valid_identifier() and value.length() <= 64

static func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

static func _whole(value: Variant) -> bool:
	return _number(value) and float(value) == floorf(float(value))
