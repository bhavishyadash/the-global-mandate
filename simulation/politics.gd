extends RefCounted

# Fictional groups and coefficients for testing, not empirical estimates.
var groups: Array = [
	{"name": "Lower income", "share": 0.4, "approval": 50.0, "raw_approval": 50.0, "service_bonus": 0.0, "tax_sensitivity": 100.0},
	{"name": "Middle income", "share": 0.4, "approval": 50.0, "raw_approval": 50.0, "service_bonus": 0.0, "tax_sensitivity": 105.0},
	{"name": "Higher income", "share": 0.2, "approval": 50.0, "raw_approval": 50.0, "service_bonus": 0.0, "tax_sensitivity": 115.0},
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
		group.raw_approval -= delta * group.tax_sensitivity
		group.approval = clampf(group.raw_approval + group.service_bonus, 0.0, 100.0)

func apply_service_bonuses(bonuses: Array) -> void:
	for i in range(groups.size()):
		groups[i].service_bonus = bonuses[i]
		groups[i].approval = clampf(groups[i].raw_approval + groups[i].service_bonus, 0.0, 100.0)

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

func votes_for_repeal() -> int:
	return 100 - votes_for_policy()

func repeal_procurement() -> bool:
	if not procurement_policy or votes_for_repeal() <= 50:
		return false
	procurement_policy = false
	procurement_progress = 0
	return true

func advance_day() -> bool:
	if procurement_policy and procurement_progress < 100:
		procurement_progress = mini(100, procurement_progress + 1)
		return procurement_progress == 100
	return false

func election() -> void:
	# Illustrative allocation, not a real electoral model. Preserve the relative
	# prior representation of the other parties when distributing remaining seats.
	var government_seats := clampi(roundi(approval()), 0, 100)
	var remaining := 100 - government_seats
	var previous_other: int = int(parties[1].seats) + int(parties[2].seats)
	var reform_seats := roundi(remaining / 2.0)
	if previous_other > 0:
		reform_seats = roundi(float(remaining) * float(parties[1].seats) / previous_other)
	parties[0].seats = government_seats
	parties[1].seats = reform_seats
	parties[2].seats = remaining - reform_seats
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
		for key in ["share", "approval", "raw_approval", "service_bonus", "tax_sensitivity"]:
			if not _number(group.get(key)):
				return false
		if group.share < 0 or group.share > 1 or group.approval < 0 or group.approval > 100 or absf(group.raw_approval) > 1000 or absf(group.service_bonus) > 100 or group.tax_sensitivity < 0 or group.tax_sensitivity > 1000:
			return false
		if absf(group.approval - clampf(group.raw_approval + group.service_bonus, 0.0, 100.0)) > 0.001:
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
