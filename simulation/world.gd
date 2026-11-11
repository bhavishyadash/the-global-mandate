extends RefCounted

const Politics = preload("res://simulation/politics.gd")
const Services = preload("res://simulation/services.gd")
const Institutions = preload("res://simulation/institutions.gd")
const Diplomacy = preload("res://simulation/diplomacy.gd")
const PROCUREMENT_ANNUAL_COST := 10000000.0
const ANNUAL_DEBT_RATE := 0.03
const TEST_TAXABLE_BASE := 2000000000.0
const ADDITIONAL_TAXES := {"consumption": {"field": "consumption_tax_rate", "base": 1500000000.0}, "corporate": {"field": "corporate_tax_rate", "base": 1000000000.0}}
const CATEGORY_SHARES := {"Health": 0.30, "Education": 0.25, "Security": 0.20, "Infrastructure": 0.15, "Administration": 0.10}
var politics = Politics.new()
var services = Services.new()
var institutions = Institutions.new()
var diplomacy = Diplomacy.new()

# All values here are fictional test data; rates are annual USD.
const INITIAL_DATE := {"year": 2026, "month": 1, "day": 1}
var date: Dictionary = INITIAL_DATE.duplicate()
var country := {
	"name": "Federal Republic (test scenario)",
	"population": 10000000,
	"treasury": 1000000000.0,
	"debt": 0.0,
	"annual_revenue": 1200000000.0,
	"annual_spending": 1100000000.0,
	"spending_categories": {"Health": 330000000.0, "Education": 275000000.0, "Security": 220000000.0, "Infrastructure": 165000000.0, "Administration": 110000000.0},
	"income_tax_rate": 0.20,
	"consumption_tax_rate": 0.0,
	"corporate_tax_rate": 0.0,
	"approval": 50.0,
}
var fiscal: Dictionary = _new_fiscal_period(false)
var previous_fiscal: Dictionary = {}
var events: Array[String] = ["Scenario started. All figures are fictional test data."]
const MAX_EVENTS := 200

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
	var procurement: float = PROCUREMENT_ANNUAL_COST if politics.procurement_policy and politics.procurement_progress >= 100 else 0.0
	return procurement + diplomacy.annual_agreement_cost()

func daily_balance() -> float:
	return annual_balance() / (366.0 if is_leap_year(date.year) else 365.0)

func forecast_fiscal(days: int, changes: Dictionary = {}) -> Dictionary:
	# Simulate a separate copy: no files, live state or random outcomes are changed.
	if days < 1 or days > 366 or date.year >= 9999:
		return {}
	var future = get_script().new()
	future.date = date.duplicate(true)
	future.country = country.duplicate(true)
	if not future.politics.import_state(politics.export_state()) or not future.services.import_state(services.export_state()) or not future.institutions.import_state(institutions.export_state()) or not future.diplomacy.import_state(diplomacy.export_state()):
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
				add_event("Cash exhausted; government borrowing began.")
			country.debt += borrowing
			fiscal.borrowed += borrowing
	else:
		var repayment: float = minf(country.debt, balance)
		country.debt -= repayment
		fiscal.repaid += repayment
		country.treasury += balance - repayment
	services.advance_day(country.spending_categories, country.population)
	politics.apply_service_bonuses(services.group_bonuses())
	country.approval = politics.approval()
	if politics.advance_day():
		add_event("Procurement policy implementation completed.")
	var institutional_event: String = institutions.advance_day()
	if not institutional_event.is_empty():
		add_event(institutional_event)
	var diplomatic_event: String = diplomacy.advance_day()
	if not diplomatic_event.is_empty():
		add_event(diplomatic_event)
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
	file.store_string(JSON.stringify({"version": 11, "diplomacy": diplomacy.export_state(), "fiscal": fiscal, "previous_fiscal": previous_fiscal, "date": date, "country": country, "events": events, "politics": politics.export_state(), "services": services.export_state(), "institutions": institutions.export_state()}))
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
	if not parsed is Dictionary or (parsed.get("version") != 1 and parsed.get("version") != 2 and parsed.get("version") != 3 and parsed.get("version") != 4 and parsed.get("version") != 5 and parsed.get("version") != 6 and parsed.get("version") != 7 and parsed.get("version") != 8 and parsed.get("version") != 9 and parsed.get("version") != 10 and parsed.get("version") != 11):
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
	var loaded_politics = Politics.new()
	var loaded_services = Services.new()
	var loaded_institutions = Institutions.new()
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
	fiscal = loaded_fiscal
	previous_fiscal = loaded_previous
	country = c.duplicate(true)
	country.population = int(c.population)
	politics = loaded_politics
	services = loaded_services
	institutions = loaded_institutions
	diplomacy = loaded_diplomacy
	events.clear()
	for event in e:
		events.append(event)
	return ""

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
	add_event("Income tax changed from %.1f%% to %.1f%%." % [previous * 100.0, rate * 100.0])
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
	add_event("%s tax changed from %.1f%% to %.1f%%." % [kind.capitalize(), previous * 100.0, rate * 100.0])
	return true

func vote_procurement() -> bool:
	var votes: int = politics.votes_for_policy()
	if politics.vote_procurement():
		add_event("Procurement policy passed with %d of 100 seats; implementation begins." % votes)
		return true
	add_event("Procurement vote failed or policy already active (%d of 100 seats)." % votes)
	return false

func issue_directive(kind: String) -> bool:
	if not institutions.issue(kind):
		return false
	add_event("Executive issued the %s directive; the fictional court review began." % institutions.CASES[kind].name)
	return true

func start_diplomatic_talks(partner: String, proposal: String = "dialogue") -> bool:
	if not diplomacy.start_talks(partner, proposal):
		return false
	add_event("Opened %s talks with %s." % [diplomacy.PROPOSALS[proposal].name, diplomacy.PARTNERS[partner]])
	return true

func cancel_diplomatic_talks() -> bool:
	var partner: String = diplomacy.active
	if not diplomacy.cancel_talks():
		return false
	add_event("Cancelled diplomatic talks with %s." % diplomacy.PARTNERS[partner])
	return true

func end_cooperation(partner: String) -> bool:
	if not diplomacy.end_agreement(partner):
		return false
	add_event("Ended cooperation agreement with %s; relations fell by 5 test points." % diplomacy.PARTNERS[partner])
	return true

func revoke_directive() -> bool:
	if not institutions.revoke():
		return false
	add_event("Executive revoked the %s directive; implementation stopped." % institutions.CASES[institutions.kind].name)
	return true

func vote_procurement_repeal() -> bool:
	var votes: int = politics.votes_for_repeal()
	if politics.repeal_procurement():
		add_event("Procurement repeal passed with %d of 100 seats; implementation and recurring costs stopped." % votes)
		return true
	add_event("Procurement repeal failed or policy not active (%d of 100 seats)." % votes)
	return false

func _conduct_election() -> void:
	politics.election()
	add_event("Illustrative election held: government won %d of 100 seats." % politics.parties[0].seats)

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
	add_event("Annual spending changed from $%.0f to $%.0f." % [previous, amount])
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
	add_event("%s annual spending changed from $%.0f to $%.0f." % [category, previous, amount])
	return true
