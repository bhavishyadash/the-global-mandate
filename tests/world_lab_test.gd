extends SceneTree

const Lab = preload("res://ui/world_lab.gd")
const SAVE := "res://tests/world_lab_test_save.json"

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	for suffix in ["", ".bak", ".tmp", ".invalid", ".bak.previous"]:
		assert(not FileAccess.file_exists(SAVE + suffix))
	var lab = Lab.new()
	root.add_child(lab)
	assert(lab.initialized and lab.registry.country_ids() == ["coastal_republic", "usa_sandbox"])
	assert("independent fictional" in lab.get_child(0).text)
	var usa_before: Dictionary = lab.registry.country_snapshot(lab.USA)
	var coastal_before: Dictionary = lab.registry.country_snapshot(lab.COAST)
	for index in range(lab.picker.item_count):
		if lab.picker.get_item_metadata(index) == lab.USA:
			lab.picker.select(index)
	lab._selection_changed()
	lab.tax.value = 60
	lab.apply_tax()
	assert(is_equal_approx(lab.registry.country_snapshot(lab.USA).country.approval, 8.0))
	assert(lab.registry.country_snapshot(lab.COAST) == coastal_before)
	assert(usa_before.country.income_tax_rate == 0.2)
	lab.start_dialogue()
	assert(lab.dialogue_button.disabled and lab.registry.dialogue_progress(lab.USA, lab.COAST) == 0)
	lab.advance_day()
	assert(lab.registry.country_snapshot(lab.USA).date.day == 2)
	assert(lab.registry.country_snapshot(lab.COAST).date.day == 2)
	assert(lab.registry.dialogue_progress(lab.USA, lab.COAST) == 1)
	assert(lab.save_to(SAVE).is_empty())
	var saved: Dictionary = lab.registry.export_snapshot()
	lab.advance_day()
	var load_error: String = lab.load_from(SAVE)
	if not load_error.is_empty():
		push_error("Lab load failed: " + load_error)
	assert(load_error.is_empty())
	var loaded: Dictionary = lab.registry.export_snapshot()
	assert(loaded.countries.usa_sandbox.date == saved.countries.usa_sandbox.date)
	assert(is_equal_approx(loaded.countries.usa_sandbox.country.approval, saved.countries.usa_sandbox.country.approval))
	assert(is_equal_approx(loaded.countries.usa_sandbox.country.treasury, saved.countries.usa_sandbox.country.treasury))
	assert(loaded.talks == saved.talks)
	saved = loaded
	assert(lab.registry.dialogue_progress(lab.USA, lab.COAST) == 1)
	var wrong_world = Lab.Registry.new()
	assert(wrong_world.initialize([Lab.World.Scenario.read_file(Lab.World.DEFAULT_SCENARIO)]).is_empty())
	var file := FileAccess.open(SAVE, FileAccess.WRITE)
	file.store_string(JSON.stringify(wrong_world.export_snapshot()))
	file.close()
	assert(not lab.load_from(SAVE).is_empty() and lab.registry.export_snapshot() == saved)
	for day in range(29):
		lab.advance_day()
	assert(lab.registry.dialogue_progress(lab.USA, lab.COAST) == -1)
	assert(lab.registry.relationship(lab.USA, lab.COAST) == 5.0 and not lab.dialogue_button.disabled)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
	lab.queue_free()
	print("World lab checks passed")
	quit(0)
