extends VBoxContainer

const Registry = preload("res://simulation/world_registry.gd")
const World = preload("res://simulation/world.gd")
const WorldMap = preload("res://ui/world_map.gd")
const LAB_SAVE := "user://experimental_world_save.json"
const USA := "usa_sandbox"
const COAST := "coastal_republic"
const MAX_DAYS_PER_FRAME := 10
const FRAME_BUDGET_USEC := 8000
var registry = Registry.new()
var picker: OptionButton
var tax: SpinBox
var overview: Label
var selected_details: Label
var message: Label
var load_confirmation: ConfirmationDialog
var pending_load_path := ""
var dialogue_button: Button
var cancel_talks_button: Button
var proposal_picker: OptionButton
var diplomacy_preview: Label
var lab_map: Control
var map_status: Label
var initialized := false
var running := false
var elapsed := 0.0
var batch_remaining := 0
var clock_buttons: Dictionary = {}
var guarded_controls: Array = []
var speed_picker: OptionButton
var clock_status: Label

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
	for spec in [["Save lab world", "save"], ["Load lab world", "load"], ["Load lab backup", "backup"]]:
		var button := Button.new()
		button.text = spec[0]
		var action: String = spec[1]
		button.pressed.connect(func(): _action(action))
		actions.add_child(button)
		guarded_controls.append(button)
	var clock_controls := HBoxContainer.new()
	add_child(clock_controls)
	for spec in [["Run lab", "toggle"], ["Advance 1 day", "advance"], ["Advance 30 days", "batch"], ["Cancel 30-day advance", "cancel"]]:
		var button := Button.new()
		button.text = spec[0]
		var action: String = spec[1]
		button.pressed.connect(func(): _action(action))
		clock_controls.add_child(button)
		clock_buttons[action] = button
	speed_picker = OptionButton.new()
	for speed in [1, 3, 10]:
		speed_picker.add_item("%d days/sec" % speed, speed)
	clock_controls.add_child(speed_picker)
	speed_picker.item_selected.connect(func(_index: int): _refresh_clock())
	clock_status = Label.new()
	clock_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(clock_status)
	load_confirmation = ConfirmationDialog.new()
	load_confirmation.title = "Load experimental world?"
	load_confirmation.dialog_text = "Loading replaces the current lab world. Save it first if you want to keep it. The main game is not changed."
	load_confirmation.confirmed.connect(_confirm_load)
	load_confirmation.canceled.connect(func(): pending_load_path = "")
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
	guarded_controls.append(picker)
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
	guarded_controls.append(tax)
	var apply := Button.new()
	apply.text = "Apply to selected country"
	apply.pressed.connect(apply_tax)
	selection.add_child(apply)
	guarded_controls.append(apply)
	selected_details = Label.new()
	selected_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(selected_details)
	proposal_picker = OptionButton.new()
	proposal_picker.add_item("Open dialogue")
	proposal_picker.add_item("Cooperation agreement")
	add_child(proposal_picker)
	guarded_controls.append(proposal_picker)
	proposal_picker.item_selected.connect(func(_index: int): refresh())
	diplomacy_preview = Label.new()
	diplomacy_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(diplomacy_preview)
	var diplomacy_actions := HBoxContainer.new()
	add_child(diplomacy_actions)
	dialogue_button = Button.new()
	dialogue_button.text = "Start selected talks"
	dialogue_button.pressed.connect(start_dialogue)
	diplomacy_actions.add_child(dialogue_button)
	cancel_talks_button = Button.new()
	cancel_talks_button.text = "Cancel talks"
	cancel_talks_button.pressed.connect(cancel_talks)
	diplomacy_actions.add_child(cancel_talks_button)
	add_child(message)
	var map_title := Label.new()
	map_title.text = "LAB MAP — click the US to select its sandbox"
	add_child(map_title)
	map_status = Label.new()
	map_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_status.text = "US is mapped to the lab sandbox. Coastal Republic is fictional and has no geographic location."
	add_child(map_status)
	var map_controls := HBoxContainer.new()
	add_child(map_controls)
	for spec in [["+", "in"], ["−", "out"], ["Reset lab map", "reset"]]:
		var button := Button.new()
		button.text = spec[0]
		var action: String = spec[1]
		button.pressed.connect(func(): _map_action(action))
		map_controls.add_child(button)
	lab_map = WorldMap.new()
	lab_map.custom_minimum_size = Vector2(0, 400)
	lab_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(lab_map)
	lab_map.set_scenario_layer(1, ["USA"], "USA")
	lab_map.country_selected.connect(_on_map_country)
	lab_map.city_selected.connect(func(city: Dictionary): _on_map_country(city.get("country", ""), city.name))
	_selection_changed()

