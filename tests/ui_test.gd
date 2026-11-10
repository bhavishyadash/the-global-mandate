extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var screen = load("res://main.tscn").instantiate()
	root.add_child(screen)
	screen.set_process(false)
	assert(screen.world.date.day == 1)
	screen._advance_day()
	assert(screen.world.date.day == 2)
	screen.tax.value = 60
	assert("8.0%" in screen.tax_preview.text)
	assert(is_equal_approx(screen.world.country.income_tax_rate, 0.20))
	screen._apply_tax()
	assert(is_equal_approx(screen.world.country.approval, 8.0))
	screen.spending.value = 1500
	assert("Annual balance" in screen.spending_preview.text)
	assert(is_equal_approx(screen.world.country.annual_spending, 1100000000.0))
	screen._apply_spending()
	assert(is_equal_approx(screen.world.country.annual_spending, 1500000000.0))
	screen._vote_policy()
	assert(screen.world.politics.procurement_policy)
	screen.world.date = {"year": 2029, "month": 12, "day": 31}
	screen._advance_day()
	assert(screen.world.politics.election_count == 1)
	assert("2034" in screen.politics_summary.text)
	screen._toggle_pause()
	assert(screen.running)
	screen._toggle_pause()
	assert(not screen.running)
	var before: Dictionary = screen.world.date.duplicate()
	screen._process(5.0)
	assert(screen.world.date == before)
	screen._toggle_pause()
	screen.speed = 30
	screen._process(2.0)
	assert(is_equal_approx(screen.elapsed, 30.0))
	screen._toggle_pause()
	screen._process(1.0)
	assert(is_equal_approx(screen.elapsed, 30.0))
	screen._toggle_pause()
	screen.speed = 1
	screen._process(0.0)
	assert(is_equal_approx(screen.elapsed, 0.0))
	screen.queue_free()
	print("UI interaction checks passed")
	quit(0)
