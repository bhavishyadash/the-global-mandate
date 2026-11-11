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
var category_picker: OptionButton
var category_amount: SpinBox
var category_preview: Label
var additional_tax_picker: OptionButton
var additional_tax: SpinBox
var additional_tax_preview: Label
var directive_picker: OptionButton
var directive_summary: Label
var dashboard_tabs: TabContainer
var forecast_label: Label
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
	spending_label.text = "Reset total budget ($ millions) "
	budget_controls.add_child(spending_label)
	spending = SpinBox.new()
	spending.min_value = 0
	spending.max_value = 10000
	spending.step = 0.01
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
	var category_controls := HBoxContainer.new()
	layout.add_child(category_controls)
	category_picker = OptionButton.new()
	for category in World.CATEGORY_SHARES:
		category_picker.add_item(category)
	category_controls.add_child(category_picker)
	category_amount = SpinBox.new()
	category_amount.min_value = 0
	category_amount.max_value = 10000
	category_amount.step = 0.01
	category_amount.value = world.country.spending_categories[category_picker.get_item_text(0)] / 1000000.0
	category_controls.add_child(category_amount)
	var category_button := Button.new()
	category_button.text = "Apply category ($ millions)"
	category_button.pressed.connect(_apply_category)
	category_controls.add_child(category_button)
	var tax_controls := HBoxContainer.new()
	layout.add_child(tax_controls)
	additional_tax_picker = OptionButton.new()
	additional_tax_picker.add_item("Consumption tax")
	additional_tax_picker.add_item("Corporate tax")
	tax_controls.add_child(additional_tax_picker)
	additional_tax = SpinBox.new()
	additional_tax.min_value = 0.0
	additional_tax.max_value = 60.0
	additional_tax.step = 0.1
	tax_controls.add_child(additional_tax)
	var additional_tax_button := Button.new()
	additional_tax_button.text = "Apply selected tax (%)"
	additional_tax_button.pressed.connect(_apply_additional_tax)
	tax_controls.add_child(additional_tax_button)
	status = Label.new()
	layout.add_child(status)
	explanation = Label.new()
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.text = "Balance = revenue minus categories, policy costs and debt interest. Deficits use cash then borrow; surpluses repay debt then add cash. Category funding gradually affects service conditions and approval in the fictional test model. Resetting the total restores initial shares."
	layout.add_child(explanation)
	tax_preview = Label.new()
	tax_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(tax_preview)
	tax.value_changed.connect(_update_tax_preview)
	additional_tax_preview = Label.new()
	additional_tax_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(additional_tax_preview)
	additional_tax_picker.item_selected.connect(_additional_tax_selected)
	additional_tax.value_changed.connect(_update_additional_tax_preview)
	spending_preview = Label.new()
	spending_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(spending_preview)
	spending.value_changed.connect(_update_spending_preview)
	category_preview = Label.new()
	category_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(category_preview)
	category_picker.item_selected.connect(_category_selected)
	category_amount.value_changed.connect(_update_category_preview)
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
	var directive_controls := HBoxContainer.new()
	layout.add_child(directive_controls)
	directive_picker = OptionButton.new()
	directive_picker.add_item("Procurement reporting")
	directive_picker.add_item("Override spending limit")
	directive_controls.add_child(directive_picker)
	var directive_button := Button.new()
	directive_button.text = "Issue directive"
	directive_button.pressed.connect(_issue_directive)
	directive_controls.add_child(directive_button)
	var revoke_button := Button.new()
	revoke_button.text = "Revoke directive"
	revoke_button.pressed.connect(_revoke_directive)
	directive_controls.add_child(revoke_button)
	directive_summary = Label.new()
	directive_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(directive_summary)
	directive_picker.item_selected.connect(func(_index: int): _refresh_directive())
	var heading := Label.new()
	heading.text = "RECENT DECISIONS"
	layout.add_child(heading)
	history = Label.new()
	history.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(history)
	# Keep the clock, income tax and save controls visible while grouping the
	# growing decision panels into independently scrollable sections.
	dashboard_tabs = TabContainer.new()
	dashboard_tabs.custom_minimum_size = Vector2(0, 520)
	dashboard_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dashboard_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(dashboard_tabs)
	var overview := _make_dashboard_tab("Overview")
	var finances := _make_dashboard_tab("Budget & services")
	var taxes := _make_dashboard_tab("Tax previews")
	var government := _make_dashboard_tab("Government")
	var decisions := _make_dashboard_tab("History")
	for node in [summary, explanation]:
		node.reparent(overview)
	for node in [budget_controls, category_controls, spending_preview, category_preview]:
		node.reparent(finances)
	var forecast_button := Button.new()
	forecast_button.text = "Forecast next 365 days"
	forecast_button.pressed.connect(_forecast_budget)
	finances.add_child(forecast_button)
	forecast_label = Label.new()
	forecast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	forecast_label.text = "Forecast on demand; rerun after changing settings or advancing time."
	finances.add_child(forecast_label)
	for node in [tax_controls, tax_preview, additional_tax_preview]:
		node.reparent(taxes)
	for node in [politics_summary, political_controls, directive_controls, directive_summary]:
		node.reparent(government)
	for node in [heading, history]:
		node.reparent(decisions)
	_refresh()

