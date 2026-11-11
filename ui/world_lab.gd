extends VBoxContainer

const Registry = preload("res://simulation/world_registry.gd")
const World = preload("res://simulation/world.gd")
const LAB_SAVE := "user://experimental_world_save.json"
const USA := "usa_sandbox"
const COAST := "coastal_republic"
var registry = Registry.new()
var picker: OptionButton
var tax: SpinBox
var overview: Label
var selected_details: Label
var message: Label
var load_confirmation: ConfirmationDialog
var dialogue_button: Button
var initialized := false

func _ready() -> void:
	add_theme_constant_override("separation", 10)
	var heading := Label.new()
	heading.text = "MULTI-COUNTRY LAB — independent fictional test world"
	add_child(heading)
	var note := Label.new()
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.text = "This experimental world has its own clock and save slot. Its US sandbox and Coastal Republic have fictional values. It does not control the main game or map. Advance days here to update both countries together."
	add_child(note)
	var scenarios := [World.Scenario.read_file("res://data/scenarios/usa_sandbox.json"), World.Scenario.read_file("res://data/scenarios/coastal_test.json")]
	var error: String = registry.initialize(scenarios)
	message = Label.new()
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if not error.is_empty():
		message.text = "World lab unavailable: " + error
		add_child(message)
		return
	initialized = true
	var actions := HBoxContainer.new()
	add_child(actions)
	for spec in [["Advance lab one day", "advance"], ["Save lab world", "save"], ["Load lab world", "load"]]:
		var button := Button.new()
		button.text = spec[0]
		var action: String = spec[1]
		button.pressed.connect(func(): _action(action))
		actions.add_child(button)
	load_confirmation = ConfirmationDialog.new()
	load_confirmation.title = "Load experimental world?"
	load_confirmation.dialog_text = "Loading replaces the current lab world. Save it first if you want to keep it. The main game is not changed."
	load_confirmation.confirmed.connect(func(): load_from(LAB_SAVE))
	add_child(load_confirmation)
	overview = Label.new()
	overview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(overview)
	var selection := HBoxContainer.new()
	add_child(selection)
	picker = OptionButton.new()
	for id in registry.country_ids():
		picker.add_item(registry.country_snapshot(id).country.name)
		picker.set_item_metadata(picker.item_count - 1, id)
	selection.add_child(picker)
	picker.item_selected.connect(func(_index: int): _selection_changed())
	var tax_label := Label.new()
	tax_label.text = "Income tax:"
	selection.add_child(tax_label)
	tax = SpinBox.new()
	tax.min_value = 0
	tax.max_value = 60
	tax.step = 1
	tax.suffix = "%"
	tax.custom_minimum_size = Vector2(105, 0)
	selection.add_child(tax)
	var apply := Button.new()
	apply.text = "Apply to selected country"
	apply.pressed.connect(apply_tax)
	selection.add_child(apply)
	selected_details = Label.new()
	selected_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(selected_details)
	dialogue_button = Button.new()
	dialogue_button.text = "Open dialogue between the two countries"
	dialogue_button.pressed.connect(start_dialogue)
	add_child(dialogue_button)
	add_child(message)
	_selection_changed()

func selected_id() -> String:
	return str(picker.get_item_metadata(picker.selected)) if picker != null and picker.selected >= 0 else ""

func _selection_changed() -> void:
	var state: Dictionary = registry.country_snapshot(selected_id())
	if state.is_empty():
		return
	tax.value = state.country.income_tax_rate * 100.0
	refresh()

func refresh() -> void:
	if not initialized:
		return
	var a: Dictionary = registry.country_snapshot(USA)
	var b: Dictionary = registry.country_snapshot(COAST)
	var d: Dictionary = a.date
	var progress: int = registry.dialogue_progress(USA, COAST)
	var talk := "No active dialogue." if progress < 0 else "Dialogue: day %d / %d." % [progress, Registry.TALK_DAYS]
	overview.text = "LAB DATE: %04d-%02d-%02d (both countries)\n%s\n%s: approval %.1f%% | cash $%.1fM\n%s: approval %.1f%% | cash $%.1fM\nRelationship: %.1f / 100 | %s" % [d.year, d.month, d.day, "All figures and relationships are fictional.", a.country.name, a.country.approval, a.country.treasury / 1000000.0, b.country.name, b.country.approval, b.country.treasury / 1000000.0, registry.relationship(USA, COAST), talk]
	var state: Dictionary = registry.country_snapshot(selected_id())
	if not state.is_empty():
		var c: Dictionary = state.country
		selected_details.text = "SELECTED: %s\nPopulation %d | income tax %.1f%% | approval %.1f%%\nAnnual revenue $%.1fM | spending $%.1fM | debt $%.1fM" % [c.name, c.population, c.income_tax_rate * 100.0, c.approval, c.annual_revenue / 1000000.0, c.annual_spending / 1000000.0, c.debt / 1000000.0]
	dialogue_button.disabled = progress >= 0

func _action(action: String) -> void:
	match action:
		"advance": advance_day()
		"save": save_to(LAB_SAVE)
		"load": load_confirmation.popup_centered()

func advance_day() -> void:
	if not initialized:
		return
	registry.advance_day()
	message.text = "Advanced both lab countries by one day."
	refresh()

func apply_tax() -> void:
	if not initialized:
		return
	var result: Dictionary = registry.execute_country(selected_id(), {"id": "set_income_tax", "args": {"rate": tax.value / 100.0}})
	message.text = result.message
	refresh()

func start_dialogue() -> void:
	if not initialized:
		return
	message.text = "Dialogue opened; it completes after 30 lab days." if registry.start_dialogue(USA, COAST) else "Dialogue is already active or unavailable."
	refresh()

func save_to(path: String) -> String:
	if not initialized:
		return "World lab is unavailable."
	var error: String = registry.save_game(path)
	message.text = "Lab world saved to its separate slot." if error.is_empty() else error
	return error

func load_from(path: String) -> String:
	if not initialized:
		return "World lab is unavailable."
	var candidate = Registry.new()
	var error: String = candidate.load_game(path)
	if error.is_empty() and candidate.country_ids() != [COAST, USA]:
		error = "This save is not the two-country lab world."
	if error.is_empty() and (candidate.country_snapshot(USA).scenario_id != "usa_sandbox" or candidate.country_snapshot(COAST).scenario_id != "coastal_test"):
		error = "This save has unexpected lab scenario identities."
	if not error.is_empty():
		message.text = error
		return error
	registry = candidate
	message.text = "Lab world loaded; the main game was not changed."
	_selection_changed()
	return ""
