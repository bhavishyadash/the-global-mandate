extends RefCounted

# Fictional groups and coefficients for testing, not empirical estimates.
var groups: Array = [
	{"name": "Lower income", "share": 0.4, "approval": 50.0, "tax_sensitivity": 100.0},
	{"name": "Middle income", "share": 0.4, "approval": 50.0, "tax_sensitivity": 105.0},
	{"name": "Higher income", "share": 0.2, "approval": 50.0, "tax_sensitivity": 115.0},
]
var parties: Array = [
	{"name": "Government", "seats": 48, "support": true},
	{"name": "Reform Party", "seats": 22, "support": true},
	{"name": "Opposition", "seats": 30, "support": false},
]
var procurement_policy := false
var procurement_progress := 0
var election_count := 0

func apply_tax_change(delta: float) -> void:
	for group in groups:
		group.approval = clampf(group.approval - delta * group.tax_sensitivity, 0.0, 100.0)

func approval() -> float:
	var result := 0.0
	for group in groups:
		result += group.approval * group.share
	return result

func votes_for_policy() -> int:
	var result := 0
	for party in parties:
		if party.support:
			result += party.seats
	return result

func vote_procurement() -> bool:
	if procurement_policy or votes_for_policy() <= 50:
		return false
	procurement_policy = true
	return true

func advance_day() -> bool:
	if procurement_policy and procurement_progress < 100:
		procurement_progress = mini(100, procurement_progress + 1)
		return procurement_progress == 100
	return false

func election() -> void:
	# Illustrative two-bloc vote share; not a real electoral model.
	var government_seats := clampi(roundi(approval()), 0, 100)
	parties[0].seats = government_seats
	parties[1].seats = 0
	parties[2].seats = 100 - government_seats
	election_count += 1

func export_state() -> Dictionary:
	return {"groups": groups.duplicate(true), "parties": parties.duplicate(true), "procurement_policy": procurement_policy, "procurement_progress": procurement_progress, "election_count": election_count}

func import_state(state: Variant) -> bool:
	if not state is Dictionary or not state.get("groups") is Array or not state.get("parties") is Array:
		return false
	var gs: Array = state.groups
	var ps: Array = state.parties
	if gs.size() != 3 or ps.size() != 3 or not state.get("procurement_policy") is bool:
		return false
	var progress: Variant = state.get("procurement_progress")
	var elections: Variant = state.get("election_count")
	if not _whole(progress) or progress < 0 or progress > 100 or not _whole(elections) or elections < 0:
		return false
	if not state.procurement_policy and progress != 0:
		return false
	var shares := 0.0
	for group in gs:
		if not group is Dictionary or not group.get("name") is String:
			return false
		for key in ["share", "approval", "tax_sensitivity"]:
			if not _number(group.get(key)):
				return false
		if group.share < 0 or group.share > 1 or group.approval < 0 or group.approval > 100 or group.tax_sensitivity < 0 or group.tax_sensitivity > 1000:
			return false
		shares += group.share
	if absf(shares - 1.0) > 0.00001:
		return false
	var seats := 0
	for party in ps:
		if not party is Dictionary or not party.get("name") is String or not party.get("support") is bool or not _whole(party.get("seats")) or party.seats < 0:
			return false
		seats += int(party.seats)
	if seats != 100:
		return false
	groups = gs.duplicate(true)
	parties = ps.duplicate(true)
	procurement_policy = state.procurement_policy
	procurement_progress = int(progress)
	election_count = int(elections)
	return true

static func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

static func _whole(value: Variant) -> bool:
	return _number(value) and float(value) == floorf(float(value))
