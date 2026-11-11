extends RefCounted

const Politics = preload("res://simulation/politics.gd")
const Services = preload("res://simulation/services.gd")
const Institutions = preload("res://simulation/institutions.gd")
const Diplomacy = preload("res://simulation/diplomacy.gd")
const Healthcare = preload("res://simulation/healthcare.gd")
const Congress = preload("res://simulation/congress.gd")
const Scenario = preload("res://simulation/scenario.gd")
const PolicyRules = preload("res://simulation/policy_rules.gd")
const DEFAULT_SCENARIO := "res://data/scenarios/test_republic.json"
const ANNUAL_DEBT_RATE := 0.03
const TEST_TAXABLE_BASE := 2000000000.0
const ADDITIONAL_TAXES := {"consumption": {"field": "consumption_tax_rate", "base": 1500000000.0}, "corporate": {"field": "corporate_tax_rate", "base": 1000000000.0}}
const CATEGORY_SHARES := {"Health": 0.30, "Education": 0.25, "Security": 0.20, "Infrastructure": 0.15, "Administration": 0.10}
var politics = Politics.new()
var services = Services.new()
var institutions = Institutions.new()
var diplomacy = Diplomacy.new()
var healthcare = Healthcare.new()
var congress = Congress.new()
var policy_rules: Dictionary = PolicyRules.defaults()

# All values here are fictional test data; rates are annual USD.
const INITIAL_DATE := {"year": 2026, "month": 1, "day": 1}
var date: Dictionary = INITIAL_DATE.duplicate()
var country: Dictionary = {}
var scenario_id := ""
var initialization_error := ""
var random_seed_value := Scenario.DEFAULT_SEED
var random_state := Scenario.DEFAULT_SEED
var fiscal: Dictionary = _new_fiscal_period(false)
var previous_fiscal: Dictionary = {}
var events: Array[String] = ["Scenario started. All figures are fictional test data."]
var event_records: Array = []
const MAX_EVENTS := 200
const EVENT_CATEGORIES := ["scenario", "finance", "policy", "institution", "diplomacy", "election", "general", "legacy"]

func _init() -> void:
	var error := apply_scenario(Scenario.read_file(DEFAULT_SCENARIO))
	if not error.is_empty():
		initialization_error = error
		push_error("Default scenario could not be loaded: " + error)

func apply_scenario(data: Variant) -> String:
	var error: String = Scenario.validate(data)
	if not error.is_empty():
		return error
	# Validate all data before replacing any live state.
	scenario_id = data.id
	random_seed_value = int(data.get("seed", Scenario.DEFAULT_SEED))
	random_state = random_seed_value
	initialization_error = ""
	date = {"year": int(data.date.year), "month": int(data.date.month), "day": int(data.date.day)}
	country = data.country.duplicate(true)
	country.population = int(country.population)
	politics = Politics.new()
	services = Services.new()
	institutions = Institutions.new()
	diplomacy = Diplomacy.new()
	healthcare = Healthcare.new()
	congress = Congress.new()
	policy_rules = data.policy_rules.duplicate(true) if data.version >= 5 else PolicyRules.defaults()
	if data.version >= 3:
		healthcare.configure(data.healthcare_rules)
	if data.version >= 4:
		institutions.configure(data.institution_rules)
	if data.version >= 2:
		politics.import_state(data.politics)
		services.import_state(data.services)
		institutions.import_state(data.institutions)
		diplomacy.import_state(data.diplomacy)
	fiscal = _new_fiscal_period(date.month != 1 or date.day != 1)
	previous_fiscal = {}
	events = ["Scenario started. All figures are fictional test data."]
	event_records = [{"category": "scenario", "date": date.duplicate(), "text": events[0], "cause": "scenario_started", "severity": "info"}]
	return ""

func next_random_u32() -> int:
	# 32-bit LCG, specified explicitly for stable replay across platforms.
	# It is for game simulation only, not cryptographic use.
	random_state = (1664525 * random_state + 1013904223) & 0xffffffff
	return random_state

func next_random_fraction() -> float:
	return next_random_u32() / 4294967296.0

func annual_balance() -> float:
	return total_annual_revenue() - country.annual_spending - policy_annual_cost() - debt_interest()

func total_annual_revenue() -> float:
	return country.annual_revenue + diplomacy.annual_partner_contribution()

func debt_interest() -> float:
	return country.debt * ANNUAL_DEBT_RATE

func income_tax_revenue() -> float:
	return country.income_tax_rate * TEST_TAXABLE_BASE

