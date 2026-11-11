extends RefCounted

# These cases and outcomes are fictional test rules, not real legal advice.
const CASES := {
	"reporting": {"name": "Procurement reporting", "within_authority": true, "description": "Direct an agency to publish procurement reports under assumed existing authority."},
	"override": {"name": "Override spending limit", "within_authority": false, "description": "Direct an agency to exceed a fictional statutory spending limit."},
}
var kind := ""
var status := "none"
var days := 0
var progress := 0

func issue(selected: String) -> bool:
	if not CASES.has(selected) or status in ["under_review", "injunction", "upheld", "implemented"]:
		return false
	kind = selected
	status = "under_review"
	days = 0
	progress = 0
	return true

func revoke() -> bool:
	if status not in ["under_review", "injunction", "upheld", "implemented"]:
		return false
	status = "revoked"
	return true

func advance_day() -> String:
	if status not in ["under_review", "injunction", "upheld"]:
		return ""
	days += 1
	if status == "under_review" and kind == "override" and days == 10:
		status = "injunction"
		return "A court temporarily suspended the spending-limit directive."
	if status == "under_review" or status == "upheld":
		progress += 1
	if days == 30:
		if kind == "override":
			status = "struck_down"
			return "A court struck down the spending-limit directive under the fictional scenario rules."
		status = "upheld"
		return "A court upheld the reporting directive under the fictional scenario rules."
	if status == "upheld" and progress >= 60:
		status = "implemented"
		return "The reporting directive reached full implementation."
	return ""

func export_state() -> Dictionary:
	return {"kind": kind, "status": status, "days": days, "progress": progress}

func import_state(data: Variant) -> bool:
	if not data is Dictionary or not data.get("kind") is String or not data.get("status") is String:
		return false
	if not _whole(data.get("days")) or not _whole(data.get("progress")):
		return false
	var d := int(data.days)
	var p := int(data.progress)
	var k: String = data.kind
	var s: String = data.status
	if d < 0 or d > 60 or p < 0 or p > 60 or p > d:
		return false
	var valid := false
	match s:
		"none": valid = k == "" and d == 0 and p == 0
		"under_review": valid = CASES.has(k) and d < 30 and p == d and (k != "override" or d < 10)
		"injunction": valid = k == "override" and d >= 10 and d < 30 and p == 9
		"upheld": valid = k == "reporting" and d >= 30 and d < 60 and p == d
		"implemented": valid = k == "reporting" and d == 60 and p == 60
		"struck_down": valid = k == "override" and d == 30 and p == 9
		"revoked": valid = CASES.has(k) and d <= 60
	if not valid:
		return false
	kind = k
	status = s
	days = d
	progress = p
	return true

static func _whole(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value))
