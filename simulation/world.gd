extends RefCounted

# All values here are fictional test data; rates are annual USD.
const INITIAL_DATE := {"year": 2026, "month": 1, "day": 1}
var date: Dictionary = INITIAL_DATE.duplicate()
var country := {
	"name": "Federal Republic (test scenario)",
	"population": 10000000,
	"treasury": 1000000000.0,
	"annual_revenue": 1200000000.0,
	"annual_spending": 1100000000.0,
	"income_tax_rate": 0.20,
	"approval": 50.0,
}
var events: Array[String] = ["Scenario started. All figures are fictional test data."]
const MAX_EVENTS := 200

func annual_balance() -> float:
	return country.annual_revenue - country.annual_spending

func daily_balance() -> float:
	return annual_balance() / (366.0 if is_leap_year(date.year) else 365.0)

func advance_day() -> void:
	var previous_treasury: float = country.treasury
	country.treasury += daily_balance()
	if previous_treasury >= 0.0 and country.treasury < 0.0:
		add_event("Treasury fell below zero. Borrowing is not yet modeled.")
	date.day += 1
	if date.day > days_in_month(date.year, date.month):
		date.day = 1
		date.month += 1
		if date.month > 12:
			date.month = 1
			date.year += 1

func add_event(message: String) -> void:
	events.push_front("%04d-%02d-%02d: %s" % [date.year, date.month, date.day, message])
	if events.size() > MAX_EVENTS:
		events.resize(MAX_EVENTS)

static func is_leap_year(year: int) -> bool:
	return year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)

static func days_in_month(year: int, month: int) -> int:
	if month == 2:
		return 29 if is_leap_year(year) else 28
	return 30 if month in [4, 6, 9, 11] else 31

func save_game(path: String) -> String:
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return "Could not open the save file for writing."
	file.store_string(JSON.stringify({"version": 1, "date": date, "country": country, "events": events}))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return "Could not finish writing the save file."
	var absolute_path := ProjectSettings.globalize_path(path)
	var absolute_temp := ProjectSettings.globalize_path(temporary)
	var backup := absolute_path + ".bak"
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(backup) and DirAccess.remove_absolute(backup) != OK:
			return "Could not replace the previous backup."
		if DirAccess.rename_absolute(absolute_path, backup) != OK:
			return "Could not back up the existing save."
	if DirAccess.rename_absolute(absolute_temp, absolute_path) != OK:
		if FileAccess.file_exists(backup):
			DirAccess.rename_absolute(backup, absolute_path)
		return "Could not finish saving; the previous save was retained if possible."
	return ""

func load_game(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return "No save could be opened."
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return "Save contains invalid JSON."
	var parsed: Variant = json.data
	if not parsed is Dictionary or parsed.get("version") != 1:
		return "Save is invalid or uses an unsupported version."
	var d: Variant = parsed.get("date")
	var c: Variant = parsed.get("country")
	var e: Variant = parsed.get("events")
	if not d is Dictionary or not c is Dictionary or not e is Array:
		return "Save data is incomplete."
	for key in ["year", "month", "day"]:
		if not d.has(key) or not _is_whole_number(d[key]):
			return "Save has an invalid date."
	var year := int(d.year)
	var month := int(d.month)
	var day := int(d.day)
	if year < 1 or year > 9999 or month < 1 or month > 12 or day < 1 or day > days_in_month(year, month):
		return "Save has an invalid date."
	if not c.has("name") or not c.name is String or c.name.is_empty() or not c.has("population") or not _is_whole_number(c.population) or c.population < 0:
		return "Save has invalid country data."
	for key in ["treasury", "annual_revenue", "annual_spending", "income_tax_rate", "approval"]:
		if not c.has(key) or not (c[key] is float or c[key] is int) or not is_finite(float(c[key])):
			return "Save has invalid financial or approval data."
	if c.income_tax_rate < 0.0 or c.income_tax_rate > 0.60 or c.approval < 0.0 or c.approval > 100.0 or c.annual_revenue < 0.0 or c.annual_spending < 0.0 or c.annual_spending > 10000000000.0 or e.size() > MAX_EVENTS:
		return "Save has out-of-range policy or approval data."
	for event in e:
		if not event is String:
			return "Save has invalid event data."
	date = {"year": year, "month": month, "day": day}
	country = c.duplicate(true)
	country.population = int(c.population)
	events.clear()
	for event in e:
		events.append(event)
	return ""

static func _is_whole_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value))

func set_income_tax(rate: float) -> bool:
	if not is_finite(rate) or rate < 0.0 or rate > 0.60:
		return false
	var previous: float = country.income_tax_rate
	if is_equal_approx(rate, previous):
		return true
	# Placeholder: $2 billion taxable base, other revenue held constant.
	country.annual_revenue += (rate - previous) * 2000000000.0
	# Temporary test sensitivity: a rise from 20% to 60% reduces 50% approval to 8%.
	country.approval = clampf(country.approval - (rate - previous) * 105.0, 0.0, 100.0)
	country.income_tax_rate = rate
	add_event("Income tax changed from %.1f%% to %.1f%%." % [previous * 100.0, rate * 100.0])
	return true

func set_annual_spending(amount: float) -> bool:
	if not is_finite(amount) or amount < 0.0 or amount > 10000000000.0:
		return false
	var previous: float = country.annual_spending
	if is_equal_approx(previous, amount):
		return true
	country.annual_spending = amount
	add_event("Annual spending changed from $%.0f to $%.0f." % [previous, amount])
	return true