func additional_tax_revenue(kind: String) -> float:
	if not ADDITIONAL_TAXES.has(kind):
		return 0.0
	var spec: Dictionary = ADDITIONAL_TAXES[kind]
	return float(country[spec.field]) * float(spec.base)

func policy_annual_cost() -> float:
	var procurement: float = policy_rules.procurement_annual_cost if politics.procurement_policy and politics.procurement_progress >= 100 else 0.0
	var reporting: float = policy_rules.reporting_annual_cost if reporting_effect_active() else 0.0
	return procurement + reporting + diplomacy.annual_agreement_cost() + healthcare.annual_cost()

func reporting_effect_active() -> bool:
	return institutions.kind == "reporting" and institutions.status == "implemented"

func service_target(category: String, spending: float) -> float:
	return services.target(category, spending, country.population, float(policy_rules.reporting_admin_target_bonus) if reporting_effect_active() else 0.0, healthcare.health_bonus())

func daily_balance() -> float:
	return annual_balance() / (366.0 if is_leap_year(date.year) else 365.0)

func forecast_fiscal(days: int, changes: Dictionary = {}) -> Dictionary:
	# Simulate a separate copy: no files, live state or random outcomes are changed.
	if days < 1 or days > 366 or date.year >= 9999:
		return {}
	var future = get_script().new()
	future.date = date.duplicate(true)
	future.country = country.duplicate(true)
	future.scenario_id = scenario_id
	future.random_seed_value = random_seed_value
	future.random_state = random_state
	future.policy_rules = policy_rules.duplicate(true)
	future.healthcare.configure(healthcare.rules)
	future.institutions.configure(institutions.rules)
	if not future.politics.import_state(politics.export_state()) or not future.services.import_state(services.export_state()) or not future.institutions.import_state(institutions.export_state()) or not future.diplomacy.import_state(diplomacy.export_state()) or not future.healthcare.import_state(healthcare.export_state()):
		return {}
	for key in changes:
		if key not in ["income_tax", "consumption_tax", "corporate_tax", "spending"] or not _is_number(changes[key]):
			return {}
	if changes.has("income_tax") and not future.set_income_tax(float(changes.income_tax)):
		return {}
	for kind in ["consumption", "corporate"]:
		var key: String = kind + "_tax"
		if changes.has(key) and not future.set_additional_tax(kind, float(changes[key])):
			return {}
	if changes.has("spending") and not future.set_annual_spending(float(changes.spending)):
		return {}
	var result := {"days": days, "revenue": 0.0, "spending": 0.0, "policy": 0.0, "interest": 0.0, "first_cash_exhaustion_day": 0}
	for i in range(days):
		var divisor := 366.0 if is_leap_year(future.date.year) else 365.0
		result.revenue += future.total_annual_revenue() / divisor
		result.spending += future.country.annual_spending / divisor
		result.policy += future.policy_annual_cost() / divisor
		result.interest += future.debt_interest() / divisor
		future.advance_day()
		if result.first_cash_exhaustion_day == 0 and future.country.treasury <= 0.0:
			result.first_cash_exhaustion_day = i + 1
	result.end_date = future.date.duplicate()
	result.cash = future.country.treasury
	result.debt = future.country.debt
	result.approval = future.country.approval
	return result

func advance_day() -> void:
	var divisor := 366.0 if is_leap_year(date.year) else 365.0
	var revenue: float = total_annual_revenue() / divisor
	var spending: float = country.annual_spending / divisor
	var policy: float = policy_annual_cost() / divisor
	var interest: float = debt_interest() / divisor
	var balance := revenue - spending - policy - interest
	fiscal.days += 1
	fiscal.revenue += revenue
	fiscal.spending += spending
	fiscal.policy += policy
	fiscal.interest += interest
	if balance < 0.0:
		var expense := -balance
		var cash_used: float = minf(country.treasury, expense)
		country.treasury -= cash_used
		var borrowing := expense - cash_used
		if borrowing > 0.0:
			if country.debt <= 0.0:
				add_event("Cash exhausted; government borrowing began.", "finance", "cash_exhausted", "warning")
			country.debt += borrowing
			fiscal.borrowed += borrowing
	else:
		var repayment: float = minf(country.debt, balance)
		country.debt -= repayment
		fiscal.repaid += repayment
		country.treasury += balance - repayment
	services.advance_day(country.spending_categories, country.population, float(policy_rules.reporting_admin_target_bonus) if reporting_effect_active() else 0.0, healthcare.health_bonus())
	politics.apply_service_bonuses(services.group_bonuses())
	country.approval = politics.approval()
	if politics.advance_day(int(policy_rules.procurement_progress_per_day)):
		add_event("Procurement policy implementation completed.", "policy", "procurement_implemented")
	if healthcare.advance_day(services.levels.Administration):
		add_event("Healthcare program reached full implementation.", "policy", "healthcare_implemented")
	var institutional_event: String = institutions.advance_day()
	if not institutional_event.is_empty():
		add_event(institutional_event, "institution", "directive_" + institutions.status)
	var diplomatic_event: String = diplomacy.advance_day()
	if not diplomatic_event.is_empty():
		add_event(diplomatic_event, "diplomacy", "negotiation_update")
	date.day += 1
	if date.day > days_in_month(date.year, date.month):
		date.day = 1
		date.month += 1
		if date.month > 12:
			date.month = 1
			previous_fiscal = fiscal.duplicate(true)
			fiscal = _new_fiscal_period(false)
			date.year += 1
			if date.year >= 2030 and (date.year - 2030) % 4 == 0:
				_conduct_election()

