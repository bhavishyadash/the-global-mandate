extends Control

const World = preload("res://simulation/world.gd")
var world = World.new()
var running := false
var elapsed := 0.0
var summary: Label
var history: Label
var tax: SpinBox
var pause_button: Button
var status: Label
var spending: SpinBox
var speed := 1
var explanation: Label
const SAVE_PATH := "user://prototype_save.json"

func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(edge, 24)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)
	var title := Label.new()
	title.text = "THE GLOBAL MANDATE  |  Simulation foundation"
	title.add_theme_font_size_override("font_size", 25)
	layout.add_child(title)
	var notice := Label.new()
	notice.text = "Prototype: fictional data and simplified placeholder calculations."
	layout.add_child(notice)
	summary = Label.new()
	layout.add_child(summary)
	var controls := HBoxContainer.new()
	layout.add_child(controls)
	pause_button = Button.new()
	pause_button.text = "Resume"
	pause_button.pressed.connect(_toggle_pause)
	controls.add_child(pause_button)
	var next_day := Button.new()
	next_day.text = "Advance one day"
	next_day.pressed.connect(_advance_day)
	controls.add_child(next_day)
	var tax_label := Label.new()
	tax_label.text = "   Income tax (%) "
	controls.add_child(tax_label)
	tax = SpinBox.new()
	tax.min_value = 0.0
	tax.max_value = 60.0
	tax.step = 1.0
	tax.value = 20.0
	controls.add_child(tax)
	var apply := Button.new()
	apply.text = "Apply test policy"
	apply.pressed.connect(_apply_tax)
	controls.add_child(apply)
	var save_button := Button.new()
	save_button.text = "Save"
	save_button.pressed.connect(_save_game)
	controls.add_child(save_button)
	var load_button := Button.new()
	load_button.text = "Load"
	load_button.pressed.connect(_load_game)
	controls.add_child(load_button)
	var backup_button := Button.new()
	backup_button.text = "Load backup"
	backup_button.pressed.connect(_load_backup)
	controls.add_child(backup_button)
	var budget_controls := HBoxContainer.new()
	layout.add_child(budget_controls)
	var spending_label := Label.new()
	spending_label.text = "Annual government spending ($ millions) "
	budget_controls.add_child(spending_label)
	spending = SpinBox.new()
	spending.min_value = 0
	spending.max_value = 10000
	spending.step = 10
	spending.value = 1100
	budget_controls.add_child(spending)
	var apply_spending := Button.new()
	apply_spending.text = "Apply spending"
	apply_spending.pressed.connect(_apply_spending)
	budget_controls.add_child(apply_spending)
	var speed_label := Label.new()
	speed_label.text = "   Speed: "
	budget_controls.add_child(speed_label)
	var speed_picker := OptionButton.new()
	for multiplier in [1, 5, 30]:
		speed_picker.add_item("%d days/sec" % multiplier, multiplier)
	speed_picker.item_selected.connect(func(index: int): speed = speed_picker.get_item_id(index))
	budget_controls.add_child(speed_picker)
	status = Label.new()
	layout.add_child(status)
	explanation = Label.new()
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.text = "Budget = annual revenue minus annual spending. The daily change divides this balance by the days in the year. Tax and approval effects are fictional placeholders; spending currently affects only the budget."
	layout.add_child(explanation)
	var heading := Label.new()
	heading.text = "RECENT DECISIONS"
	layout.add_child(heading)
	history = Label.new()
	history.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(history)
	_refresh()

func _process(delta: float) -> void:
	if running:
		elapsed += delta * speed
		while elapsed >= 1.0:
			elapsed -= 1.0
			world.advance_day()
			_refresh()

func _toggle_pause() -> void:
	running = not running
	pause_button.text = "Pause" if running else "Resume"

func _advance_day() -> void:
	world.advance_day()
	_refresh()

func _apply_tax() -> void:
	world.set_income_tax(tax.value / 100.0)
	_refresh()

func _apply_spending() -> void:
	world.set_annual_spending(spending.value * 1000000.0)
	_refresh()

func _save_game() -> void:
	var error: String = world.save_game(SAVE_PATH)
	status.text = "Game saved." if error.is_empty() else error

func _load_game() -> void:
	_load_from(SAVE_PATH)

func _load_backup() -> void:
	_load_from(SAVE_PATH + ".bak")

func _load_from(path: String) -> void:
	var error: String = world.load_game(path)
	if error.is_empty():
		running = false
		elapsed = 0.0
		pause_button.text = "Resume"
		tax.value = world.country.income_tax_rate * 100.0
		spending.value = world.country.annual_spending / 1000000.0
		status.text = "Game loaded and paused."
		_refresh()
	else:
		status.text = error

func _refresh() -> void:
	var c: Dictionary = world.country
	var d: Dictionary = world.date
	summary.text = "%s\nDate: %04d-%02d-%02d\nPopulation: %d\nTreasury: $%.0f\nAnnual revenue: $%.0f   |   Annual spending: $%.0f\nAnnual balance: $%.0f   |   Daily change: $%.2f\nIncome tax: %.1f%%   |   Approval: %.1f%%" % [c.name, d.year, d.month, d.day, c.population, c.treasury, c.annual_revenue, c.annual_spending, world.annual_balance(), world.daily_balance(), c.income_tax_rate * 100.0, c.approval]
	history.text = "\n".join(world.events.slice(0, 8))
