extends RefCounted

# A display projection of the existing fiscal model; it never mutates world.
static func calculate(world: Variant, category: String, proposed_amount: float) -> Dictionary:
	if world == null:
		return {}
	var valid: bool = not world.preview_category_spending(category, proposed_amount).is_empty()
	var current: Dictionary = world.country.spending_categories.duplicate()
	current["Policy costs"] = world.policy_annual_cost()
	current["Debt interest"] = world.debt_interest()
	var proposed := current.duplicate()
	if valid:
		proposed[category] = proposed_amount
	var current_total := 0.0
	var proposed_total := 0.0
	for key in current:
		current_total += float(current[key])
		proposed_total += float(proposed[key])
	return {"current": current, "proposed": proposed, "current_total": current_total, "proposed_total": proposed_total, "valid": valid}
