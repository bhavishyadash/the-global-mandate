extends RefCounted

const World = preload("res://simulation/world.gd")
const Decisions = preload("res://simulation/decisions.gd")
const MAX_COUNTRIES := 250
const MAX_TALKS := 1000
const TALK_DAYS := 30
const RELATION_GAIN := 5.0
const COOPERATION_GAIN := 10.0
const COOPERATION_MIN_RELATION := 5.0
const COOPERATION_COST := 5000000.0
const AGREEMENT_DAYS := 365

# This is an experimental headless multi-country layer. Its bilateral
# relationships are separate from the older single-country diplomacy model.
var _countries: Dictionary = {}
var _relations: Dictionary = {}
var _talks: Dictionary = {}
var _agreements: Dictionary = {}
# Optional save metadata; it does not change simulation state.
var saved_controlled_id := ""

func initialize(scenarios: Variant) -> String:
	if not scenarios is Array or scenarios.is_empty() or scenarios.size() > MAX_COUNTRIES:
		return "A registry needs between 1 and 250 scenarios."
	var countries := {}
	var shared_date: Dictionary = {}
	for scenario in scenarios:
		var error: String = World.Scenario.validate(scenario)
		if not error.is_empty():
			return error
		var country = World.new()
		country.apply_scenario(scenario)
		var id: String = country.country.id
		if countries.has(id):
			return "Country IDs must be unique."
		if not shared_date.is_empty() and country.date != shared_date:
			return "Countries must start on the same date."
		shared_date = country.date.duplicate()
		countries[id] = country
	_countries = countries
	_relations = {}
	_talks = {}
	_agreements = {}
	saved_controlled_id = ""
	return ""

func country_ids() -> Array:
	var ids := _countries.keys()
	ids.sort()
	return ids

func country_snapshot(id: String) -> Dictionary:
	return _countries[id].export_snapshot() if _countries.has(id) else {}

# Internal live reference for the opt-in shared-world controller. Callers must
# advance time through the registry, not this country directly.
func controlled_country(id: String) -> Variant:
	return _countries.get(id)

func forecast_fiscal(id: String, days: int, changes: Dictionary = {}) -> Dictionary:
	if not _countries.has(id) or days < 1 or days > 366 or _countries[id].date.year >= 9999:
		return {}
	var future = get_script().new()
	if not future.import_snapshot(export_snapshot()).is_empty():
		return {}
	var country = future.controlled_country(id)
	if not country._apply_forecast_changes(changes):
		return {}
	var result := {"days": days, "revenue": 0.0, "spending": 0.0, "policy": 0.0, "interest": 0.0, "first_cash_exhaustion_day": 0}
	for i in range(days):
		var before: Dictionary = country.fiscal.duplicate(true)
		var year: int = country.date.year
		future.advance_day()
		# On New Year's Day the completed ledger moved to previous_fiscal.
		var after: Dictionary = country.previous_fiscal if country.date.year != year else country.fiscal
		for field in ["revenue", "spending", "policy", "interest"]:
			result[field] += float(after[field]) - float(before[field])
		if result.first_cash_exhaustion_day == 0 and country.country.treasury <= 0.0:
			result.first_cash_exhaustion_day = i + 1
	result.end_date = country.date.duplicate(true)
	result.cash = country.country.treasury
	result.debt = country.country.debt
	result.approval = country.country.approval
	result.population = country.country.population
	return result

func execute_country(id: String, request: Variant) -> Dictionary:
	if not _countries.has(id):
		return {"ok": false, "code": "unknown_country", "message": "Country does not exist."}
	return Decisions.execute(_countries[id], request)

func start_dialogue(a: String, b: String) -> bool:
	return start_talks(a, b, "dialogue")

func start_talks(a: String, b: String, kind: String) -> bool:
	if not _countries.has(a) or not _countries.has(b) or a == b or _talks.size() >= MAX_TALKS:
		return false
	var key := _pair(a, b)
	if _talks.has(key) or kind not in ["dialogue", "cooperation"] or (kind == "cooperation" and _agreements.has(key)):
		return false
	if kind == "cooperation":
		var reserved := _agreements.size()
		for existing in _talks.values():
			if existing.kind == "cooperation":
				reserved += 1
		if reserved >= MAX_TALKS:
			return false
	_talks[key] = {"kind": kind, "progress": 0}
	_countries[a].add_event("Opened bilateral %s talks with %s." % [kind, _countries[b].country.name], "diplomacy")
	_countries[b].add_event("Opened bilateral %s talks with %s." % [kind, _countries[a].country.name], "diplomacy")
	return true