func next_election_year() -> int:
	if date.year < 2030:
		return 2030
	return date.year + 4 - ((date.year - 2030) % 4)

func add_event(message: String, category: String = "general", cause: String = "unspecified", severity: String = "info") -> void:
	var text := "%04d-%02d-%02d: %s" % [date.year, date.month, date.day, message]
	if category not in EVENT_CATEGORIES or category == "legacy":
		category = "general"
	events.push_front(text)
	if not Scenario._id(cause):
		cause = "unspecified"
	if severity not in ["info", "warning", "error"]:
		severity = "info"
	event_records.push_front({"category": category, "date": date.duplicate(), "text": text, "cause": cause, "severity": severity})
	if events.size() > MAX_EVENTS:
		events.resize(MAX_EVENTS)
		event_records.resize(MAX_EVENTS)

func filtered_events(category: String = "") -> Array:
	var result: Array = []
	for record in event_records:
		if category.is_empty() or record.category == category:
			result.append(record.duplicate(true))
	return result

static func is_leap_year(year: int) -> bool:
	return year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)

static func days_in_month(year: int, month: int) -> int:
	if month == 2:
		return 29 if is_leap_year(year) else 28
	return 30 if month in [4, 6, 9, 11] else 31

func export_snapshot() -> Dictionary:
	# Return detached data so consumers cannot mutate the running world through
	# an exported snapshot. The same representation is used for save files.
	return {"version": 21, "congress": congress.export_state(), "policy_rules": policy_rules.duplicate(true), "institution_rules": institutions.rules.duplicate(true), "healthcare_rules": healthcare.rules.duplicate(true), "healthcare": healthcare.export_state(), "scenario_id": scenario_id, "random_seed": random_seed_value, "random_state": random_state, "event_records": event_records.duplicate(true), "diplomacy": diplomacy.export_state(), "fiscal": fiscal.duplicate(true), "previous_fiscal": previous_fiscal.duplicate(true), "date": date.duplicate(true), "country": country.duplicate(true), "events": events.duplicate(), "politics": politics.export_state(), "services": services.export_state(), "institutions": institutions.export_state()}

func save_game(path: String, rename_operation: Callable = Callable(), write_operation: Callable = Callable()) -> String:
	var temporary := path + ".tmp"
	if FileAccess.file_exists(temporary) or DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(temporary)):
		return "A temporary save already exists; inspect it before saving."
	var error := _save_write(temporary, JSON.stringify(export_snapshot()), write_operation)
	if error != OK:
		if FileAccess.file_exists(temporary):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary))
		return "Could not finish writing the save file."
	var absolute_path := ProjectSettings.globalize_path(path)
	var absolute_temp := ProjectSettings.globalize_path(temporary)
	# A valid previous save must not be replaced by a snapshot that our own
	# loader would reject. Validate before moving either primary or backup.
	var candidate = get_script().new()
	var validation_error: String = candidate.load_game(temporary)
	if not validation_error.is_empty():
		DirAccess.remove_absolute(absolute_temp)
		return "Game state cannot be saved: " + validation_error
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
				DirAccess.remove_absolute(absolute_temp)
				return "An interrupted backup rotation needs manual recovery before saving."
			if FileAccess.file_exists(backup):
				if _save_rename(backup, previous_backup, rename_operation) != OK:
					DirAccess.remove_absolute(absolute_temp)
					return "Could not preserve the previous backup."
				retained_backup = true
			displaced = backup
		else:
			displaced = absolute_path + ".invalid"
			if FileAccess.file_exists(displaced):
				DirAccess.remove_absolute(absolute_temp)
				return "A previous invalid save already exists; move it before saving again."
		if _save_rename(absolute_path, displaced, rename_operation) != OK:
			if retained_backup:
				_save_rename(previous_backup, backup, rename_operation)
			DirAccess.remove_absolute(absolute_temp)
			return "Could not preserve the existing save."
	if _save_rename(absolute_temp, absolute_path, rename_operation) != OK:
		if not displaced.is_empty() and FileAccess.file_exists(displaced):
			_save_rename(displaced, absolute_path, rename_operation)
		if retained_backup and not FileAccess.file_exists(backup):
			_save_rename(previous_backup, backup, rename_operation)
		return "Could not finish saving; the previous save was retained if possible."
	if retained_backup and DirAccess.remove_absolute(previous_backup) != OK:
		return "Game saved, but the older backup could not be removed; manual cleanup is needed."
	return ""