func selected_id() -> String:
	return str(picker.get_item_metadata(picker.selected)) if picker != null and picker.selected >= 0 else ""

func _selection_changed() -> void:
	var state: Dictionary = registry.country_snapshot(selected_id())
	if state.is_empty():
		return
	tax.value = state.country.income_tax_rate * 100.0
	if lab_map != null:
		lab_map.selected_id = "USA" if selected_id() == USA else ""
		lab_map.selected_city_name = ""
		lab_map.queue_redraw()
		map_status.text = "US sandbox selected in the lab." if selected_id() == USA else "Coastal Republic is fictional and has no geographic location."
	refresh()

func _on_map_country(id: String, display_name: String) -> void:
	if id != "USA":
		map_status.text = "%s is reference geography only; the selected lab country did not change." % display_name
		return
	for index in range(picker.item_count):
		if picker.get_item_metadata(index) == USA:
			picker.select(index)
			_selection_changed()
			return

func _map_action(action: String) -> void:
	match action:
		"in": lab_map.zoom_at(lab_map.size / 2.0, 1.25)
		"out": lab_map.zoom_at(lab_map.size / 2.0, 0.8)
		"reset": lab_map.reset_view()

func refresh() -> void:
	if not initialized:
		return
	var a: Dictionary = registry.country_snapshot(USA)
	var b: Dictionary = registry.country_snapshot(COAST)
	var d: Dictionary = a.date
	var progress: int = registry.dialogue_progress(USA, COAST)
	var talk := "No active talks." if progress < 0 else "%s talks: day %d / %d." % [registry.talk_kind(USA, COAST).capitalize(), progress, Registry.TALK_DAYS]
	var remaining: int = registry.agreement_days(USA, COAST)
	overview.text = "LAB DATE: %04d-%02d-%02d (both countries)\n%s\n%s: approval %.1f%% | cash $%.1fM\n%s: approval %.1f%% | cash $%.1fM\nRelationship: %.1f / 100 | %s" % [d.year, d.month, d.day, "All figures and relationships are fictional.", a.country.name, a.country.approval, a.country.treasury / 1000000.0, b.country.name, b.country.approval, b.country.treasury / 1000000.0, registry.relationship(USA, COAST), talk]
	overview.text += "\nCooperation: %s" % ("active for %d more days" % remaining if remaining > 0 else "no active agreement")
	var state: Dictionary = registry.country_snapshot(selected_id())
	if not state.is_empty():
		var c: Dictionary = state.country
		selected_details.text = "SELECTED: %s\nPopulation %d | income tax %.1f%% | approval %.1f%%\nAnnual revenue $%.1fM | spending $%.1fM | debt $%.1fM" % [c.name, c.population, c.income_tax_rate * 100.0, c.approval, c.annual_revenue / 1000000.0, c.annual_spending / 1000000.0, c.debt / 1000000.0]
	var cooperation := proposal_picker.selected == 1
	var available := not cooperation or remaining == 0
	if cooperation:
		diplomacy_preview.text = "COOPERATION — fictional test rules\nTalks last 30 days. If relations are at least %.0f and both countries have $%.1fM cash when talks finish, each pays a one-time $%.1fM, relations rise by %.0f and an agreement lasts %d days. No recurring payments or trade effects are modeled. Current eligibility: %s.%s" % [Registry.COOPERATION_MIN_RELATION, Registry.COOPERATION_COST / 1000000.0, Registry.COOPERATION_COST / 1000000.0, Registry.COOPERATION_GAIN, Registry.AGREEMENT_DAYS, "eligible" if registry.cooperation_eligible(USA, COAST) else "not eligible", " An existing agreement prevents new cooperation talks." if not available else ""]
	else:
		diplomacy_preview.text = "DIALOGUE — fictional test rules\nTalks last 30 days and add %.0f relations when complete; no direct cash cost." % Registry.RELATION_GAIN
	dialogue_button.disabled = progress >= 0 or not available
	cancel_talks_button.disabled = progress < 0
	_refresh_clock()

