extends RefCounted

# Fictional test policy. Dollar amounts are annual and all coefficients are
# illustrative, not estimates of real healthcare or legislative behavior.
const DEFAULT_RULES_PATH := "res://data/rules/healthcare_v1.json"
static var _cached_defaults: Dictionary = {}
var rules: Dictionary = {}
var active := false
var funding := 0.0
var progress := 0.0
var appropriation := 1.0

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
	if not data is Dictionary or data.size() != 9 or data.get("version") != 1 or not data.get("funding_options") is Array or data.funding_options.size() != 3:
		return false
	var last := 0.0
	for value in data.funding_options:
		if not _number(value) or value <= last or value > 10000000000.0:
			return false
		last = float(value)
	for key in ["days_at_normal_capacity", "target_per_100m", "reform_proposal_max", "opposition_proposal_min", "reform_repeal_min", "reform_appropriation_max", "opposition_appropriation_min"]:
		if not _number(data.get(key)):
			return false
	return data.days_at_normal_capacity >= 1.0 and data.days_at_normal_capacity <= 3650.0 and data.target_per_100m >= 0.0 and data.target_per_100m <= 100.0 and data.reform_proposal_max >= 0.0 and data.reform_proposal_max <= 10000000000.0 and data.opposition_proposal_min >= 0.0 and data.opposition_proposal_min <= 10000000000.0 and data.reform_repeal_min >= 0.0 and data.reform_repeal_min <= 10000000000.0 and data.reform_appropriation_max >= 0.0 and data.reform_appropriation_max <= 1.0 and data.opposition_appropriation_min >= 0.0 and data.opposition_appropriation_min <= 1.0

func configure(data: Variant) -> bool:
	if not valid_rules(data):
		return false
	rules = data.duplicate(true)
	return true

func valid_funding(amount: float) -> bool:
	return is_finite(amount) and amount in rules.get("funding_options", [])

func support(parties: Array, amount: float, repeal: bool = false) -> Array:
	if not valid_funding(amount) or parties.size() != 3:
		return []
	# Fictional government support and scenario-defined opposition thresholds.
	var positions := [true, amount >= rules.reform_repeal_min if repeal else amount <= rules.reform_proposal_max, false if repeal else amount >= rules.opposition_proposal_min]
	var result: Array = []
	for i in range(3):
		result.append({"name": parties[i].name, "seats": int(parties[i].seats), "support": positions[i]})
	return result

func votes(positions: Array) -> int:
	var result := 0
	for party in positions:
		if party.support:
			result += int(party.seats)
	return result

func appropriation_support(parties: Array, fraction: float) -> Array:
	if not is_finite(fraction) or fraction < 0.0 or fraction > 1.0 or parties.size() != 3:
		return []
	# Fictional positions use the scenario-defined funding-share thresholds.
	var positions := [true, fraction <= rules.reform_appropriation_max, fraction >= rules.opposition_appropriation_min]
	var result: Array = []
	for i in range(3):
		result.append({"name": parties[i].name, "seats": int(parties[i].seats), "support": positions[i]})
	return result

func advance_day(administration: float) -> bool:
	if not active or progress >= 100.0 or appropriation <= 0.0:
		return false
	# Neutral administration (50/100) completes rollout in configured days;
	# weak administration slows it, and zero capacity stalls it.
	progress = minf(100.0, progress + clampf(administration / 50.0, 0.0, 2.0) * appropriation * 100.0 / float(rules.days_at_normal_capacity))
	if progress >= 100.0 - 0.000001:
		progress = 100.0
	return progress >= 100.0

func health_bonus() -> float:
	return float(rules.target_per_100m) * (funding / 100000000.0) * appropriation * (progress / 100.0) if active else 0.0

func annual_cost() -> float:
	return funding * appropriation if active else 0.0

func export_state() -> Dictionary:
	return {"active": active, "funding": funding, "progress": progress, "appropriation": appropriation}

func import_state(data: Variant) -> bool:
	if not data is Dictionary or not data.get("active") is bool or not _number(data.get("funding")) or not _number(data.get("progress")) or not _number(data.get("appropriation")) or data.appropriation < 0.0 or data.appropriation > 1.0:
		return false
	if data.active:
		if not valid_funding(float(data.funding)) or data.progress < 0.0 or data.progress > 100.0:
			return false
	elif data.funding != 0.0 or data.progress != 0.0:
		return false
	active = data.active
	funding = float(data.funding)
	progress = float(data.progress)
	appropriation = float(data.appropriation)
	return true

static func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))