static func _save_rename(source: String, destination: String, operation: Callable) -> Error:
	# The optional callable allows deterministic filesystem failure tests; the
	# production path always uses the OS rename implementation.
	return operation.call(source, destination) if operation.is_valid() else DirAccess.rename_absolute(source, destination)

static func _save_write(path: String, contents: String, operation: Callable) -> Error:
	if operation.is_valid():
		return operation.call(path, contents)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(contents)
	file.flush()
	var error := file.get_error()
	file.close()
	return error

func load_game(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return "No save could be opened."
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return "Save contains invalid JSON."
	return import_snapshot(json.data)

func import_snapshot(parsed: Variant) -> String:
	# Validate into temporary subsystem objects before replacing live state.
	if not parsed is Dictionary or not _is_whole_number(parsed.get("version")) or parsed.version < 1 or parsed.version > 21:
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
	c = c.duplicate(true)
	var loaded_scenario_id := "test_republic"
	var loaded_seed := Scenario.DEFAULT_SEED
	var loaded_random_state := Scenario.DEFAULT_SEED
	if parsed.version >= 14:
		for key in ["random_seed", "random_state"]:
			if not _is_whole_number(parsed.get(key)) or parsed[key] < 0 or parsed[key] > Scenario.MAX_SEED:
				return "Save has invalid random state."
		loaded_seed = int(parsed.random_seed)
		loaded_random_state = int(parsed.random_state)
	if parsed.version < 12:
		c.id = "test_republic"
	else:
		if not Scenario._id(parsed.get("scenario_id")) or not Scenario._id(c.get("id")):
			return "Save has invalid scenario or country identity."
		loaded_scenario_id = parsed.scenario_id
	if parsed.version < 6:
		c.consumption_tax_rate = 0.0
		c.corporate_tax_rate = 0.0
	else:
		for kind in ADDITIONAL_TAXES:
			var field: String = ADDITIONAL_TAXES[kind].field
			if not _is_number(c.get(field)) or c[field] < 0.0 or c[field] > 0.60:
				return "Save has invalid additional tax data."
	if parsed.version < 4:
		c.debt = maxf(0.0, -float(c.treasury))
		c.treasury = maxf(0.0, float(c.treasury))
		c.spending_categories = _split_spending(float(c.annual_spending))
	else:
		if not _is_number(c.get("debt")) or c.debt < 0.0 or c.treasury < 0.0 or not c.get("spending_categories") is Dictionary:
			return "Save has invalid budget data."
		var categories: Dictionary = c.spending_categories
		if categories.size() != CATEGORY_SHARES.size():
			return "Save has invalid spending categories."
		var total := 0.0
		for category in CATEGORY_SHARES:
			if not _is_number(categories.get(category)) or categories[category] < 0.0:
				return "Save has invalid spending categories."
			total += float(categories[category])
		if absf(total - float(c.annual_spending)) > 0.01:
			return "Save spending categories do not match the budget."
	for event in e:
		if not event is String:
			return "Save has invalid event data."
	var loaded_records: Array = []
	if parsed.version >= 13:
		var records: Variant = parsed.get("event_records")
		if parsed.version < 17 and records is Array:
			records = records.duplicate(true)
			for record in records:
				if record is Dictionary:
					record.cause = "legacy_unknown"
					record.severity = "info"
		if not _valid_event_records(records, e):
			return "Save has invalid structured event data."
		loaded_records = records.duplicate(true)
		for record in loaded_records:
			if record.date is Dictionary:
				record.date = {"year": int(record.date.year), "month": int(record.date.month), "day": int(record.date.day)}
	else:
		for event in e:
			loaded_records.append({"category": "legacy", "date": null, "text": event, "cause": "legacy_unknown", "severity": "info"})
	var loaded_politics = Politics.new()
	var loaded_policy_rules: Variant = parsed.get("policy_rules") if parsed.version >= 20 else PolicyRules.defaults()
	if not PolicyRules.valid(loaded_policy_rules):
		return "Save has invalid baseline policy rules."
	var loaded_services = Services.new()
	var loaded_institutions = Institutions.new()
	if parsed.version >= 19 and not loaded_institutions.configure(parsed.get("institution_rules")):
		return "Save has invalid institutional rules."
	var loaded_healthcare = Healthcare.new()
	if parsed.version >= 18 and not loaded_healthcare.configure(parsed.get("healthcare_rules")):
		return "Save has invalid healthcare rules."
	if parsed.version >= 15:
		var healthcare_data: Variant = parsed.get("healthcare")
		if parsed.version == 15 and healthcare_data is Dictionary:
			healthcare_data = healthcare_data.duplicate(true)
			healthcare_data.appropriation = 1.0
		if not loaded_healthcare.import_state(healthcare_data):
			return "Save has invalid healthcare policy data."
	var loaded_congress = Congress.new()
	if parsed.version >= 21 and not loaded_congress.import_state(parsed.get("congress"), loaded_healthcare.rules.funding_options):
		return "Save has invalid congressional bill data."
	var loaded_diplomacy = Diplomacy.new()
	if parsed.version >= 9:
		var diplomatic_data: Variant = parsed.get("diplomacy")
		if parsed.version == 9 and diplomatic_data is Dictionary and diplomatic_data.get("active") is String:
			diplomatic_data = diplomatic_data.duplicate(true)
			diplomatic_data.proposal = "" if diplomatic_data.get("active", "").is_empty() else "dialogue"
		if parsed.version < 11 and diplomatic_data is Dictionary:
			diplomatic_data = diplomatic_data.duplicate(true)
			diplomatic_data.agreements = {"maritime": 0, "northern": 0}
		if not loaded_diplomacy.import_state(diplomatic_data):
			return "Save has invalid diplomatic data."
	if parsed.version >= 7 and not loaded_institutions.import_state(parsed.get("institutions")):
		return "Save has invalid institutional data."
	if parsed.version >= 5 and not loaded_services.import_state(parsed.get("services")):
		return "Save has invalid service data."
	if parsed.version >= 2:
		var political_data: Variant = parsed.get("politics")
		if parsed.version < 5 and political_data is Dictionary and political_data.get("groups") is Array:
			political_data = political_data.duplicate(true)
			for group in political_data.groups:
				if group is Dictionary:
					if parsed.version == 2 and group.has("approval"):
						group.raw_approval = group.approval
					group.service_bonus = 0.0
		if not loaded_politics.import_state(political_data) or absf(loaded_politics.approval() - float(c.approval)) > 0.001:
			return "Save has invalid political data."
	else:
		for group in loaded_politics.groups:
			group.approval = float(c.approval)
			group.raw_approval = float(c.approval)
	if parsed.version >= 5:
		var bonuses: Array = loaded_services.group_bonuses()
		for i in range(loaded_politics.groups.size()):
			if absf(loaded_politics.groups[i].service_bonus - bonuses[i]) > 0.001:
				return "Save has inconsistent service effects."
	var loaded_fiscal: Dictionary = _new_fiscal_period(true)
	var loaded_previous: Dictionary = {}
	if parsed.version >= 8:
		if not _valid_fiscal_period(parsed.get("fiscal")) or not parsed.get("previous_fiscal") is Dictionary:
			return "Save has invalid fiscal history."
		if not parsed.previous_fiscal.is_empty() and not _valid_fiscal_period(parsed.previous_fiscal):
			return "Save has invalid fiscal history."
		loaded_fiscal = parsed.fiscal.duplicate(true)
		loaded_previous = parsed.previous_fiscal.duplicate(true)
	date = {"year": year, "month": month, "day": day}
	scenario_id = loaded_scenario_id
	random_seed_value = loaded_seed
	random_state = loaded_random_state
	fiscal = loaded_fiscal
	previous_fiscal = loaded_previous
	country = c.duplicate(true)
	country.population = int(c.population)
	politics = loaded_politics
	services = loaded_services
	institutions = loaded_institutions
	healthcare = loaded_healthcare
	congress = loaded_congress
	policy_rules = loaded_policy_rules.duplicate(true)
	diplomacy = loaded_diplomacy
	events.clear()
	for event in e:
		events.append(event)
	event_records = loaded_records
	return ""

static func _valid_event_records(records: Variant, texts: Array) -> bool:
	if not records is Array or records.size() != texts.size():
		return false
	for i in range(records.size()):
		var record: Variant = records[i]
		if not record is Dictionary or record.size() != 5 or not record.get("category") is String or record.category not in EVENT_CATEGORIES or not record.get("text") is String or record.text != texts[i] or not record.has("date") or not Scenario._id(record.get("cause")) or record.get("severity") not in ["info", "warning", "error"]:
			return false
		var d: Variant = record.date
		if record.category == "legacy":
			if d != null:
				return false
			continue
		if not d is Dictionary:
			return false
		for key in ["year", "month", "day"]:
			if not _is_whole_number(d.get(key)):
				return false
		var year := int(d.year)
		var month := int(d.month)
		if year < 1 or year > 9999 or month < 1 or month > 12 or d.day < 1 or d.day > days_in_month(year, month):
			return false
	return true

static func _new_fiscal_period(partial: bool) -> Dictionary:
	return {"days": 0, "partial": partial, "revenue": 0.0, "spending": 0.0, "policy": 0.0, "interest": 0.0, "borrowed": 0.0, "repaid": 0.0}

static func _valid_fiscal_period(period: Variant) -> bool:
	if not period is Dictionary or not period.get("partial") is bool or not _is_whole_number(period.get("days")) or period.days < 0 or period.days > 366:
		return false
	for key in ["revenue", "spending", "policy", "interest", "borrowed", "repaid"]:
		if not _is_number(period.get(key)) or period[key] < 0.0:
			return false
	return true

static func _is_whole_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value))

