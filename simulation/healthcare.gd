extends RefCounted

# Fictional test policy. Dollar amounts are annual and all coefficients are
# illustrative, not estimates of real healthcare or legislative behavior.
const FUNDING_OPTIONS := [50000000.0, 100000000.0, 200000000.0]
const DAYS_AT_NORMAL_CAPACITY := 120.0
const TARGET_PER_100M := 20.0
var active := false
var funding := 0.0
var progress := 0.0

static func valid_funding(amount: float) -> bool:
	return is_finite(amount) and (amount == 50000000.0 or amount == 100000000.0 or amount == 200000000.0)

func support(parties: Array, amount: float, repeal: bool = false) -> Array:
	if not valid_funding(amount) or parties.size() != 3:
		return []
	# Test party positions: government supports its bill/repeal; Reform backs
	# lower funding and repeal of larger programs; Opposition backs the largest.
	var positions := [true, amount >= 100000000.0 if repeal else amount <= 100000000.0, false if repeal else amount >= 200000000.0]
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

func advance_day(administration: float) -> bool:
	if not active or progress >= 100.0:
		return false
	# Neutral administration (50/100) completes the rollout in 120 days;
	# weak administration slows it, and zero capacity stalls it.
	progress = minf(100.0, progress + clampf(administration / 50.0, 0.0, 2.0) * 100.0 / DAYS_AT_NORMAL_CAPACITY)
	if progress >= 100.0 - 0.000001:
		progress = 100.0
	return progress >= 100.0

func health_bonus() -> float:
	return TARGET_PER_100M * (funding / 100000000.0) * (progress / 100.0) if active else 0.0

func export_state() -> Dictionary:
	return {"active": active, "funding": funding, "progress": progress}

func import_state(data: Variant) -> bool:
	if not data is Dictionary or not data.get("active") is bool or not _number(data.get("funding")) or not _number(data.get("progress")):
		return false
	if data.active:
		if not valid_funding(float(data.funding)) or data.progress < 0.0 or data.progress > 100.0:
			return false
	elif data.funding != 0.0 or data.progress != 0.0:
		return false
	active = data.active
	funding = float(data.funding)
	progress = float(data.progress)
	return true

static func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))
