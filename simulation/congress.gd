extends RefCounted

# Fixed illustrative votes; they are neither real legislators nor forecasts.
const HOUSE_SEATS := 435
const SENATE_SEATS := 100
const STAGES := ["idle", "house", "senate", "president", "override_house", "override_senate", "enacted", "failed"]
var stage := "idle"
var funding := 0.0

func export_state() -> Dictionary:
	return {"stage": stage, "funding": funding}

func import_state(data: Variant, options: Array) -> bool:
	if not data is Dictionary or data.size() != 2 or not data.get("stage") is String or data.stage not in STAGES or not (data.get("funding") is float or data.get("funding") is int):
		return false
	if not is_finite(float(data.funding)) or (data.stage == "idle" and data.funding != 0.0) or (data.stage != "idle" and data.funding not in options):
		return false
	stage = data.stage
	funding = float(data.funding)
	return true

func introduce(amount: float, options: Array) -> bool:
	if stage not in ["idle", "failed", "enacted"] or amount not in options:
		return false
	funding = amount
	stage = "house"
	return true

func votes(chamber: String, options: Array) -> int:
	var index := options.find(funding)
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
	stage = "enacted" if action == "sign" else "override_house"
	return true