static func _is_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

static func _split_spending(amount: float) -> Dictionary:
	var result := {}
	var allocated := 0.0
	for category in CATEGORY_SHARES:
		if category == "Administration":
			result[category] = amount - allocated
		else:
			result[category] = amount * CATEGORY_SHARES[category]
			allocated += result[category]
	return result

func preview_income_tax(rate: float) -> Dictionary:
	if not is_finite(rate) or rate < 0.0 or rate > 0.60:
		return {}
	var preview_politics = Politics.new()
	if not preview_politics.import_state(politics.export_state()):
		return {}
	var delta: float = rate - country.income_tax_rate
	var projected_revenue: float = country.annual_revenue + delta * TEST_TAXABLE_BASE
	if not is_finite(projected_revenue) or projected_revenue < 0.0:
		return {}
	preview_politics.apply_tax_change(delta)
	return {
		"annual_revenue": projected_revenue + diplomacy.annual_partner_contribution(),
		"approval": preview_politics.approval(),
		"groups": preview_politics.groups.duplicate(true),
	}

func set_income_tax(rate: float) -> bool:
	if preview_income_tax(rate).is_empty():
		return false
	var previous: float = country.income_tax_rate
	if is_equal_approx(rate, previous):
		return true
	# Placeholder: $2 billion taxable base, other revenue held constant.
	country.annual_revenue += (rate - previous) * TEST_TAXABLE_BASE
	politics.apply_tax_change(rate - previous)
	country.approval = politics.approval()
	country.income_tax_rate = rate
	add_event("Income tax changed from %.1f%% to %.1f%%." % [previous * 100.0, rate * 100.0], "finance", "income_tax_changed")
	return true

