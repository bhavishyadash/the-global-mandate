extends RefCounted

# Fixed illustrative votes; they are neither real legislators nor forecasts.
const HOUSE_SEATS := 435
const SENATE_SEATS := 100
const STAGES := ["idle", "house", "senate", "president", "override_house", "override_senate", "enacted", "failed"]
var stage := "idle"
var funding := 0.0
var history: Array = []

func export_state() -> Dictionary:
	return {"stage": stage, "funding": funding, "history": history.duplicate(true)}

func import_state(data: Variant, options: Array) -> bool:
	if not data is Dictionary or data.size() != 3 or not data.get("stage") is String or data.stage not in STAGES or not (data.get("funding") is float or data.get("funding") is int) or not data.get("history") is Array or data.history.size() > 5:
		return false
	if not is_finite(float(data.funding)) or (data.stage == "idle" and data.funding != 0.0) or (data.stage != "idle" and data.funding not in options):
		return false
	var next_step := ""
	for item in data.history:
		if not item is Dictionary or item.size() != 4 or item.get("step") not in ["house", "senate", "override_house", "override_senate", "president"] or not item.get("result") is String or not item.get("yes") is int and not item.get("yes") is float or not item.get("total") is int and not item.get("total") is float:
			return false
		if not next_step.is_empty() and item.step != next_step:
			return false
		if not is_finite(float(item.yes)) or not is_finite(float(item.total)) or item.yes != floor(item.yes) or item.total != floor(item.total):
			return false
		if item.step == "president":
			if item.result not in ["sign", "veto"] or item.yes != 0 or item.total != 0:
				return false
		else:
			var total := HOUSE_SEATS if item.step in ["house", "override_house"] else SENATE_SEATS
			if item.total != total or item.yes < 0 or item.yes > total or item.result not in ["passed", "failed"]:
				return false
			var overridden: bool = item.step in ["override_house", "override_senate"]
			var passed: bool = item.yes * 3 >= total * 2 if overridden else item.yes * 2 > total
			if (item.result == "passed") != passed:
				return false
		if item.step == "president":
			next_step = "enacted" if item.result == "sign" else "override_house"
		elif item.result == "failed":
			next_step = "failed"
		else:
			next_step = {"house": "senate", "senate": "president", "override_house": "override_senate", "override_senate": "enacted"}[item.step]
	if data.stage == "idle" and not data.history.is_empty():
		return false
	if not data.history.is_empty():
		if data.stage != next_step:
			return false
	stage = data.stage
	funding = float(data.funding)
	history = data.history.duplicate(true)
	return true

func introduce(amount: float, options: Array) -> bool:
	if stage not in ["idle", "failed", "enacted"] or amount not in options:
		return false
	funding = amount
	stage = "house"
	history.clear()
	return true

func votes(chamber: String, options: Array) -> int:
	return votes_for(funding, chamber, options)

func votes_for(amount: float, chamber: String, options: Array) -> int:
	var index := options.find(amount)
	if index < 0:
		return 0
	return [320, 280, 180][index] if chamber == "house" else [75, 60, 45][index]

func vote(options: Array) -> bool:
	if stage not in ["house", "senate", "override_house", "override_senate"]:
		return false
	var house := stage in ["house", "override_house"]
	var override := stage in ["override_house", "override_senate"]
	var total := HOUSE_SEATS if house else SENATE_SEATS
	var yes := votes("house" if house else "senate", options)
	var passed := yes * 3 >= total * 2 if override else yes * 2 > total
	history.append({"step": stage, "yes": yes, "total": total, "result": "passed" if passed else "failed"})
	if not passed:
		stage = "failed"
	elif stage == "house":
		stage = "senate"
	elif stage == "senate":
		stage = "president"
	elif stage == "override_house":
		stage = "override_senate"
	else:
		stage = "enacted"
	return true

func presidential_action(action: String) -> bool:
	if stage != "president" or action not in ["sign", "veto"]:
		return false
	history.append({"step": "president", "yes": 0, "total": 0, "result": action})
	stage = "enacted" if action == "sign" else "override_house"
	return true
