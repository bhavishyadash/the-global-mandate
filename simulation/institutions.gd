extends RefCounted

# These cases and outcomes are fictional test rules, not real legal advice.
const DEFAULT_RULES_PATH := "res://data/rules/institutions_v1.json"
static var _cached_defaults: Dictionary = {}
var rules: Dictionary = {}
var kind := ""
var status := "none"
var days := 0
var progress := 0

func _init() -> void:
	rules = default_rules()

static func default_rules() -> Dictionary:
	if _cached_defaults.is_empty():
		var file := FileAccess.open(DEFAULT_RULES_PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if valid_rules(parsed):
				_cached_defaults = parsed.duplicate(true)
	return _cached_defaults.duplicate(true)

static func valid_rules(data: Variant) -> bool:
	if not data is Dictionary or data.size() != 5 or data.get("version") != 1 or not data.get("cases") is Dictionary or data.cases.size() != 2:
		return false
	for key in ["review_day", "injunction_day", "implementation_days"]:
		if not _whole(data.get(key)):
			return false
	if data.injunction_day < 1 or data.injunction_day >= data.review_day or data.review_day < 2 or data.implementation_days <= data.review_day or data.implementation_days > 3650:
		return false
	for id in ["reporting", "override"]:
		var entry: Variant = data.cases.get(id)
		if not entry is Dictionary or entry.size() != 3 or not entry.get("name") is String or entry.name.strip_edges().is_empty() or entry.name.length() > 100 or not entry.get("description") is String or entry.description.length() > 500 or not entry.get("within_authority") is bool:
			return false
	return true

func configure(data: Variant) -> bool:
	if not valid_rules(data):
		return false
	rules = data.duplicate(true)
	return true

func issue(selected: String) -> bool:
	if not rules.cases.has(selected) or status in ["under_review", "injunction", "upheld", "implemented"]:
		return false
	kind = selected
	status = "under_review"
	days = 0
	progress = 0
	return true

func revoke() -> bool:
	if status not in ["under_review", "injunction", "upheld", "implemented"]:
		return false
	status = "revoked"
	return true

func advance_day() -> String:
	if status not in ["under_review", "injunction", "upheld"]:
		return ""
	days += 1
	if status == "under_review" and not rules.cases[kind].within_authority and days == rules.injunction_day:
		status = "injunction"
		return "A court temporarily suspended the %s directive." % rules.cases[kind].name
	if status == "under_review" or status == "upheld":
		progress += 1
	if days == rules.review_day:
		if not rules.cases[kind].within_authority:
			status = "struck_down"
			return "A court struck down the %s directive under the fictional scenario rules." % rules.cases[kind].name
		status = "upheld"
		return "A court upheld the %s directive under the fictional scenario rules." % rules.cases[kind].name
	if status == "upheld" and progress >= rules.implementation_days:
		status = "implemented"
		return "The %s directive reached full implementation." % rules.cases[kind].name
	return ""

func export_state() -> Dictionary:
	return {"kind": kind, "status": status, "days": days, "progress": progress}

func import_state(data: Variant) -> bool:
	if not data is Dictionary or not data.get("kind") is String or not data.get("status") is String:
		return false
	if not _whole(data.get("days")) or not _whole(data.get("progress")):
		return false
	var d := int(data.days)
	var p := int(data.progress)
	var k: String = data.kind
	var s: String = data.status
	if d < 0 or d > rules.implementation_days or p < 0 or p > rules.implementation_days or p > d:
		return false
	var known: bool = rules.cases.has(k)
	var authorized: bool = known and rules.cases[k].within_authority
	var valid := false
	match s:
		"none": valid = k == "" and d == 0 and p == 0
		"under_review": valid = known and d < rules.review_day and p == d and (authorized or d < rules.injunction_day)
		"injunction": valid = known and not authorized and d >= rules.injunction_day and d < rules.review_day and p == rules.injunction_day - 1
		"upheld": valid = known and authorized and d >= rules.review_day and d < rules.implementation_days and p == d
		"implemented": valid = known and authorized and d == rules.implementation_days and p == d
		"struck_down": valid = known and not authorized and d == rules.review_day and p == rules.injunction_day - 1
		"revoked": valid = known and d <= rules.implementation_days
	if not valid:
		return false
	kind = k
	status = s
	days = d
	progress = p
	return true

static func _whole(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value))