func preview_additional_tax(kind: String, rate: float) -> Dictionary:
	if not ADDITIONAL_TAXES.has(kind) or not is_finite(rate) or rate < 0.0 or rate > 0.60:
		return {}
	var spec: Dictionary = ADDITIONAL_TAXES[kind]
	var delta: float = rate - float(country[spec.field])
	var projected_revenue: float = country.annual_revenue + delta * float(spec.base)
	if not is_finite(projected_revenue) or projected_revenue < 0.0:
		return {}
	var preview_politics = Politics.new()
	if not preview_politics.import_state(politics.export_state()):
		return {}
	preview_politics.apply_additional_tax_change(kind, delta)
	return {"annual_revenue": projected_revenue + diplomacy.annual_partner_contribution(), "approval": preview_politics.approval(), "groups": preview_politics.groups.duplicate(true)}

func set_additional_tax(kind: String, rate: float) -> bool:
	if preview_additional_tax(kind, rate).is_empty():
		return false
	var spec: Dictionary = ADDITIONAL_TAXES[kind]
	var previous: float = country[spec.field]
	if is_equal_approx(previous, rate):
		return true
	country.annual_revenue += (rate - previous) * float(spec.base)
	politics.apply_additional_tax_change(kind, rate - previous)
	country.approval = politics.approval()
	country[spec.field] = rate
	add_event("%s tax changed from %.1f%% to %.1f%%." % [kind.capitalize(), previous * 100.0, rate * 100.0], "finance", "additional_tax_changed")
	return true

