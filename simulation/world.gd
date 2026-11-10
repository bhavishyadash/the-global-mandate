extends RefCounted

const Politics = preload("res://simulation/politics.gd")
var politics = Politics.new()

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
	if politics.advance_day():
		add_event("Procurement policy implementation completed.")
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
	file.store_string(JSON.stringify({"version": 3, "date": date, "country": country, "events": events, "politics": politics.export_state()}))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return "Could not finish writing the save file."
	var absolute_path := ProjectSettings.globalize_path(path)
	var absolute_temp := ProjectSettings.globalize_path(temporary)
	var backup := absolute_path + ".bak"
	var previous_backup := backup + ".previous"
	var displaced := ""
	var retained_backup := false
	if FileAccess.file_exists(path):
		# Validate the existing primary without altering the current world. Never
		# replace a usable backup with a corrupt or incompatible primary.
		var probe = get_script().new()
		if probe.load_game(path).is_empty():
			if FileAccess.file_exists(previous_backup):
				return "An interrupted backup rotation needs manual recovery before saving."
			if FileAccess.file_exists(backup):
				if DirAccess.rename_absolute(backup, previous_backup) != OK:
					return "Could not preserve the previous backup."
				retained_backup = true
			displaced = backup
		else:
			displaced = absolute_path + ".invalid"
			if FileAccess.file_exists(displaced):
				return "A previous invalid save already exists; move it before saving again."
		if DirAccess.rename_absolute(absolute_path, displaced) != OK:
			if retained_backup:
				DirAccess.rename_absolute(previous_backup, backup)
			return "Could not preserve the existing save."
	if DirAccess.rename_absolute(absolute_temp, absolute_path) != OK:
		if not displaced.is_empty() and FileAccess.file_exists(displaced):
			DirAccess.rename_absolute(displaced, absolute_path)
		if retained_backup and not FileAccess.file_exists(backup):
			DirAccess.rename_absolute(previous_backup, backup)
		return "Could not finish saving; the previous save was retained if possible."
	if retained_backup and DirAccess.remove_absolute(previous_backup) != OK:
		return "Game saved, but the older backup could not be removed; manual cleanup is needed."
	return ""

func load_game(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return "No save could be opened."
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return "Save contains invalid JSON."
	var parsed: Variant = json.data
	if not parsed is Dictionary or (parsed.get("version") != 1 and parsed.get("version") != 2 and parsed.get("version") != 3):
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
	var loaded_politics = Politics.new()
	if parsed.version == 2 or parsed.version == 3:
		var political_data: Variant = parsed.get("politics")
		if parsed.version == 2 and political_data is Dictionary and political_data.get("groups") is Array:
			political_data = political_data.duplicate(true)
			for group in political_data.groups:
				if group is Dictionary and group.has("approval"):
					group.raw_approval = group.approval
		if not loaded_politics.import_state(political_data) or absf(loaded_politics.approval() - float(c.approval)) > 0.001:
			return "Save has invalid political data."
	else:
		for group in loaded_politics.groups:
			group.approval = float(c.approval)
			group.raw_approval = float(c.approval)
	date = {"year": year, "month": month, "day": day}
	country = c.duplicate(true)
	country.population = int(c.population)
	politics = loaded_politics
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
	politics.apply_tax_change(rate - previous)
	country.approval = politics.approval()
	country.income_tax_rate = rate
	add_event("Income tax changed from %.1f%% to %.1f%%." % [previous * 100.0, rate * 100.0])
	return true

func vote_procurement() -> bool:
	var votes: int = politics.votes_for_policy()
	if politics.vote_procurement():
		add_event("Procurement policy passed with %d of 100 seats; implementation begins." % votes)
		return true
	add_event("Procurement vote failed or policy already active (%d of 100 seats)." % votes)
	return false

func hold_election() -> void:
	politics.election()
	add_event("Illustrative election held: government won %d of 100 seats." % politics.parties[0].seats)

func set_annual_spending(amount: float) -> bool:
	if not is_finite(amount) or amount < 0.0 or amount > 10000000000.0:
		return false
	var previous: float = country.annual_spending
	if is_equal_approx(previous, amount):
		return true
	country.annual_spending = amount
	add_event("Annual spending changed from $%.0f to $%.0f." % [previous, amount])
	return true
