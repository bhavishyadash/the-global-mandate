extends RefCounted

# Fictional prototype partners and fixed test effects, not real countries.
const PARTNERS := {"maritime": "Maritime Union", "northern": "Northern Federation"}
const TALK_DAYS := 30
const COOLDOWN_DAYS := 90
const RELATION_GAIN := 5.0
const PROPOSALS := {"dialogue": {"name": "Open dialogue", "gain": 5.0}, "cooperation": {"name": "Cooperation framework", "gain": 10.0}}
const COOPERATION_MINIMUM := {"maritime": 15.0, "northern": 0.0}
const AGREEMENT_DAYS := 365
const AGREEMENT_ANNUAL_COST := 10000000.0
const AGREEMENT_ANNUAL_CONTRIBUTION := 20000000.0
var relations := {"maritime": 30.0, "northern": -10.0}
var cooldowns := {"maritime": 0, "northern": 0}
var active := ""
var progress := 0
var proposal := ""
var agreements := {"maritime": 0, "northern": 0}

func start_talks(partner: String, choice: String = "dialogue") -> bool:
	if not PARTNERS.has(partner) or not PROPOSALS.has(choice) or not active.is_empty() or cooldowns[partner] > 0:
		return false
	active = partner
	proposal = choice
	progress = 0
	return true

func cancel_talks() -> bool:
	if active.is_empty():
		return false
	cooldowns[active] = COOLDOWN_DAYS
	active = ""
	proposal = ""
	progress = 0
	return true

func advance_day() -> String:
	var messages := PackedStringArray()
	for partner in cooldowns:
		cooldowns[partner] = maxi(0, cooldowns[partner] - 1)
		if agreements[partner] > 0:
			agreements[partner] -= 1
			if agreements[partner] == 0:
				messages.append("Cooperation agreement with %s expired." % PARTNERS[partner])
	if active.is_empty():
		return " ".join(messages)
	progress += 1
	if progress < TALK_DAYS:
		return " ".join(messages)
	var name: String = PARTNERS[active]
	var accepted := will_accept(active, proposal)
	if accepted:
		relations[active] = minf(100.0, relations[active] + PROPOSALS[proposal].gain)
		if proposal == "cooperation":
			agreements[active] = AGREEMENT_DAYS
	cooldowns[active] = COOLDOWN_DAYS
	active = ""
	proposal = ""
	progress = 0
	messages.append("Diplomatic talks with %s concluded; proposal %s under the test rules." % [name, "accepted" if accepted else "declined"])
	return " ".join(messages)

func annual_agreement_cost() -> float:
	var count := 0
	for partner in agreements:
		if agreements[partner] > 0:
			count += 1
	return count * AGREEMENT_ANNUAL_COST

func annual_partner_contribution() -> float:
	return annual_agreement_cost() / AGREEMENT_ANNUAL_COST * AGREEMENT_ANNUAL_CONTRIBUTION

func end_agreement(partner: String) -> bool:
	if not PARTNERS.has(partner) or agreements[partner] <= 0:
		return false
	agreements[partner] = 0
	relations[partner] = maxf(-100.0, relations[partner] - 5.0)
	return true

func will_accept(partner: String, choice: String) -> bool:
	if not PARTNERS.has(partner) or not PROPOSALS.has(choice):
		return false
	return choice == "dialogue" or relations[partner] >= COOPERATION_MINIMUM[partner]

func export_state() -> Dictionary:
	return {"relations": relations.duplicate(), "cooldowns": cooldowns.duplicate(), "agreements": agreements.duplicate(), "active": active, "progress": progress, "proposal": proposal}

func import_state(data: Variant) -> bool:
	if not data is Dictionary or not data.get("relations") is Dictionary or not data.get("cooldowns") is Dictionary or not data.get("agreements") is Dictionary or not data.get("active") is String:
		return false
	if data.relations.size() != PARTNERS.size() or data.cooldowns.size() != PARTNERS.size() or data.agreements.size() != PARTNERS.size():
		return false
	for partner in PARTNERS:
		var relation: Variant = data.relations.get(partner)
		var cooldown: Variant = data.cooldowns.get(partner)
		var agreement: Variant = data.agreements.get(partner)
		if not _number(relation) or relation < -100.0 or relation > 100.0 or not _whole(cooldown) or cooldown < 0 or cooldown > COOLDOWN_DAYS or not _whole(agreement) or agreement < 0 or agreement > AGREEMENT_DAYS:
			return false
	if not _whole(data.get("progress")) or data.progress < 0 or data.progress >= TALK_DAYS:
		return false
	if (data.active.is_empty() and data.progress != 0) or (not data.active.is_empty() and (not PARTNERS.has(data.active) or data.cooldowns[data.active] != 0)):
		return false
	if not data.get("proposal") is String or (data.active.is_empty() and not data.proposal.is_empty()) or (not data.active.is_empty() and not PROPOSALS.has(data.proposal)):
		return false
	relations = data.relations.duplicate()
	cooldowns = data.cooldowns.duplicate()
	agreements = data.agreements.duplicate()
	active = data.active
	progress = int(data.progress)
	proposal = data.proposal
	return true

static func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

static func _whole(value: Variant) -> bool:
	return _number(value) and float(value) == floorf(float(value))