func _make_dashboard_tab(title: String) -> VBoxContainer:
	var panel := ScrollContainer.new()
	panel.name = title
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dashboard_tabs.add_child(panel)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)
	return column

func _forecast_budget() -> void:
	var result: Dictionary = world.forecast_fiscal(365)
	if result.is_empty():
		forecast_label.text = "Forecast unavailable for this state."
		return
	var d: Dictionary = result.end_date
	var warning := "Cash exhausted by day %d." % result.first_cash_exhaustion_day if result.first_cash_exhaustion_day > 0 else "Cash remains positive."
	forecast_label.text = "365-DAY FORECAST to %04d-%02d-%02d (current settings; rerun after changes)\nCash $%.0f | Debt $%.0f | Approval %.1f%%\nRevenue $%.0f | Spending $%.0f | Policy $%.0f | Interest $%.0f\n%s Fictional model; no unmodeled future shocks or decisions." % [d.year, d.month, d.day, result.cash, result.debt, result.approval, result.revenue, result.spending, result.policy, result.interest, warning]

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

func _additional_tax_kind() -> String:
	return "consumption" if additional_tax_picker.selected == 0 else "corporate"

func _additional_tax_selected(_index: int) -> void:
	var kind := _additional_tax_kind()
	additional_tax.value = world.country[world.ADDITIONAL_TAXES[kind].field] * 100.0
	_update_additional_tax_preview(additional_tax.value)

func _apply_additional_tax() -> void:
	var kind := _additional_tax_kind()
	status.text = "%s tax updated." % kind.capitalize() if world.set_additional_tax(kind, additional_tax.value / 100.0) else "Tax change is unavailable."
	_refresh()

func _apply_spending() -> void:
	world.set_annual_spending(spending.value * 1000000.0)
	_category_selected(category_picker.selected)
	_refresh()

func _category_selected(index: int) -> void:
	var name := category_picker.get_item_text(index)
	category_amount.value = world.country.spending_categories[name] / 1000000.0
	_update_category_preview(category_amount.value)

func _apply_category() -> void:
	var name := category_picker.get_item_text(category_picker.selected)
	if world.set_category_spending(name, category_amount.value * 1000000.0):
		spending.value = world.country.annual_spending / 1000000.0
		status.text = "%s budget updated." % name
	else:
		status.text = "Category change exceeds the total budget limit."
	_refresh()

func _vote_policy() -> void:
	world.vote_procurement()
	_refresh()

func _repeal_policy() -> void:
	world.vote_procurement_repeal()
	_refresh()

func _issue_directive() -> void:
	var kind := "reporting" if directive_picker.selected == 0 else "override"
	status.text = "Directive issued." if world.issue_directive(kind) else "Finish or revoke the active directive first."
	_refresh()

func _revoke_directive() -> void:
	status.text = "Directive revoked." if world.revoke_directive() else "No active directive to revoke."
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
		_additional_tax_selected(additional_tax_picker.selected)
		spending.value = world.country.annual_spending / 1000000.0
		_category_selected(category_picker.selected)
		status.text = "Game loaded and paused."
		_refresh()
	else:
		status.text = error

