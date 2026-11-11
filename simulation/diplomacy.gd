extends RefCounted

# Fictional prototype partners and fixed test effects, not real countries.
const PARTNERS := {"maritime": "Maritime Union", "northern": "Northern Federation"}
const TALK_DAYS := 30
const COOLDOWN_DAYS := 90
const RELATION_GAIN := 5.0
var relations := {"maritime": 30.0, "northern": -10.0}
var cooldowns := {"maritime": 0, "northern": 0}
var active := ""
var progress := 0

func start_talks(partner: String) -> bool:
	if not PARTNERS.has(partner) or not active.is_empty() or cooldowns[partner] > 0:
		return false
	active = partner
	progress = 0
	return true

func cancel_talks() -> bool:
	if active.is_empty():
		return false
	cooldowns[active] = COOLDOWN_DAYS
	active = ""
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
	relations[active] = minf(100.0, relations[active] + RELATION_GAIN)
	cooldowns[active] = COOLDOWN_DAYS
	active = ""
	progress = 0
	return "Diplomatic talks with %s concluded; relations improved under the test rules." % name

func export_state() -> Dictionary:
	return {"relations": relations.duplicate(), "cooldowns": cooldowns.duplicate(), "active": active, "progress": progress}

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
	relations = data.relations.duplicate()
	cooldowns = data.cooldowns.duplicate()
	active = data.active
	progress = int(data.progress)
	return true

static func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

static func _whole(value: Variant) -> bool:
	return _number(value) and float(value) == floorf(float(value))
