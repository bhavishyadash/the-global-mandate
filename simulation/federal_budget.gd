extends RefCounted

const Reference = preload("res://ui/us_reference.gd")
const MAX_MILLIONS := 1000000000

# Historical dollars are stored in millions to match the source's precision.
# The reported total remains the anchor: independently rounded functions differ
# by one million, which must not be silently assigned to a policy category.
static func preview(data: Variant, function_name: String, new_millions: Variant) -> Dictionary:
	var error: String = Reference.validate(data)
	if not error.is_empty():
		return {"error": error}
	if not (new_millions is int or new_millions is float) or not is_finite(float(new_millions)) or float(new_millions) != floorf(float(new_millions)) or new_millions < 0 or new_millions > MAX_MILLIONS:
		return {"error": "Enter a nonnegative whole number of millions within the supported range."}
	var original := 0.0
	var found := false
	for row in data.budget.functions:
		if row.name == function_name:
			found = true
			original = row.millions
			break
	if not found or original < 0:
		return {"error": "Choose a nonnegative spending function; net offsets cannot be adjusted here."}
	var delta := float(new_millions) - original
	var new_outlays: float = data.budget.outlays_millions + delta
	if new_outlays < 0:
		return {"error": "The change would make total federal outlays negative."}
	return {"error": "", "function": function_name, "old_millions": original, "new_millions": float(new_millions), "delta_millions": delta, "receipts_millions": data.budget.receipts_millions, "outlays_millions": new_outlays, "deficit_millions": new_outlays - data.budget.receipts_millions}
