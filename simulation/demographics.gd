extends RefCounted

# Fictional annual rates are stored in tenths per 1,000 people. Accumulators
# use a common exact denominator for 365- and 366-day years, avoiding loss of
# fractional people or a rounding reset at a leap-year boundary.
const DENOMINATOR := 10000 * 365 * 366
const MAX_POPULATION := 10000000000
var rules: Dictionary = default_rules()
var fractions := {"births": 0, "deaths": 0, "migration": 0}

static func default_rules() -> Dictionary:
	return {"birth_rate_tenths": 0, "death_rate_tenths": 0, "migration_rate_tenths": 0}

static func _whole(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and floorf(float(value)) == float(value)

static func valid_rules(value: Variant) -> bool:
	if not value is Dictionary or value.size() != 3:
		return false
	for key in ["birth_rate_tenths", "death_rate_tenths", "migration_rate_tenths"]:
		if not _whole(value.get(key)):
			return false
	return value.birth_rate_tenths >= 0 and value.birth_rate_tenths <= 1000 and value.death_rate_tenths >= 0 and value.death_rate_tenths <= 1000 and value.migration_rate_tenths >= -1000 and value.migration_rate_tenths <= 1000

func configure(value: Variant) -> bool:
	if not valid_rules(value):
		return false
	rules = {"birth_rate_tenths": int(value.birth_rate_tenths), "death_rate_tenths": int(value.death_rate_tenths), "migration_rate_tenths": int(value.migration_rate_tenths)}
	fractions = {"births": 0, "deaths": 0, "migration": 0}
	return true

func export_state() -> Dictionary:
	return {"rules": rules.duplicate(true), "fractions": fractions.duplicate(true)}

func import_state(value: Variant) -> bool:
	if not value is Dictionary or value.size() != 2 or not valid_rules(value.get("rules")) or not value.get("fractions") is Dictionary or value.fractions.size() != 3:
		return false
	for key in ["births", "deaths", "migration"]:
		if not _whole(value.fractions.get(key)) or absf(float(value.fractions[key])) >= DENOMINATOR:
			return false
	if value.fractions.births < 0 or value.fractions.deaths < 0:
		return false
	var next_rules: Dictionary = value.rules.duplicate(true)
	var next_fractions: Dictionary = value.fractions.duplicate(true)
	configure(next_rules)
	for key in fractions:
		fractions[key] = int(next_fractions[key])
	return true

func advance(population: int, leap_year: bool) -> Dictionary:
	if population < 0 or population > MAX_POPULATION:
		return {"population": population, "births": 0, "deaths": 0, "migration": 0}
	var factor := 365 if leap_year else 366
	var counts := {}
	for spec in [["births", "birth_rate_tenths"], ["deaths", "death_rate_tenths"], ["migration", "migration_rate_tenths"]]:
		var total: int = fractions[spec[0]] + population * int(rules[spec[1]]) * factor
		@warning_ignore("integer_division")
		var whole: int = total / DENOMINATOR
		fractions[spec[0]] = total - whole * DENOMINATOR
		counts[spec[0]] = whole
	var births: int = mini(counts.births, MAX_POPULATION - population)
	var deaths: int = mini(counts.deaths, population + births)
	var migration: int = clampi(counts.migration, -(population + births - deaths), MAX_POPULATION - (population + births - deaths))
	if births != counts.births:
		fractions.births = 0
	if deaths != counts.deaths:
		fractions.deaths = 0
	if migration != counts.migration:
		fractions.migration = 0
	return {"population": population + births - deaths + migration, "births": births, "deaths": deaths, "migration": migration}
