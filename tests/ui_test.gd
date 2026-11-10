extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var screen = load("res://main.tscn").instantiate()
	root.add_child(screen)
	assert(screen.world.date.day == 1)
	screen._advance_day()
	assert(screen.world.date.day == 2)
	screen.tax.value = 60
	screen._apply_tax()
	assert(is_equal_approx(screen.world.country.approval, 8.0))
	screen.spending.value = 1500
	screen._apply_spending()
	assert(is_equal_approx(screen.world.country.annual_spending, 1500000000.0))
	screen._toggle_pause()
	assert(screen.running)
	screen._toggle_pause()
	assert(not screen.running)
	screen.queue_free()
	print("UI interaction checks passed")
	quit(0)
