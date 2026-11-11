extends SceneTree

const World = preload("res://simulation/world.gd")
const Breakdown = preload("res://ui/budget_breakdown.gd")

func _initialize() -> void:
	var world = World.new()
	var original: Dictionary = world.export_snapshot()
	var baseline: Dictionary = Breakdown.calculate(world, "Health", 500000000.0)
	assert(baseline.valid)
	assert(is_equal_approx(baseline.current_total, 1100000000.0))
	assert(is_equal_approx(baseline.proposed_total, 1270000000.0))
	assert(is_equal_approx(baseline.current.Health, 330000000.0))
	assert(is_equal_approx(baseline.proposed.Health, 500000000.0))
	assert(world.export_snapshot() == original)
	assert(world.vote_healthcare(100000000.0))
	world.country.debt = 200000000.0
	var funded: Dictionary = Breakdown.calculate(world, "Health", 500000000.0)
	assert(is_equal_approx(funded.current["Policy costs"], 100000000.0))
	assert(is_equal_approx(funded.current["Debt interest"], 6000000.0))
	assert(is_equal_approx(funded.current_total, 1206000000.0))
	assert(is_equal_approx(funded.proposed_total, 1376000000.0))
	var invalid: Dictionary = Breakdown.calculate(world, "Health", 10000000000.0)
	assert(not invalid.valid and invalid.proposed == invalid.current)
	var empty = World.new()
	for category in empty.country.spending_categories:
		empty.country.spending_categories[category] = 0.0
	empty.country.annual_spending = 0.0
	var zero: Dictionary = Breakdown.calculate(empty, "Health", 0.0)
	assert(zero.valid and zero.current_total == 0.0 and zero.proposed_total == 0.0)
	print("Budget breakdown checks passed")
	quit(0)
