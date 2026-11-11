extends RefCounted

# Fictional prototype partners and fixed test effects, not real countries.
const PARTNERS := {"maritime": "Maritime Union", "northern": "Northern Federation"}
const TALK_DAYS := 30
const COOLDOWN_DAYS := 90
const RELATION_GAIN := 5.0
const PROPOSALS := {"dialogue": {"name": "Open dialogue", "gain": 5.0}, "cooperation": {"name": "Cooperation framework", "gain": 10.0}}
const COOPERATION_MINIMUM := {"maritime": 15.0, "northern": 0.0}
var relations := {"maritime": 30.0, "northern": -10.0}
var cooldowns := {"maritime": 0, "northern": 0}
var active := ""
var progress := 0
var proposal := ""

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
	for partner in cooldowns:
		cooldowns[partner] = maxi(0, cooldowns[partner] - 1)
	if active.is_empty():
		return ""
	progress += 1
	if progress < TALK_DAYS:
		return ""
	var name: String = PARTNERS[active]
	var accepted := will_accept(active, proposal)
	if accepted:
		relations[active] = minf(100.0, relations[active] + PROPOSALS[proposal].gain)
	cooldowns[active] = COOLDOWN_DAYS
	active = ""
	proposal = ""
	progress = 0
	return "Diplomatic talks with %s concluded; proposal %s under the test rules." % [name, "accepted" if accepted else "declined"]

func will_accept(partner: String, choice: String) -> bool:
	if not PARTNERS.has(partner) or not PROPOSALS.has(choice):
		return false
	return choice == "dialogue" or relations[partner] >= COOPERATION_MINIMUM[partner]

func export_state() -> Dictionary:
	return {"relations": relations.duplicate(), "cooldowns": cooldowns.duplicate(), "active": active, "progress": progress, "proposal": proposal}

func import_state(data: Variant) -> bool:
	if not data is Dictionary or not data.get("relations") is Dictionary or not data.get("cooldowns") is Dictionary or not data.get("active") is String:
		return false
	if data.relations.size() != PARTNERS.size() or data.cooldowns.size() != PARTNERS.size():
		return false
	for partner in PARTNERS:
		var relation: Variant = data.relations.get(partner)
		var cooldown: Variant = data.cooldowns.get(partner)
		if not _number(relation) or relation < -100.0 or relation > 100.0 or not _whole(cooldown) or cooldown < 0 or cooldown > COOLDOWN_DAYS:
			return false
	if not _whole(data.get("progress")) or data.progress < 0 or data.progress >= TALK_DAYS:
		return false
	if (data.active.is_empty() and data.progress != 0) or (not data.active.is_empty() and (not PARTNERS.has(data.active) or data.cooldowns[data.active] != 0)):
		return false
	if not data.get("proposal") is String or (data.active.is_empty() and not data.proposal.is_empty()) or (not data.active.is_empty() and not PROPOSALS.has(data.proposal)):
		return false
	relations = data.relations.duplicate()
	cooldowns = data.cooldowns.duplicate()
	active = data.active
	progress = int(data.progress)
	proposal = data.proposal
	return true

static func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

static func _whole(value: Variant) -> bool:
	return _number(value) and float(value) == floorf(float(value))