func relationship(a: String, b: String) -> float:
	if not _countries.has(a) or not _countries.has(b) or a == b:
		return NAN
	return float(_relations.get(_pair(a, b), 0.0))

func dialogue_progress(a: String, b: String) -> int:
	var talk: Dictionary = _talks.get(_pair(a, b), {})
	return int(talk.get("progress", -1))

func talk_kind(a: String, b: String) -> String:
	var talk: Dictionary = _talks.get(_pair(a, b), {})
	return str(talk.get("kind", ""))

func cancel_talks(a: String, b: String) -> bool:
	if not _countries.has(a) or not _countries.has(b) or a == b:
		return false
	var key := _pair(a, b)
	if not _talks.has(key):
		return false
	_talks.erase(key)
	for id in [a, b]:
		_countries[id].add_event("Bilateral talks cancelled without an agreement.", "diplomacy", "lab_talks_cancelled")
	return true

func agreement_days(a: String, b: String) -> int:
	return int(_agreements.get(_pair(a, b), 0))

func cooperation_eligible(a: String, b: String) -> bool:
	return _countries.has(a) and _countries.has(b) and a != b and relationship(a, b) >= COOPERATION_MIN_RELATION and _countries[a].country.treasury >= COOPERATION_COST and _countries[b].country.treasury >= COOPERATION_COST

func advance_day() -> void:
	for key in _agreements.keys():
		_agreements[key] -= 1
		if _agreements[key] <= 0:
			var pair: PackedStringArray = key.split("|")
			for id in pair:
				_countries[id].add_event("Bilateral cooperation agreement expired.", "diplomacy", "lab_agreement_expired")
			_agreements.erase(key)
	var keys := _talks.keys()
	keys.sort()
	for key in keys:
		_talks[key].progress += 1
		if _talks[key].progress >= TALK_DAYS:
			var pair: PackedStringArray = key.split("|")
			var kind: String = _talks[key].kind
			var accepted := kind == "dialogue" or cooperation_eligible(pair[0], pair[1])
			if accepted:
				_relations[key] = minf(100.0, float(_relations.get(key, 0.0)) + (RELATION_GAIN if kind == "dialogue" else COOPERATION_GAIN))
				if kind == "cooperation":
					_agreements[key] = AGREEMENT_DAYS
					for id in pair:
						_countries[id].country.treasury -= COOPERATION_COST
						_countries[id].fiscal.spending += COOPERATION_COST
			for id in pair:
				_countries[id].add_event("Bilateral %s talks concluded: %s%s." % [kind, "accepted" if accepted else "declined", "; one-time cost $%.0f" % COOPERATION_COST if accepted and kind == "cooperation" else ""], "diplomacy", "lab_talks_concluded")
			_talks.erase(key)
	for id in country_ids():
		_countries[id].advance_day()

func export_snapshot() -> Dictionary:
	var snapshots := {}
	for id in country_ids():
		snapshots[id] = _countries[id].export_snapshot()
	return {"version": 2, "countries": snapshots, "relations": _relations.duplicate(true), "talks": _talks.duplicate(true), "agreements": _agreements.duplicate(true)}

func load_game(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return "No world save could be opened."
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return "World save contains invalid JSON."
	return import_snapshot(json.data)

func save_game(path: String, rename_operation: Callable = Callable(), write_operation: Callable = Callable(), controlled_id: String = "") -> String:
	if not controlled_id.is_empty() and not _countries.has(controlled_id):
		return "Controlled country does not exist in this world."
	var saved_data := export_snapshot()
	if not controlled_id.is_empty():
		saved_data["controlled_country"] = controlled_id
	var temporary := path + ".tmp"
	if FileAccess.file_exists(temporary) or DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(temporary)):
		return "A temporary world save already exists; inspect it before saving."
	var write_error := World._save_write(temporary, JSON.stringify(saved_data), write_operation)
	var absolute_temp := ProjectSettings.globalize_path(temporary)
	if write_error != OK:
		if FileAccess.file_exists(temporary):
			DirAccess.remove_absolute(absolute_temp)
		return "Could not finish writing the world save."
	var candidate = get_script().new()
	var validation_error: String = candidate.load_game(temporary)
	if not validation_error.is_empty():
		DirAccess.remove_absolute(absolute_temp)
		return "World state cannot be saved: " + validation_error
	var primary := ProjectSettings.globalize_path(path)
	var backup := primary + ".bak"
	var previous := backup + ".previous"
	var displaced := ""
	var retained := false
	if FileAccess.file_exists(path):
		var probe = get_script().new()
		if probe.load_game(path).is_empty():
			if FileAccess.file_exists(previous):
				DirAccess.remove_absolute(absolute_temp)
				return "An interrupted world backup rotation needs manual recovery."
			if FileAccess.file_exists(backup):
				if World._save_rename(backup, previous, rename_operation) != OK:
					DirAccess.remove_absolute(absolute_temp)
					return "Could not preserve the previous world backup."
				retained = true
			displaced = backup
		else:
			displaced = primary + ".invalid"
			if FileAccess.file_exists(displaced):
				DirAccess.remove_absolute(absolute_temp)
				return "A previous invalid world save needs manual recovery."
		if World._save_rename(primary, displaced, rename_operation) != OK:
			if retained:
				World._save_rename(previous, backup, rename_operation)
			DirAccess.remove_absolute(absolute_temp)
			return "Could not preserve the existing world save."
	if World._save_rename(absolute_temp, primary, rename_operation) != OK:
		if not displaced.is_empty() and FileAccess.file_exists(displaced):
			World._save_rename(displaced, primary, rename_operation)
		if retained and not FileAccess.file_exists(backup):
			World._save_rename(previous, backup, rename_operation)
		return "Could not finish saving; prior files were retained if possible."
	if retained and DirAccess.remove_absolute(previous) != OK:
		return "World saved, but older backup cleanup needs manual attention."
	return ""