func preview_healthcare(amount: float, repeal: bool = false) -> Dictionary:
	if not healthcare.valid_funding(amount) or (repeal and (not healthcare.active or amount != healthcare.funding)):
		return {}
	var positions: Array = healthcare.support(politics.parties, amount, repeal)
	var seats: int = healthcare.votes(positions)
	var current_cost: float = healthcare.annual_cost()
	var next_cost: float = 0.0 if repeal else amount * (healthcare.appropriation if healthcare.active else 1.0)
	return {"positions": positions, "votes": seats, "passes": seats > 50, "annual_cost": next_cost, "annual_balance": annual_balance() + current_cost - next_cost, "administration": services.levels.Administration, "progress": healthcare.progress, "full_health_target_bonus": float(healthcare.rules.target_per_100m) * amount / 100000000.0 if not repeal else 0.0}

func introduce_congress_bill(amount: float) -> bool:
	if not congress.introduce(amount, healthcare.rules.funding_options):
		return false
	add_event("Healthcare bill introduced in the fictional House ($%.0f/year)." % amount, "policy", "congress_bill_introduced")
	return true

func congress_vote() -> bool:
	var before: String = congress.stage
	if not congress.vote(healthcare.rules.funding_options):
		return false
	add_event("Congressional vote: %s → %s." % [before, congress.stage], "policy", "congress_vote")
	if congress.stage == "enacted":
		_enact_congress_healthcare()
	return true

func congress_president(action: String) -> bool:
	if not congress.presidential_action(action):
		return false
	add_event("President chose to %s the healthcare bill." % action, "policy", "presidential_action")
	if congress.stage == "enacted":
		_enact_congress_healthcare()
	return true

func _enact_congress_healthcare() -> void:
	if healthcare.active and congress.funding > healthcare.funding:
		healthcare.progress *= healthcare.funding / congress.funding
	healthcare.active = true
	healthcare.funding = congress.funding
	add_event("Healthcare authorization enacted through the bicameral prototype.", "policy", "congress_healthcare_enacted")

func vote_healthcare(amount: float) -> bool:
	var preview := preview_healthcare(amount)
	if preview.is_empty() or (healthcare.active and healthcare.funding == amount):
		return false
	if not preview.passes:
		add_event("Healthcare proposal failed with %d of 100 seats." % preview.votes, "policy", "healthcare_vote_failed", "warning")
		return false
	var amending: bool = healthcare.active
	if amending and amount > healthcare.funding:
		healthcare.progress *= healthcare.funding / amount
	healthcare.active = true
	healthcare.funding = amount
	add_event("Healthcare %s passed with %d of 100 seats; annual funding is $%.0f." % ["amendment" if amending else "proposal", preview.votes, amount], "policy", "healthcare_vote_passed")
	return true

func preview_healthcare_appropriation(fraction: float) -> Dictionary:
	if not healthcare.active or not is_finite(fraction) or fraction < 0.0 or fraction > 1.0:
		return {}
	var positions: Array = healthcare.appropriation_support(politics.parties, fraction)
	var seats: int = healthcare.votes(positions)
	var cost: float = healthcare.funding * fraction
	var daily_progress: float = minf(100.0 - healthcare.progress, clampf(services.levels.Administration / 50.0, 0.0, 2.0) * fraction * 100.0 / float(healthcare.rules.days_at_normal_capacity))
	return {"positions": positions, "votes": seats, "passes": seats > 50, "changed": not is_equal_approx(healthcare.appropriation, fraction), "annual_cost": cost, "annual_balance": annual_balance() + healthcare.annual_cost() - cost, "daily_progress": daily_progress, "health_bonus": float(healthcare.rules.target_per_100m) * healthcare.funding / 100000000.0 * fraction * healthcare.progress / 100.0}

func set_healthcare_appropriation(fraction: float) -> bool:
	var preview := preview_healthcare_appropriation(fraction)
	if preview.is_empty() or is_equal_approx(healthcare.appropriation, fraction):
		return false
	if not preview.passes:
		add_event("Healthcare appropriation vote for %.0f%% failed with %d of 100 seats; funding unchanged." % [fraction * 100.0, preview.votes], "finance", "appropriation_vote_failed", "warning")
		return false
	healthcare.appropriation = fraction
	add_event("Healthcare appropriation set to %.0f%% of authorization with %d of 100 seats." % [fraction * 100.0, preview.votes], "finance", "appropriation_vote_passed")
	return true

