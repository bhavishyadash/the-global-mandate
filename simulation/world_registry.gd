extends RefCounted

const World = preload("res://simulation/world.gd")
const Decisions = preload("res://simulation/decisions.gd")
const MAX_COUNTRIES := 250
const MAX_TALKS := 1000
const TALK_DAYS := 30
const RELATION_GAIN := 5.0

# This is an experimental headless multi-country layer. Its bilateral
# relationships are separate from the older single-country diplomacy model.
var _countries: Dictionary = {}
var _relations: Dictionary = {}
var _talks: Dictionary = {}

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
	return ""

func country_ids() -> Array:
	var ids := _countries.keys()
	ids.sort()
	return ids

func country_snapshot(id: String) -> Dictionary:
	return _countries[id].export_snapshot() if _countries.has(id) else {}

func execute_country(id: String, request: Variant) -> Dictionary:
	if not _countries.has(id):
		return {"ok": false, "code": "unknown_country", "message": "Country does not exist."}
	return Decisions.execute(_countries[id], request)

func start_dialogue(a: String, b: String) -> bool:
	if not _countries.has(a) or not _countries.has(b) or a == b or _talks.size() >= MAX_TALKS:
		return false
	var key := _pair(a, b)
	if _talks.has(key):
		return false
	_talks[key] = 0
	_countries[a].add_event("Opened bilateral dialogue with %s." % _countries[b].country.name, "diplomacy")
	_countries[b].add_event("Opened bilateral dialogue with %s." % _countries[a].country.name, "diplomacy")
	return true

func relationship(a: String, b: String) -> float:
	if not _countries.has(a) or not _countries.has(b) or a == b:
		return NAN
	return float(_relations.get(_pair(a, b), 0.0))

func dialogue_progress(a: String, b: String) -> int:
	return int(_talks.get(_pair(a, b), -1))

func advance_day() -> void:
	var keys := _talks.keys()
	keys.sort()
	for key in keys:
		_talks[key] += 1
		if _talks[key] >= TALK_DAYS:
			_relations[key] = minf(100.0, float(_relations.get(key, 0.0)) + RELATION_GAIN)
			var pair: PackedStringArray = key.split("|")
			_countries[pair[0]].add_event("Bilateral dialogue with %s concluded." % _countries[pair[1]].country.name, "diplomacy")
			_countries[pair[1]].add_event("Bilateral dialogue with %s concluded." % _countries[pair[0]].country.name, "diplomacy")
			_talks.erase(key)
	for id in country_ids():
		_countries[id].advance_day()

func export_snapshot() -> Dictionary:
	var snapshots := {}
	for id in country_ids():
		snapshots[id] = _countries[id].export_snapshot()
	return {"version": 1, "countries": snapshots, "relations": _relations.duplicate(true), "talks": _talks.duplicate(true)}

func import_snapshot(data: Variant) -> String:
	if not data is Dictionary or data.get("version") != 1 or not data.get("countries") is Dictionary or not data.get("relations") is Dictionary or not data.get("talks") is Dictionary:
		return "Invalid registry snapshot."
	if data.countries.is_empty() or data.countries.size() > MAX_COUNTRIES or data.talks.size() > MAX_TALKS:
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
	for key in data.talks:
		if not _valid_pair(key, countries) or not World._is_whole_number(data.talks[key]) or data.talks[key] < 0 or data.talks[key] >= TALK_DAYS:
			return "Registry has invalid dialogue state."
	_countries = countries
	_relations = data.relations.duplicate()
	_talks = data.talks.duplicate()
	for key in _relations:
		_relations[key] = float(_relations[key])
	for key in _talks:
		_talks[key] = int(_talks[key])
	return ""

static func _pair(a: String, b: String) -> String:
	return a + "|" + b if a < b else b + "|" + a

static func _valid_pair(value: Variant, countries: Dictionary) -> bool:
	if not value is String:
		return false
	var ids: PackedStringArray = value.split("|")
	return ids.size() == 2 and ids[0] != ids[1] and countries.has(ids[0]) and countries.has(ids[1]) and value == _pair(ids[0], ids[1])
