extends Control

const World = preload("res://simulation/world.gd")
const MAX_DAYS_PER_FRAME := 30
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
var politics_summary: Label
var tax_preview: Label
var spending_preview: Label
const SAVE_PATH := "user://prototype_save.json"

func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(edge, 24)
	add_child(margin)
	var scroll := ScrollContainer.new()
	margin.add_child(scroll)
	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 12)
	scroll.add_child(layout)
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
	explanation.text = "Budget = annual revenue minus base spending and policy costs. The daily change divides this balance by the days in the year. All effects are fictional placeholders."
	layout.add_child(explanation)
	tax_preview = Label.new()
	tax_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(tax_preview)
	tax.value_changed.connect(_update_tax_preview)
	spending_preview = Label.new()
	spending_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(spending_preview)
	spending.value_changed.connect(_update_spending_preview)
	politics_summary = Label.new()
	politics_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(politics_summary)
	var political_controls := HBoxContainer.new()
	layout.add_child(political_controls)
	var vote_button := Button.new()
	vote_button.text = "Vote on procurement policy"
	vote_button.pressed.connect(_vote_policy)
	political_controls.add_child(vote_button)
	var repeal_button := Button.new()
	repeal_button.text = "Vote to repeal procurement"
	repeal_button.pressed.connect(_repeal_policy)
	political_controls.add_child(repeal_button)
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
		var processed := 0
		while elapsed >= 1.0 and processed < MAX_DAYS_PER_FRAME:
			elapsed -= 1.0
			world.advance_day()
			processed += 1
		if processed > 0:
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

func _vote_policy() -> void:
	world.vote_procurement()
	_refresh()

func _repeal_policy() -> void:
	world.vote_procurement_repeal()
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
	summary.text = "%s\nDate: %04d-%02d-%02d\nPopulation: %d\nTreasury: $%.0f\nAnnual revenue: $%.0f   |   Base spending: $%.0f\nAnnual policy cost: $%.0f\nAnnual balance: $%.0f   |   Daily change: $%.2f\nIncome tax: %.1f%%   |   Approval: %.1f%%" % [c.name, d.year, d.month, d.day, c.population, c.treasury, c.annual_revenue, c.annual_spending, world.policy_annual_cost(), world.annual_balance(), world.daily_balance(), c.income_tax_rate * 100.0, c.approval]
	var lines := PackedStringArray(["POLITICS — fictional test model"])
	for group in world.politics.groups:
		lines.append("%s (%.0f%% of population): %.1f%% approval" % [group.name, group.share * 100, group.approval])
	for party in world.politics.parties:
		lines.append("%s: %d seats" % [party.name, party.seats])
	lines.append("Procurement support: %d/100 seats | Implementation: %d%% | Elections: %d" % [world.politics.votes_for_policy(), world.politics.procurement_progress, world.politics.election_count])
	lines.append("Repeal support: %d/100 seats (opponents of the policy)." % world.politics.votes_for_repeal())
	lines.append("Test policy requires a majority, takes 100 days and then costs $%.0f per year. Next illustrative election: January 1, %d. Seat allocation is a simplified placeholder." % [world.PROCUREMENT_ANNUAL_COST, world.next_election_year()])
	politics_summary.text = "\n".join(lines)
	history.text = "\n".join(world.events.slice(0, 8))
	_update_tax_preview(tax.value)
	_update_spending_preview(spending.value)

func _update_tax_preview(value: float) -> void:
	var preview: Dictionary = world.preview_income_tax(value / 100.0)
	if preview.is_empty():
		tax_preview.text = "Tax preview unavailable."
		return
	var lines := PackedStringArray(["TAX PREVIEW (fictional immediate model)", "Projected annual revenue: $%.0f | National approval: %.1f%%" % [preview.annual_revenue, preview.approval]])
	for group in preview.groups:
		lines.append("%s: %.1f%% approval" % [group.name, group.approval])
	tax_preview.text = "\n".join(lines)

func _update_spending_preview(value: float) -> void:
	var preview: Dictionary = world.preview_annual_spending(value * 1000000.0)
	if preview.is_empty():
		spending_preview.text = "Spending preview unavailable."
		return
	spending_preview.text = "SPENDING PREVIEW (fictional budget model)\nAnnual balance: $%.0f | Daily treasury change: $%.2f\nServices, employment and public opinion are not yet modeled." % [preview.annual_balance, preview.daily_balance]