func repeal_healthcare() -> bool:
	if not healthcare.active:
		return false
	var preview := preview_healthcare(healthcare.funding, true)
	if not preview.passes:
		add_event("Healthcare repeal failed with %d of 100 seats." % preview.votes, "policy", "healthcare_repeal_failed", "warning")
		return false
	healthcare.active = false
	healthcare.funding = 0.0
	healthcare.progress = 0.0
	healthcare.appropriation = 1.0
	add_event("Healthcare repeal passed with %d of 100 seats; future costs stopped." % preview.votes, "policy", "healthcare_repealed")
	return true

func vote_procurement() -> bool:
	var votes: int = politics.votes_for_policy()
	if politics.vote_procurement():
		add_event("Procurement policy passed with %d of 100 seats; implementation begins." % votes, "policy", "procurement_vote_passed")
		return true
	add_event("Procurement vote failed or policy already active (%d of 100 seats)." % votes, "policy", "procurement_vote_unavailable", "warning")
	return false

func issue_directive(kind: String) -> bool:
	if not institutions.issue(kind):
		return false
	add_event("Executive issued the %s directive; the fictional court review began." % institutions.rules.cases[kind].name, "institution", "directive_issued")
	return true

func start_diplomatic_talks(partner: String, proposal: String = "dialogue") -> bool:
	if not diplomacy.start_talks(partner, proposal):
		return false
	add_event("Opened %s talks with %s." % [diplomacy.PROPOSALS[proposal].name, diplomacy.PARTNERS[partner]], "diplomacy", "talks_opened")
	return true

func cancel_diplomatic_talks() -> bool:
	var partner: String = diplomacy.active
	if not diplomacy.cancel_talks():
		return false
	add_event("Cancelled diplomatic talks with %s." % diplomacy.PARTNERS[partner], "diplomacy", "talks_cancelled")
	return true

func end_cooperation(partner: String) -> bool:
	if not diplomacy.end_agreement(partner):
		return false
	add_event("Ended cooperation agreement with %s; relations fell by 5 test points." % diplomacy.PARTNERS[partner], "diplomacy", "cooperation_ended")
	return true

func revoke_directive() -> bool:
	if not institutions.revoke():
		return false
	add_event("Executive revoked the %s directive; implementation stopped." % institutions.rules.cases[institutions.kind].name, "institution", "directive_revoked")
	return true

func vote_procurement_repeal() -> bool:
	var votes: int = politics.votes_for_repeal()
	if politics.repeal_procurement():
		add_event("Procurement repeal passed with %d of 100 seats; implementation and recurring costs stopped." % votes, "policy", "procurement_repealed")
		return true
	add_event("Procurement repeal failed or policy not active (%d of 100 seats)." % votes, "policy", "procurement_repeal_unavailable", "warning")
	return false

func _conduct_election() -> void:
	politics.election()
	add_event("Illustrative election held: government won %d of 100 seats." % politics.parties[0].seats, "election", "election_held")

func preview_annual_spending(amount: float) -> Dictionary:
	if not is_finite(amount) or amount < 0.0 or amount > 10000000000.0:
		return {}
	var balance: float = total_annual_revenue() - amount - policy_annual_cost() - debt_interest()
	var year_days := 366.0 if is_leap_year(date.year) else 365.0
	return {"annual_balance": balance, "daily_balance": balance / year_days}

func set_annual_spending(amount: float) -> bool:
	if preview_annual_spending(amount).is_empty():
		return false
	var previous: float = country.annual_spending
	if is_equal_approx(previous, amount):
		return true
	country.annual_spending = amount
	country.spending_categories = _split_spending(amount)
	add_event("Annual spending changed from $%.0f to $%.0f." % [previous, amount], "finance", "annual_spending_changed")
	return true

func preview_category_spending(category: String, amount: float) -> Dictionary:
	if not country.spending_categories.has(category) or not is_finite(amount) or amount < 0.0:
		return {}
	var total: float = country.annual_spending - country.spending_categories[category] + amount
	return preview_annual_spending(total)

func set_category_spending(category: String, amount: float) -> bool:
	if preview_category_spending(category, amount).is_empty():
		return false
	var previous: float = country.spending_categories[category]
	if is_equal_approx(previous, amount):
		return true
	country.spending_categories[category] = amount
	country.annual_spending += amount - previous
	add_event("%s annual spending changed from $%.0f to $%.0f." % [category, previous, amount], "finance", "category_spending_changed")
	return true