func _refresh() -> void:
	var c: Dictionary = world.country
	var d: Dictionary = world.date
	summary.text = "%s\nDate: %04d-%02d-%02d\nPopulation: %d\nCash: $%.0f  |  Debt: $%.0f\nAnnual revenue: $%.0f   |   Category spending: $%.0f\nAnnual policy cost: $%.0f  |  Debt interest: $%.0f\nAnnual balance: $%.0f   |   Daily net flow: $%.2f\nIncome tax: %.1f%%   |   Approval: %.1f%%" % [c.name, d.year, d.month, d.day, c.population, c.treasury, c.debt, c.annual_revenue, c.annual_spending, world.policy_annual_cost(), world.debt_interest(), world.annual_balance(), world.daily_balance(), c.income_tax_rate * 100.0, c.approval]
	var budget_lines := PackedStringArray(["ANNUAL CATEGORY SPENDING"])
	var consumption_revenue: float = world.additional_tax_revenue("consumption")
	var corporate_revenue: float = world.additional_tax_revenue("corporate")
	budget_lines.append("Tax revenue (fixed test bases): income $%.0f | consumption $%.0f | corporate $%.0f | other revenue $%.0f" % [world.income_tax_revenue(), consumption_revenue, corporate_revenue, c.annual_revenue - world.income_tax_revenue() - consumption_revenue - corporate_revenue])
	for category in World.CATEGORY_SHARES:
		budget_lines.append("%s: $%.0f | service %.1f/100 | target %.1f" % [category, c.spending_categories[category], world.services.levels[category], world.services.target(category, c.spending_categories[category], c.population)])
	var ledger: Dictionary = world.fiscal
	budget_lines.append("RECORDED THIS YEAR: %d days%s | Revenue $%.0f | Spending $%.0f | Policy $%.0f | Interest $%.0f" % [ledger.days, " (partial history)" if ledger.partial else "", ledger.revenue, ledger.spending, ledger.policy, ledger.interest])
	budget_lines.append("Borrowed $%.0f | Repaid $%.0f | Recorded balance $%.0f" % [ledger.borrowed, ledger.repaid, ledger.revenue - ledger.spending - ledger.policy - ledger.interest])
	if not world.previous_fiscal.is_empty():
		var previous: Dictionary = world.previous_fiscal
		budget_lines.append("PREVIOUS YEAR: %d days%s | Revenue $%.0f | Total expenses $%.0f | Borrowed $%.0f | Repaid $%.0f" % [previous.days, " (partial history)" if previous.partial else "", previous.revenue, previous.spending + previous.policy + previous.interest, previous.borrowed, previous.repaid])
	summary.text += "\n" + "\n".join(budget_lines)
	var lines := PackedStringArray(["POLITICS — fictional test model"])
	for group in world.politics.groups:
		lines.append("%s (%.0f%% of population): %.1f%% approval" % [group.name, group.share * 100, group.approval])
	for party in world.politics.parties:
		lines.append("%s: %d seats" % [party.name, party.seats])
	lines.append("Procurement support: %d/100 seats | Implementation: %d%% | Elections: %d" % [world.politics.votes_for_policy(), world.politics.procurement_progress, world.politics.election_count])
	lines.append("Repeal support: %d/100 seats (opponents of the policy)." % world.politics.votes_for_repeal())
	lines.append("Test policy requires a majority, takes 100 days and then costs $%.0f per year. Next illustrative election: January 1, %d. Seat allocation is a simplified placeholder." % [world.PROCUREMENT_ANNUAL_COST, world.next_election_year()])
	politics_summary.text = "\n".join(lines)
	_refresh_directive()
	history.text = "\n".join(world.events.slice(0, 8))
	_update_tax_preview(tax.value)
	_update_additional_tax_preview(additional_tax.value)
	_update_spending_preview(spending.value)
	_update_category_preview(category_amount.value)

func _refresh_directive() -> void:
	var model = world.institutions
	var selected := "reporting" if directive_picker.selected == 0 else "override"
	var choice: Dictionary = model.CASES[selected]
	var active_name: String = model.CASES[model.kind].name if model.CASES.has(model.kind) else "None"
	directive_summary.text = "EXECUTIVE DIRECTIVES — fictional test rules\nSelected: %s. %s\nScenario authority: %s. Court review resolves after 30 days; the override is suspended after 10.\nCurrent: %s | status: %s | elapsed: %d days | agency progress: %d/60\nNo fiscal or economic effects are modeled." % [choice.name, choice.description, "within authority" if choice.within_authority else "exceeds authority", active_name, model.status, model.days, model.progress]

func _update_tax_preview(value: float) -> void:
	var preview: Dictionary = world.preview_income_tax(value / 100.0)
	if preview.is_empty():
		tax_preview.text = "Tax preview unavailable."
		return
	var lines := PackedStringArray(["TAX PREVIEW (fictional immediate model)", "Projected annual revenue: $%.0f | National approval: %.1f%%" % [preview.annual_revenue, preview.approval]])
	for group in preview.groups:
		lines.append("%s: %.1f%% approval" % [group.name, group.approval])
	tax_preview.text = "\n".join(lines)

func _update_additional_tax_preview(value: float) -> void:
	var kind := _additional_tax_kind()
	var preview: Dictionary = world.preview_additional_tax(kind, value / 100.0)
	if preview.is_empty():
		additional_tax_preview.text = "Tax preview unavailable."
		return
	var lines := PackedStringArray(["%s TAX PREVIEW (fictional fixed-base model)" % kind.to_upper(), "Projected annual revenue: $%.0f | National approval: %.1f%%" % [preview.annual_revenue, preview.approval]])
	for group in preview.groups:
		lines.append("%s: %.1f%% approval" % [group.name, group.approval])
	additional_tax_preview.text = "\n".join(lines)

func _update_spending_preview(value: float) -> void:
	var preview: Dictionary = world.preview_annual_spending(value * 1000000.0)
	if preview.is_empty():
		spending_preview.text = "Spending preview unavailable."
		return
	spending_preview.text = "TOTAL BUDGET PREVIEW (resets category shares)\nAnnual balance: $%.0f | Daily net flow: $%.2f\nService and approval changes develop over time; employment and wider economic effects are not modeled." % [preview.annual_balance, preview.daily_balance]

func _update_category_preview(value: float) -> void:
	var name := category_picker.get_item_text(category_picker.selected)
	var preview: Dictionary = world.preview_category_spending(name, value * 1000000.0)
	if preview.is_empty():
		category_preview.text = "Category preview unavailable: total exceeds budget limit."
		return
	var service_target: float = world.services.target(name, value * 1000000.0, world.country.population)
	category_preview.text = "%s budget preview: annual balance $%.0f | daily net flow $%.2f | long-run service target %.1f/100 (fictional)" % [name, preview.annual_balance, preview.daily_balance, service_target]