func import_snapshot(data: Variant) -> String:
	if not data is Dictionary or not World._is_whole_number(data.get("version")) or data.version < 1 or data.version > 2 or not data.get("countries") is Dictionary or not data.get("relations") is Dictionary or not data.get("talks") is Dictionary:
		return "Invalid registry snapshot."
	var control: Variant = data.get("controlled_country", "")
	if not control is String or (not control.is_empty() and not data.countries.has(control)):
		return "Registry has invalid controlled country metadata."
	var talks: Dictionary = data.talks.duplicate(true)
	var agreements: Variant = data.get("agreements") if data.version == 2 else {}
	if not agreements is Dictionary:
		return "Registry has invalid agreements."
	if data.version == 1:
		for key in talks:
			talks[key] = {"kind": "dialogue", "progress": talks[key]}
	if data.countries.is_empty() or data.countries.size() > MAX_COUNTRIES or data.talks.size() > MAX_TALKS or agreements.size() > MAX_TALKS:
		return "Registry snapshot is outside the supported bounds."
	var countries := {}
	var shared_date: Dictionary = {}
	for id in data.countries:
		if not World.Scenario._id(id):
			return "Registry has an invalid country ID."
		var country = World.new()
		var error: String = country.import_snapshot(data.countries[id])
		if not error.is_empty() or country.country.id != id:
			return "Registry has invalid country state."
		if not shared_date.is_empty() and country.date != shared_date:
			return "Registry countries have different dates."
		shared_date = country.date.duplicate()
		countries[id] = country
	for key in data.relations:
		if not _valid_pair(key, countries) or not World._is_number(data.relations[key]) or data.relations[key] < -100.0 or data.relations[key] > 100.0:
			return "Registry has invalid relationships."
	var reserved: int = agreements.size()
	for key in talks:
		var talk: Variant = talks[key]
		if not _valid_pair(key, countries) or not talk is Dictionary or talk.size() != 2 or talk.get("kind") not in ["dialogue", "cooperation"] or not World._is_whole_number(talk.get("progress")) or talk.progress < 0 or talk.progress >= TALK_DAYS:
			return "Registry has invalid dialogue state."
		if talk.kind == "cooperation" and agreements.has(key):
			return "Registry has conflicting cooperation state."
		if talk.kind == "cooperation":
			reserved += 1
	if reserved > MAX_TALKS:
		return "Registry has too many pending or active agreements."
	for key in agreements:
		if not _valid_pair(key, countries) or not World._is_whole_number(agreements[key]) or agreements[key] < 1 or agreements[key] > AGREEMENT_DAYS:
			return "Registry has invalid agreement state."
	_countries = countries
	saved_controlled_id = control
	_relations = data.relations.duplicate()
	_talks = talks
	_agreements = agreements.duplicate()
	for key in _relations:
		_relations[key] = float(_relations[key])
	for key in _talks:
		_talks[key].progress = int(_talks[key].progress)
	for key in _agreements:
		_agreements[key] = int(_agreements[key])
	return ""

static func _pair(a: String, b: String) -> String:
	return a + "|" + b if a < b else b + "|" + a

static func _valid_pair(value: Variant, countries: Dictionary) -> bool:
	if not value is String:
		return false
	var ids: PackedStringArray = value.split("|")
	return ids.size() == 2 and ids[0] != ids[1] and countries.has(ids[0]) and countries.has(ids[1]) and value == _pair(ids[0], ids[1])