func _refresh_clock() -> void:
	if clock_status == null:
		return
	var batching := batch_remaining > 0
	clock_buttons.toggle.disabled = batching
	clock_buttons.advance.disabled = running or batching
	clock_buttons.batch.disabled = running or batching
	clock_buttons.cancel.disabled = not batching
	clock_buttons.toggle.text = "Pause lab" if running else "Run lab"
	speed_picker.disabled = batching
	for control in guarded_controls:
		if control is SpinBox:
			control.editable = not batching
		else:
			control.disabled = batching
	if dialogue_button != null and batching:
		dialogue_button.disabled = true
		cancel_talks_button.disabled = true
	clock_status.text = "LAB CLOCK: %s | %d queued day(s) | 30-day advance remaining: %d. Lab time is independent and continues while running, even on another tab." % ["running" if running else "paused", floori(elapsed), batch_remaining]

func _process(delta: float) -> void:
	if not initialized:
		return
	if running:
		elapsed += maxf(0.0, delta) * speed_picker.get_selected_id()
	var processed := 0
	var started := Time.get_ticks_usec()
	while (batch_remaining > 0 or (running and elapsed >= 1.0)) and processed < MAX_DAYS_PER_FRAME:
		if processed > 0 and Time.get_ticks_usec() - started >= FRAME_BUDGET_USEC:
			break
		if batch_remaining > 0:
			batch_remaining -= 1
		else:
			elapsed -= 1.0
		registry.advance_day()
		processed += 1
	if processed > 0:
		if batch_remaining == 0 and not running:
			message.text = "30-day lab advance completed."
		refresh()
	elif running:
		_refresh_clock()

func _action(action: String) -> void:
	match action:
		"toggle":
			running = not running
			_refresh_clock()
		"advance": advance_day()
		"batch":
			if not running and batch_remaining == 0:
				batch_remaining = 30
				message.text = "Advancing the lab by 30 days; cancel stops future days."
				_refresh_clock()
		"cancel":
			batch_remaining = 0
			message.text = "30-day advance cancelled; completed days remain."
			refresh()
		"save": save_to(LAB_SAVE)
		"load": _request_load(false)
		"backup": _request_load(true)

func _request_load(backup: bool) -> void:
	running = false
	batch_remaining = 0
	elapsed = 0.0
	refresh()
	message.text = "Lab clock paused and queued days cleared before loading."
	pending_load_path = LAB_SAVE + (".bak" if backup else "")
	load_confirmation.dialog_text = "Loading the lab %s replaces the current lab world. Save it first if you want to keep it. The main game is not changed." % ("backup" if backup else "save")
	load_confirmation.popup_centered()

func _confirm_load() -> void:
	var path := pending_load_path
	pending_load_path = ""
	if not path.is_empty():
		load_from(path)

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
	var kind := "cooperation" if proposal_picker.selected == 1 else "dialogue"
	message.text = "%s talks opened; they conclude after 30 lab days." % kind.capitalize() if registry.start_talks(USA, COAST, kind) else "Talks are already active or unavailable."
	refresh()

func cancel_talks() -> void:
	if not initialized:
		return
	message.text = "Talks cancelled." if registry.cancel_talks(USA, COAST) else "No talks are active."
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
	running = false
	batch_remaining = 0
	elapsed = 0.0
	message.text = "Lab world loaded; the main game was not changed."
	_selection_changed()
	return ""
