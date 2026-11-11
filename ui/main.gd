extends Control

const World = preload("res://simulation/world.gd")
const Decisions = preload("res://simulation/decisions.gd")
const Diagnostics = preload("res://simulation/diagnostics.gd")
const WorldMap = preload("res://ui/world_map.gd")
const GovernmentTheme = preload("res://ui/government_theme.gd")
const BudgetBreakdown = preload("res://ui/budget_breakdown.gd")
const BudgetChart = preload("res://ui/budget_chart.gd")
const SCENARIOS := [
	{"id": "test_republic", "name": "Federal Republic (fictional)", "path": "res://data/scenarios/test_republic.json"},
	{"id": "coastal_test", "name": "Coastal Republic (fictional)", "path": "res://data/scenarios/coastal_test.json"},
]
const MAX_DAYS_PER_FRAME := 30
const DEFAULT_SIMULATION_BUDGET_USEC := 8000
var world = World.new()
var running := false
var elapsed := 0.0
var summary: Label
var history: Label
var tax: SpinBox
var pause_button: Button
var status: Label
var speed_status: Label
var simulation_budget_usec := DEFAULT_SIMULATION_BUDGET_USEC
var spending: SpinBox
var speed := 1
var explanation: Label
var politics_summary: Label
var congress_summary: Label
var congress_funding: OptionButton
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
var healthcare_picker: OptionButton
var healthcare_summary: Label
var appropriation_picker: OptionButton
var forecast_label: Label
var comparison_label: Label
var forecast_current := false
var comparison_current := false
var population_summary: Label
var diplomacy_picker: OptionButton
var diplomacy_summary: Label
var proposal_picker: OptionButton
var event_filter: OptionButton
var scenario_picker: OptionButton
var new_game_confirmation: ConfirmationDialog
var diagnostic_steps: TextEdit
var world_map: Control
var map_selection: Label
var map_search: LineEdit
var map_results: ItemList
var map_search_status: Label
var government_status: Label
var budget_chart: Control
var budget_mode: OptionButton
var budget_chart_note: Label
var budget_rows: Dictionary = {}
var law_categories: TabBar
var law_search: LineEdit
var law_catalog: Tree
var law_catalog_note: Label
var healthcare_panel: VBoxContainer
var procurement_panel: VBoxContainer
var procurement_detail: Label
var review_dialog: ConfirmationDialog
var pending_decision: Dictionary = {}
var review_snapshot := ""
const SAVE_PATH := "user://prototype_save.json"

func _ready() -> void:
	theme = GovernmentTheme.create()
	var background := ColorRect.new()
	background.color = GovernmentTheme.BACKGROUND
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	if not world.initialization_error.is_empty():
		var failure := Label.new()
		failure.text = "Cannot start: the default scenario is missing or invalid. " + world.initialization_error
		failure.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		add_child(failure)
		set_process(false)
		return
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(edge, 16)
	add_child(margin)
	var scroll := ScrollContainer.new()
	margin.add_child(scroll)
	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 8)
	scroll.add_child(layout)
	var title := Label.new()
	title.text = "THE GLOBAL MANDATE"
	title.add_theme_font_size_override("font_size", 22)
	layout.add_child(title)
	government_status = Label.new()
	government_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	government_status.add_theme_color_override("font_color", GovernmentTheme.ACCENT)
	layout.add_child(government_status)
	var notice := Label.new()
	notice.text = "FICTIONAL TEST SCENARIO  ·  Early simulation prototype"
	notice.add_theme_color_override("font_color", GovernmentTheme.MUTED)
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
	tax_label.text = "Income tax (%) "
	controls.add_child(tax_label)
	tax = SpinBox.new()
	tax.min_value = 0.0
	tax.max_value = 60.0
	tax.step = 1.0
	tax.value = 20.0
	controls.add_child(tax)
	var apply := Button.new()
	apply.text = "Apply income tax"
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
	var income_controls := HBoxContainer.new()
	layout.add_child(income_controls)
	for node in [tax_label, tax, apply]:
		node.reparent(income_controls)
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
	var category_label := Label.new()
	category_label.text = "Category proposal ($ millions)"
	category_controls.add_child(category_label)
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
	var status_row := HBoxContainer.new()
	layout.add_child(status_row)
	speed_status = Label.new()
	status_row.add_child(speed_status)
	status = Label.new()
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.add_child(status)
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
	vote_button.pressed.connect(func(): _request_review("vote_procurement", {}))
	political_controls.add_child(vote_button)
	var repeal_button := Button.new()
	repeal_button.text = "Vote to repeal procurement"
	repeal_button.pressed.connect(func(): _request_review("repeal_procurement", {}))
	political_controls.add_child(repeal_button)
	var directive_controls := HBoxContainer.new()
	layout.add_child(directive_controls)
	directive_picker = OptionButton.new()
	_sync_directive_picker()
	directive_controls.add_child(directive_picker)
	var directive_button := Button.new()
	directive_button.text = "Review directive"
	directive_button.pressed.connect(func(): _request_review("issue_directive", {"kind": "reporting" if directive_picker.selected == 0 else "override"}))
	directive_controls.add_child(directive_button)
	var revoke_button := Button.new()
	revoke_button.text = "Review revocation"
	revoke_button.pressed.connect(func(): _request_review("revoke_directive", {}))
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
	dashboard_tabs.custom_minimum_size = Vector2(0, 440)
	dashboard_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dashboard_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(dashboard_tabs)
	var overview := _make_dashboard_tab("Overview")
	var finances := _make_dashboard_tab("Budget & services")
	var taxes := _make_dashboard_tab("Tax previews")
	var government := _make_dashboard_tab("Government")
	var population := _make_dashboard_tab("Population")
	var diplomacy_tab := _make_dashboard_tab("Diplomacy")
	var decisions := _make_dashboard_tab("History")
	var laws := _make_dashboard_tab("Laws")
	var map_tab := _make_dashboard_tab("World Map")
	var executive := _make_dashboard_tab("Executive Orders")
	var map_controls := HBoxContainer.new()
	map_tab.add_child(map_controls)
	var map_help := Label.new()
	map_help.text = "Drag / arrows: pan  •  Wheel / + / −: zoom  •  Select a country or city"
	map_help.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_controls.add_child(map_help)
	var zoom_in := Button.new()
	zoom_in.text = "+"
	map_controls.add_child(zoom_in)
	var zoom_out := Button.new()
	zoom_out.text = "−"
	map_controls.add_child(zoom_out)
	var reset_map := Button.new()
	reset_map.text = "Reset map"
	map_controls.add_child(reset_map)
	var map_layout := HBoxContainer.new()
	map_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_tab.add_child(map_layout)
	world_map = WorldMap.new()
	world_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	world_map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_layout.add_child(world_map)
	var map_sidebar := VBoxContainer.new()
	map_sidebar.custom_minimum_size = Vector2(250, 0)
	map_layout.add_child(map_sidebar)
	map_search = LineEdit.new()
	map_search.placeholder_text = "Search countries or cities"
	map_sidebar.add_child(map_search)
	map_search_status = Label.new()
	map_search_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_sidebar.add_child(map_search_status)
	map_results = ItemList.new()
	map_results.custom_minimum_size = Vector2(0, 150)
	map_results.visible = false
	map_sidebar.add_child(map_results)
	map_search.text_changed.connect(_search_map)
	map_results.item_selected.connect(_select_map_result)
	map_selection = Label.new()
	map_selection.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_selection.text = "WORLD MAP\n\nSelect a country or city.\n\nGeography is real-world reference data. The current playable scenario is fictional and is not linked to these countries yet."
	map_sidebar.add_child(map_selection)
	world_map.country_selected.connect(_map_country_selected)
	world_map.city_selected.connect(_map_city_selected)
	zoom_in.pressed.connect(func(): world_map.zoom_at(world_map.size / 2.0, 1.25))
	zoom_out.pressed.connect(func(): world_map.zoom_at(world_map.size / 2.0, 0.8))
	reset_map.pressed.connect(func(): world_map.reset_view())
	dashboard_tabs.current_tab = 8
	for node in [summary, explanation]:
		node.reparent(overview)
	var scenario_controls := HBoxContainer.new()
	overview.add_child(scenario_controls)
	overview.move_child(scenario_controls, 0)
	scenario_picker = OptionButton.new()
	for entry in SCENARIOS:
		scenario_picker.add_item(entry.name)
	scenario_controls.add_child(scenario_picker)
	var new_game_button := Button.new()
	new_game_button.text = "Start selected scenario"
	scenario_controls.add_child(new_game_button)
	new_game_confirmation = ConfirmationDialog.new()
	new_game_confirmation.title = "Start a new scenario?"
	new_game_confirmation.dialog_text = "This replaces your current session. Save first if you want to keep your progress."
	add_child(new_game_confirmation)
	new_game_button.pressed.connect(func(): new_game_confirmation.popup_centered())
	new_game_confirmation.confirmed.connect(_confirm_new_scenario)
	for node in [budget_controls, category_controls, spending_preview, category_preview]:
		node.reparent(finances)
	var chart_controls := HBoxContainer.new()
	finances.add_child(chart_controls)
	finances.move_child(chart_controls, 0)
	var chart_heading := Label.new()
	chart_heading.text = "ANNUAL EXPENDITURE BREAKDOWN"
	chart_heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chart_controls.add_child(chart_heading)
	budget_mode = OptionButton.new()
	budget_mode.add_item("Current")
	budget_mode.add_item("Proposed category")
	budget_mode.item_selected.connect(func(_index: int): _refresh_budget_breakdown())
	chart_controls.add_child(budget_mode)
	finances.move_child(category_controls, 1)
	var chart_layout := HBoxContainer.new()
	chart_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	finances.add_child(chart_layout)
	finances.move_child(chart_layout, 2)
	budget_chart = BudgetChart.new()
	chart_layout.add_child(budget_chart)
	var table := GridContainer.new()
	table.columns = 4
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	table.add_theme_constant_override("h_separation", 16)
	table.add_theme_constant_override("v_separation", 6)
	chart_layout.add_child(table)
	for heading_text in ["Category", "Current", "Proposed", "Share"]:
		var table_header := Label.new()
		table_header.text = heading_text
		if heading_text != "Category":
			table_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			table_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		table_header.add_theme_color_override("font_color", GovernmentTheme.MUTED)
		table.add_child(table_header)
	var chart_index := 0
	for name in ["Health", "Education", "Security", "Infrastructure", "Administration", "Policy costs", "Debt interest"]:
		var name_label := Label.new()
		name_label.text = name
		name_label.add_theme_color_override("font_color", BudgetChart.COLORS[chart_index])
		table.add_child(name_label)
		var columns: Array = []
		for column in range(3):
			var cell := Label.new()
			cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			table.add_child(cell)
			columns.append(cell)
		budget_rows[name] = columns
		chart_index += 1
	budget_chart_note = Label.new()
	budget_chart_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	finances.add_child(budget_chart_note)
	finances.move_child(budget_chart_note, 3)
	var forecast_button := Button.new()
	forecast_button.text = "Forecast next 365 days"
	forecast_button.pressed.connect(_forecast_budget)
	finances.add_child(forecast_button)
	forecast_label = Label.new()
	forecast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	forecast_label.text = "Forecast on demand; rerun after changing settings or advancing time."
	finances.add_child(forecast_label)
	var compare_button := Button.new()
	compare_button.text = "Compare entered tax and total budget"
	compare_button.pressed.connect(_compare_budget)
	finances.add_child(compare_button)
	comparison_label = Label.new()
	comparison_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	comparison_label.text = "Comparison uses the entered income tax, total budget, and selected additional tax from Tax previews; it does not apply them."
	finances.add_child(comparison_label)
	for node in [income_controls, tax_controls, tax_preview, additional_tax_preview]:
		node.reparent(taxes)
	politics_summary.reparent(government)
	var congress_title := Label.new()
	congress_title.text = "US-INSPIRED BICAMERAL HEALTHCARE BILL — fictional test"
	government.add_child(congress_title)
	congress_funding = OptionButton.new()
	for amount in world.healthcare.rules.funding_options:
		congress_funding.add_item("Healthcare authorization: $%.0fM / year" % (amount / 1000000.0))
	congress_funding.select(1)
	government.add_child(congress_funding)
	var bill_controls := HBoxContainer.new()
	government.add_child(bill_controls)
	for spec in [["Introduce bill", "introduce_congress_bill"], ["Vote in chamber", "congress_vote"], ["Sign", "sign"], ["Veto", "veto"]]:
		var button := Button.new()
		button.text = spec[0]
		var action: String = spec[1]
		button.pressed.connect(func(): _request_congress_action(action))
		bill_controls.add_child(button)
	congress_summary = Label.new()
	congress_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	government.add_child(congress_summary)
	government.move_child(politics_summary, government.get_child_count() - 1)
	var executive_heading := Label.new()
	executive_heading.text = "EXECUTIVE ORDERS — fictional test scenario"
	executive.add_child(executive_heading)
	var executive_note := Label.new()
	executive_note.text = "Directives are separate from bills; this fictional court automatically reviews every directive. Real US orders require legal authority and are reviewed through actual litigation, not automatically."
	executive_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	executive.add_child(executive_note)
	for node in [directive_controls, directive_summary]:
		node.reparent(executive)
	population_summary = Label.new()
	population_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	population.add_child(population_summary)
	diplomacy_picker = OptionButton.new()
	for partner in world.diplomacy.PARTNERS:
		diplomacy_picker.add_item(world.diplomacy.PARTNERS[partner])
	diplomacy_tab.add_child(diplomacy_picker)
	proposal_picker = OptionButton.new()
	for option in world.diplomacy.PROPOSALS:
		proposal_picker.add_item(world.diplomacy.PROPOSALS[option].name)
	diplomacy_tab.add_child(proposal_picker)
	proposal_picker.item_selected.connect(func(_index: int): _refresh())
	diplomacy_picker.item_selected.connect(func(_index: int): _refresh())
	var talk_button := Button.new()
	talk_button.text = "Open diplomatic talks"
	talk_button.pressed.connect(_start_talks)
	diplomacy_tab.add_child(talk_button)
	var cancel_talks_button := Button.new()
	cancel_talks_button.text = "Cancel talks"
	cancel_talks_button.pressed.connect(_cancel_talks)
	diplomacy_tab.add_child(cancel_talks_button)
	var end_agreement_button := Button.new()
	end_agreement_button.text = "End selected cooperation agreement"
	end_agreement_button.pressed.connect(_end_cooperation)
	diplomacy_tab.add_child(end_agreement_button)
	diplomacy_summary = Label.new()
	diplomacy_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	diplomacy_tab.add_child(diplomacy_summary)
	for node in [heading, history]:
		node.reparent(decisions)
	event_filter = OptionButton.new()
	event_filter.add_item("All events")
	for category in World.EVENT_CATEGORIES:
		event_filter.add_item(category.capitalize())
	event_filter.item_selected.connect(func(_index: int): _refresh_history())
	decisions.add_child(event_filter)
	decisions.move_child(event_filter, 1)
	var diagnostic_note := Label.new()
	diagnostic_note.text = "Optional reproduction steps (review before sharing). Reports are saved locally and never sent automatically."
	diagnostic_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	decisions.add_child(diagnostic_note)
	diagnostic_steps = TextEdit.new()
	diagnostic_steps.custom_minimum_size = Vector2(0, 80)
	diagnostic_steps.placeholder_text = "What happened and how can it be reproduced?"
	decisions.add_child(diagnostic_steps)
	var diagnostic_button := Button.new()
	diagnostic_button.text = "Export local diagnostic report"
	diagnostic_button.pressed.connect(_export_diagnostics)
	decisions.add_child(diagnostic_button)
	var law_heading := Label.new()
	law_heading.text = "LAW CATALOGUE — fictional single-chamber scenario"
	laws.add_child(law_heading)
	law_categories = TabBar.new()
	for category in ["Healthcare", "Finance", "Military", "Justice", "Education"]:
		law_categories.add_tab(category)
	laws.add_child(law_categories)
	law_search = LineEdit.new()
	law_search.placeholder_text = "Search implemented laws"
	laws.add_child(law_search)
	law_catalog = Tree.new()
	law_catalog.columns = 3
	law_catalog.hide_root = true
	law_catalog.column_titles_visible = true
	law_catalog.set_column_title(0, "Law")
	law_catalog.set_column_title(1, "Status")
	law_catalog.set_column_title(2, "Annual cost")
	law_catalog.set_column_expand(0, true)
	law_catalog.custom_minimum_size = Vector2(0, 90)
	laws.add_child(law_catalog)
	law_catalog_note = Label.new()
	law_catalog_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	laws.add_child(law_catalog_note)
	healthcare_panel = VBoxContainer.new()
	healthcare_panel.add_theme_constant_override("separation", 8)
	laws.add_child(healthcare_panel)
	procurement_panel = VBoxContainer.new()
	procurement_panel.add_theme_constant_override("separation", 8)
	laws.add_child(procurement_panel)
	political_controls.reparent(procurement_panel)
	procurement_detail = Label.new()
	procurement_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	procurement_panel.add_child(procurement_detail)
	law_categories.tab_changed.connect(func(_index: int): _refresh_law_catalog())
	law_search.text_changed.connect(func(_text: String): _refresh_law_catalog())
	law_catalog.item_selected.connect(_law_catalog_selected)
	healthcare_picker = OptionButton.new()
	_sync_healthcare_picker()
	healthcare_panel.add_child(healthcare_picker)
	healthcare_picker.item_selected.connect(func(_index: int): _refresh_healthcare())
	var healthcare_vote := Button.new()
	healthcare_vote.text = "Review healthcare proposal or amendment"
	healthcare_vote.pressed.connect(func(): _request_review("vote_healthcare", {"funding": world.healthcare.rules.funding_options[healthcare_picker.selected]}))
	healthcare_panel.add_child(healthcare_vote)
	var healthcare_repeal := Button.new()
	healthcare_repeal.text = "Review healthcare repeal"
	healthcare_repeal.pressed.connect(func(): _request_review("repeal_healthcare", {}))
	healthcare_panel.add_child(healthcare_repeal)
	appropriation_picker = OptionButton.new()
	for percent in [0, 25, 50, 75, 100]:
		appropriation_picker.add_item("Proposed appropriation: %d%%" % percent)
	appropriation_picker.select(4)
	healthcare_panel.add_child(appropriation_picker)
	appropriation_picker.item_selected.connect(func(_index: int): _refresh_healthcare())
	var appropriation_button := Button.new()
	appropriation_button.text = "Review healthcare appropriation"
	appropriation_button.pressed.connect(func(): _request_review("set_healthcare_appropriation", {"fraction": appropriation_picker.selected * 0.25}))
	healthcare_panel.add_child(appropriation_button)
	healthcare_summary = Label.new()
	healthcare_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	healthcare_panel.add_child(healthcare_summary)
	review_dialog = ConfirmationDialog.new()
	review_dialog.title = "Review decision"
	review_dialog.ok_button_text = "Submit decision"
	review_dialog.dialog_autowrap = true
	review_dialog.min_size = Vector2i(600, 0)
	review_dialog.confirmed.connect(_confirm_review)
	review_dialog.canceled.connect(_cancel_review)
	add_child(review_dialog)
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

func _map_country_selected(id: String, country_name: String) -> void:
	map_selection.text = "%s\n\nGeographic ID: %s\n\nReference geography only. Country-specific simulation, regions and data are not yet linked to this map." % [country_name, id]

func _map_city_selected(city: Dictionary) -> void:
	map_selection.text = "%s\n\n%s\nCountry ID: %s\n\nReference city marker only. Detailed city art and simulation are not implemented yet." % [city.name, "National capital" if city.capital else "City", city.country]

func _search_map(query: String) -> void:
	map_results.clear()
	var text := query.strip_edges().to_lower()
	map_results.visible = not text.is_empty()
	map_search_status.text = ""
	if text.is_empty():
		return
	var matches := 0
	for kind in ["country", "city"]:
		var entries: Array = world_map.countries if kind == "country" else world_map.cities
		for i in range(entries.size()):
			if text not in entries[i].name.to_lower():
				continue
			matches += 1
			if map_results.item_count < 30:
				map_results.add_item("%s • %s" % ["Country" if kind == "country" else "City", entries[i].name])
				map_results.set_item_metadata(map_results.item_count - 1, {"kind": kind, "index": i})
	map_search_status.text = "No matches." if matches == 0 else ("Showing 30 of %d results." % matches if matches > 30 else "%d result(s)." % matches)

func _select_map_result(index: int) -> void:
	var selection: Dictionary = map_results.get_item_metadata(index)
	if selection.kind == "country":
		world_map.focus_country(world_map.countries[selection.index])
	else:
		world_map.focus_city(world_map.cities[selection.index])

func _export_diagnostics() -> void:
	var report: Dictionary = Diagnostics.report(world, diagnostic_steps.text)
	var path := "user://diagnostic_%d.json" % Time.get_ticks_usec()
	var error: String = Diagnostics.write_new(path, report)
	status.text = "Report saved: " + ProjectSettings.globalize_path(path) if error.is_empty() else error

func _forecast_budget() -> void:
	forecast_current = false
	var result: Dictionary = world.forecast_fiscal(365)
	if result.is_empty():
		forecast_label.text = "Forecast unavailable for this state."
		return
	var d: Dictionary = result.end_date
	var warning := "Cash exhausted by day %d." % result.first_cash_exhaustion_day if result.first_cash_exhaustion_day > 0 else "Cash remains positive."
	forecast_label.text = "365-DAY FORECAST to %04d-%02d-%02d (current settings; rerun after changes)\nCash $%.0f | Debt $%.0f | Approval %.1f%%\nRevenue $%.0f | Spending $%.0f | Policy $%.0f | Interest $%.0f\n%s Fictional model; no unmodeled future shocks or decisions." % [d.year, d.month, d.day, result.cash, result.debt, result.approval, result.revenue, result.spending, result.policy, result.interest, warning]
	forecast_current = true

func _compare_budget() -> void:
	comparison_current = false
	var baseline: Dictionary = world.forecast_fiscal(365)
	var kind := _additional_tax_kind()
	var changes := {"income_tax": tax.value / 100.0, "spending": spending.value * 1000000.0}
	changes[kind + "_tax"] = additional_tax.value / 100.0
	var proposed: Dictionary = world.forecast_fiscal(365, changes)
	if baseline.is_empty() or proposed.is_empty():
		comparison_label.text = "Comparison unavailable for these inputs."
		return
	comparison_label.text = "365-DAY COMPARISON (does not apply changes; rerun after edits)\nProposed: income %.1f%%, %s %.1f%%, total budget $%.0f; changing the total resets category shares.\nCash: $%.0f vs $%.0f | Debt: $%.0f vs $%.0f | Approval: %.1f%% vs %.1f%%\nValues: current settings vs proposal. Fictional rules; no future decisions or shocks." % [tax.value, kind, additional_tax.value, spending.value * 1000000.0, baseline.cash, proposed.cash, baseline.debt, proposed.debt, baseline.approval, proposed.approval]
	comparison_current = true

func _invalidate_comparison() -> void:
	if comparison_current:
		comparison_current = false
		comparison_label.text = "OUT OF DATE — rerun comparison.\n" + comparison_label.text

func _invalidate_forecasts() -> void:
	if forecast_current:
		forecast_current = false
		forecast_label.text = "OUT OF DATE — rerun forecast.\n" + forecast_label.text
	_invalidate_comparison()

func _process(delta: float) -> void:
	if running:
		elapsed += delta * speed
		var processed := 0
		var started := Time.get_ticks_usec()
		while elapsed >= 1.0 and processed < MAX_DAYS_PER_FRAME:
			if processed > 0 and Time.get_ticks_usec() - started >= simulation_budget_usec:
				break
			elapsed -= 1.0
			world.advance_day()
			processed += 1
		if processed > 0:
			_refresh()

func _toggle_pause() -> void:
	running = not running
	pause_button.text = "Pause" if running else "Resume"
	_update_speed_status()

func _advance_day() -> void:
	world.advance_day()
	_refresh()

func _confirm_new_scenario() -> void:
	if scenario_picker.selected < 0:
		status.text = "Select a built-in scenario first."
		return
	_start_scenario(SCENARIOS[scenario_picker.selected].path)

func _start_scenario(path: String) -> bool:
	var error: String = world.apply_scenario(World.Scenario.read_file(path))
	if not error.is_empty():
		status.text = "Could not start scenario: " + error
		return false
	running = false
	elapsed = 0.0
	pause_button.text = "Resume"
	tax.value = world.country.income_tax_rate * 100.0
	_additional_tax_selected(additional_tax_picker.selected)
	spending.value = world.country.annual_spending / 1000000.0
	_category_selected(category_picker.selected)
	event_filter.select(0)
	_sync_scenario_picker()
	_sync_healthcare_picker()
	_sync_directive_picker()
	status.text = "Scenario started and paused."
	_refresh()
	return true

func _sync_scenario_picker() -> void:
	for i in range(SCENARIOS.size()):
		if SCENARIOS[i].id == world.scenario_id:
			scenario_picker.select(i)
			return
	# An externally authored saved scenario may not be in the built-in catalog.
	scenario_picker.select(-1)

func _sync_healthcare_picker() -> void:
	healthcare_picker.clear()
	if congress_funding != null:
		congress_funding.clear()
	for amount in world.healthcare.rules.funding_options:
		healthcare_picker.add_item("Healthcare funding: $%.0f million / year" % (amount / 1000000.0))
		if congress_funding != null:
			congress_funding.add_item("Healthcare authorization: $%.0fM / year" % (amount / 1000000.0))
	healthcare_picker.select(1)
	if congress_funding != null:
		congress_funding.select(1)

func _sync_directive_picker() -> void:
	directive_picker.clear()
	for kind in ["reporting", "override"]:
		directive_picker.add_item(world.institutions.rules.cases[kind].name)
	directive_picker.select(0)

func _apply_tax() -> void:
	status.text = Decisions.execute(world, {"id": "set_income_tax", "args": {"rate": tax.value / 100.0}}).message
	_refresh()

func _start_talks() -> void:
	var keys: Array = world.diplomacy.PARTNERS.keys()
	var partner: String = keys[diplomacy_picker.selected]
	var choice: String = world.diplomacy.PROPOSALS.keys()[proposal_picker.selected]
	status.text = Decisions.execute(world, {"id": "start_talks", "args": {"partner": partner, "proposal": choice}}).message
	_refresh()

func _cancel_talks() -> void:
	status.text = Decisions.execute(world, {"id": "cancel_talks", "args": {}}).message
	_refresh()

func _end_cooperation() -> void:
	var partner: String = world.diplomacy.PARTNERS.keys()[diplomacy_picker.selected]
	status.text = Decisions.execute(world, {"id": "end_cooperation", "args": {"partner": partner}}).message
	_refresh()

func _additional_tax_kind() -> String:
	return "consumption" if additional_tax_picker.selected == 0 else "corporate"

func _additional_tax_selected(_index: int) -> void:
	var kind := _additional_tax_kind()
	additional_tax.value = world.country[world.ADDITIONAL_TAXES[kind].field] * 100.0
	_update_additional_tax_preview(additional_tax.value)

func _apply_additional_tax() -> void:
	var kind := _additional_tax_kind()
	status.text = Decisions.execute(world, {"id": "set_additional_tax", "args": {"kind": kind, "rate": additional_tax.value / 100.0}}).message
	_refresh()

func _apply_spending() -> void:
	status.text = Decisions.execute(world, {"id": "set_total_spending", "args": {"amount": spending.value * 1000000.0}}).message
	_category_selected(category_picker.selected)
	_refresh()

func _category_selected(index: int) -> void:
	var name := category_picker.get_item_text(index)
	category_amount.value = world.country.spending_categories[name] / 1000000.0
	_update_category_preview(category_amount.value)

func _apply_category() -> void:
	var name := category_picker.get_item_text(category_picker.selected)
	var decision: Dictionary = Decisions.execute(world, {"id": "set_category_spending", "args": {"category": name, "amount": category_amount.value * 1000000.0}})
	if decision.ok:
		spending.value = world.country.annual_spending / 1000000.0
		status.text = "%s budget updated." % name
	else:
		status.text = "Category change exceeds the total budget limit."
	_refresh()

func _refresh_law_catalog() -> void:
	if law_catalog == null:
		return
	law_catalog.clear()
	var root_item := law_catalog.create_item()
	var category := law_categories.get_tab_title(law_categories.current_tab)
	var query := law_search.text.strip_edges().to_lower()
	var id := ""
	var name := ""
	var state := ""
	var cost := 0.0
	if category == "Healthcare":
		id = "healthcare"
		name = "Healthcare expansion"
		state = "Active" if world.healthcare.active else "Not enacted"
		cost = world.healthcare.annual_cost()
	elif category == "Finance":
		id = "procurement"
		name = "Procurement policy"
		state = "Active" if world.politics.procurement_policy else "Not enacted"
		cost = float(world.policy_rules.procurement_annual_cost) if world.politics.procurement_policy and world.politics.procurement_progress >= 100 else 0.0
	if id.is_empty() or (not query.is_empty() and query not in name.to_lower()):
		law_catalog_note.text = "No implemented laws match this category and search."
		healthcare_panel.visible = false
		procurement_panel.visible = false
		return
	var row := law_catalog.create_item(root_item)
	row.set_text(0, name)
	row.set_text(1, state)
	row.set_text(2, "$%.1fM / year" % (cost / 1000000.0))
	row.set_metadata(0, id)
	row.select(0)
	law_catalog_note.text = "Select a law to inspect its details. Values and political rules are fictional."
	_show_law_detail(id)

func _law_catalog_selected() -> void:
	var selected := law_catalog.get_selected()
	if selected != null:
		_show_law_detail(str(selected.get_metadata(0)))

func _show_law_detail(id: String) -> void:
	healthcare_panel.visible = id == "healthcare"
	procurement_panel.visible = id == "procurement"
	if id == "procurement":
		procurement_detail.text = "PROCUREMENT POLICY — fictional test rules\nCurrent: %s | rollout: %d%% | votes for adoption: %d/100 | votes for repeal: %d/100\nOnce fully implemented, the policy costs $%.1fM per year. A majority is required." % ["active" if world.politics.procurement_policy else "not enacted", world.politics.procurement_progress, world.politics.votes_for_policy(), world.politics.votes_for_repeal(), float(world.policy_rules.procurement_annual_cost) / 1000000.0]

func _review_text(id: String, args: Dictionary) -> String:
	match id:
		"introduce_congress_bill":
			return "Introduce a healthcare bill with $%.0fM annual authorization into the fictional House? No policy takes effect at introduction." % (float(args.funding) / 1000000.0)
		"congress_vote":
			var stage: String = world.congress.stage
			if stage not in ["house", "senate", "override_house", "override_senate"]:
				return ""
			var house := stage in ["house", "override_house"]
			var override := stage in ["override_house", "override_senate"]
			return "%s %s vote: %d of %d fictional members support the bill. All members are assumed to vote. %s required. A successful final override enacts the bill." % ["House" if house else "Senate", "override" if override else "passage", world.congress.votes("house" if house else "senate", world.healthcare.rules.funding_options), 435 if house else 100, "Two-thirds" if override else "A majority"]
		"congress_president":
			if world.congress.stage != "president":
				return ""
			return "Presidential action: %s. %s" % [args.action, "Signing enacts the healthcare authorization." if args.action == "sign" else "A veto returns the bill to the House; both chambers must override to enact it."]
		"vote_healthcare":
			var amount: float = args.funding
			var preview: Dictionary = world.preview_healthcare(amount)
			if preview.is_empty():
				return ""
			var party_lines := PackedStringArray()
			for party in preview.positions:
				party_lines.append("%s: %d seats — %s" % [party.name, party.seats, "supports" if party.support else "opposes"])
			return "HEALTHCARE PROPOSAL — fictional rules\n\nAuthorization: $%.1fM / year\nExpected spending at current funding: $%.1fM / year\nProjected annual balance: $%.1fM\nSupport: %d / 100 seats; %s\n%s\n\nImplementation depends on administration and appropriation. Costs begin the next day; deficits are automatically borrowed. The current model does not forecast population approval for this vote." % [amount / 1000000.0, preview.annual_cost / 1000000.0, preview.annual_balance / 1000000.0, preview.votes, "majority" if preview.passes else "no majority", "\n".join(party_lines)]
		"repeal_healthcare":
			if not world.healthcare.active:
				return ""
			var preview: Dictionary = world.preview_healthcare(world.healthcare.funding, true)
			return "HEALTHCARE REPEAL — fictional rules\n\nSupport: %d / 100 seats; %s\nIf passed, annual cost stops and the health target bonus ends. Health conditions and approval respond gradually. Projected annual balance: $%.1fM." % [preview.votes, "majority" if preview.passes else "no majority", preview.annual_balance / 1000000.0]
		"set_healthcare_appropriation":
			var preview: Dictionary = world.preview_healthcare_appropriation(float(args.fraction))
			if preview.is_empty():
				return ""
			return "HEALTHCARE APPROPRIATION — fictional rules\n\nProposed funding: %.0f%%\nAnnual cost: $%.1fM\nProjected annual balance: $%.1fM\nSupport: %d / 100 seats; %s\nRollout at current administration: %.2f points / day\n\nA failed vote leaves the current appropriation unchanged." % [float(args.fraction) * 100.0, preview.annual_cost / 1000000.0, preview.annual_balance / 1000000.0, preview.votes, "majority" if preview.passes else "no majority", preview.daily_progress]
		"vote_procurement", "repeal_procurement":
			var votes: int = world.politics.votes_for_policy() if id == "vote_procurement" else world.politics.votes_for_repeal()
			return "PROCUREMENT %s — fictional rules\n\nSupport: %d / 100 seats; %s\nCurrent: %s | implementation %d%%\nOnce implemented, annual cost is $%.1fM. A successful repeal stops that cost." % ["PROPOSAL" if id == "vote_procurement" else "REPEAL", votes, "majority" if votes > 50 else "no majority", "active" if world.politics.procurement_policy else "not enacted", world.politics.procurement_progress, float(world.policy_rules.procurement_annual_cost) / 1000000.0]
		"issue_directive":
			var kind: String = args.kind
			if not world.institutions.rules.cases.has(kind):
				return ""
			var choice: Dictionary = world.institutions.rules.cases[kind]
			return "EXECUTIVE DIRECTIVE — fictional rules\n\n%s\n%s\n\nAuthority in this scenario: %s\nCurrent directive status: %s\nCourt review is automatic after %d days in this prototype. Implementation takes %d days if upheld. Reporting costs $%.1fM / year after implementation; override has no modeled effect." % [choice.name, choice.description, "within authority" if choice.within_authority else "exceeds authority", world.institutions.status, world.institutions.rules.review_day, world.institutions.rules.implementation_days, float(world.policy_rules.reporting_annual_cost) / 1000000.0]
		"revoke_directive":
			return "REVOKE DIRECTIVE — fictional rules\n\nCurrent: %s | status: %s | implementation: %d / %d\nIf revocation succeeds, implementation and any reporting effect stop." % [world.institutions.kind if not world.institutions.kind.is_empty() else "none", world.institutions.status, world.institutions.progress, world.institutions.rules.implementation_days]
	return ""

func _request_review(id: String, args: Dictionary) -> bool:
	var text := _review_text(id, args)
	if text.is_empty():
		status.text = "This decision is not available in the current state."
		return false
	if running:
		_toggle_pause()
		status.text = "Simulation paused for decision review."
	pending_decision = {"id": id, "args": args.duplicate(true)}
	review_snapshot = JSON.stringify(world.export_snapshot())
	review_dialog.dialog_text = text + "\n\nSubmit this decision?"
	review_dialog.popup_centered()
	return true

func _cancel_review() -> void:
	pending_decision.clear()
	review_snapshot = ""

func _request_congress_action(action: String) -> void:
	if action == "introduce_congress_bill":
		_request_review(action, {"funding": world.healthcare.rules.funding_options[congress_funding.selected]})
	elif action == "congress_vote":
		_request_review(action, {})
	else:
		_request_review("congress_president", {"action": action})

func _confirm_review() -> void:
	if pending_decision.is_empty():
		return
	if JSON.stringify(world.export_snapshot()) != review_snapshot:
		_cancel_review()
		status.text = "State changed since the preview. Review the decision again."
		_refresh()
		return
	var request := pending_decision.duplicate(true)
	_cancel_review()
	status.text = Decisions.execute(world, request).message
	_refresh()

func _vote_policy() -> void:
	status.text = Decisions.execute(world, {"id": "vote_procurement", "args": {}}).message
	_refresh()

func _vote_healthcare() -> void:
	var amount: float = world.healthcare.rules.funding_options[healthcare_picker.selected]
	status.text = Decisions.execute(world, {"id": "vote_healthcare", "args": {"funding": amount}}).message
	_refresh()

func _repeal_healthcare() -> void:
	status.text = Decisions.execute(world, {"id": "repeal_healthcare", "args": {}}).message
	_refresh()

func _apply_healthcare_appropriation() -> void:
	var fraction: float = appropriation_picker.selected * 0.25
	status.text = Decisions.execute(world, {"id": "set_healthcare_appropriation", "args": {"fraction": fraction}}).message
	_refresh()

func _refresh_healthcare() -> void:
	var amount: float = world.healthcare.rules.funding_options[healthcare_picker.selected]
	var preview: Dictionary = world.preview_healthcare(amount)
	var law = world.healthcare
	var lines := PackedStringArray(["HEALTHCARE LAW — fictional test model", "Current: %s | rollout %.1f%% | authorized $%.0f million/year | funded %.0f%% ($%.0f million/year)" % ["active" if law.active else "inactive", law.progress, law.funding / 1000000.0, law.appropriation * 100.0 if law.active else 0.0, law.annual_cost() / 1000000.0], "Administration %.1f/100 | health condition %.1f/100 | current health target %.1f/100" % [world.services.levels.Administration, world.services.levels.Health, world.service_target("Health", world.country.spending_categories.Health)], "PROPOSAL: %d/100 seats support; %s (51 required)." % [preview.votes, "passes" if preview.passes else "fails"]])
	for party in preview.positions:
		lines.append("%s: %d seats — %s" % [party.name, party.seats, "supports" if party.support else "opposes"])
	lines.append("If enacted: authorized $%.0f million/year, actual cost $%.0f million/year at current appropriation, annual balance $%.0f million at current rates; full-funding maximum +%.1f health target points, subject to the 100-point cap." % [amount / 1000000.0, preview.annual_cost / 1000000.0, preview.annual_balance / 1000000.0, preview.full_health_target_bonus])
	if law.active:
		var repeal: Dictionary = world.preview_healthcare(law.funding, true)
		lines.append("Repeal support: %d/100 seats — %s." % [repeal.votes, "passes" if repeal.passes else "fails"])
		var funding_preview: Dictionary = world.preview_healthcare_appropriation(appropriation_picker.selected * 0.25)
		var outcome: String = ("passes" if funding_preview.passes else "fails") if funding_preview.changed else "unchanged — no vote"
		lines.append("APPROPRIATION VOTE: %d/100 seats support; %s (51 required)." % [funding_preview.votes, outcome])
		for party in funding_preview.positions:
			lines.append("%s: %d seats — %s" % [party.name, party.seats, "supports" if party.support else "opposes"])
		lines.append("If passed: $%.0f million/year; annual balance $%.0f million. At current administration: %.2f rollout points/day; current-progress health target bonus %+.1f points." % [funding_preview.annual_cost / 1000000.0, funding_preview.annual_balance / 1000000.0, funding_preview.daily_progress, funding_preview.health_bonus])
	lines.append("New laws start fully funded by their passage. Later appropriation changes need a majority vote; funding continues unchanged after rejection. Costs change from the next day; deficits are automatically borrowed. Rollout takes %.0f days at full funding and administration 50/100; partial funding slows rollout and reduces the health target bonus. Zero funding pauses rollout. Service conditions and group approval respond gradually. These rules and party positions are fictional placeholders." % law.rules.days_at_normal_capacity)
	for group in world.politics.groups:
		lines.append("%s: %.1f%% approval (service contribution %+.1f points)" % [group.name, group.approval, group.service_bonus])
	healthcare_summary.text = "\n".join(lines)

func _repeal_policy() -> void:
	status.text = Decisions.execute(world, {"id": "repeal_procurement", "args": {}}).message
	_refresh()

func _issue_directive() -> void:
	var kind := "reporting" if directive_picker.selected == 0 else "override"
	status.text = Decisions.execute(world, {"id": "issue_directive", "args": {"kind": kind}}).message
	_refresh()

func _revoke_directive() -> void:
	status.text = Decisions.execute(world, {"id": "revoke_directive", "args": {}}).message
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
		_sync_scenario_picker()
		_sync_healthcare_picker()
		_sync_directive_picker()
		status.text = "Game loaded and paused."
		_refresh()
	else:
		status.text = error

func _refresh() -> void:
	_invalidate_forecasts()
	_update_speed_status()
	var c: Dictionary = world.country
	var d: Dictionary = world.date
	government_status.text = "%s   |   %04d-%02d-%02d   |   Cash $%.1fM   |   Annual balance $%.1fM   |   Approval %.1f%%" % [c.name, d.year, d.month, d.day, c.treasury / 1000000.0, world.annual_balance() / 1000000.0, c.approval]
	summary.text = "%s\nDate: %04d-%02d-%02d\nPopulation: %d\nCash: $%.0f  |  Debt: $%.0f\nAnnual revenue: $%.0f   |   Category spending: $%.0f\nAnnual policy cost: $%.0f  |  Debt interest: $%.0f\nAnnual balance: $%.0f   |   Daily net flow: $%.2f\nIncome tax: %.1f%%   |   Approval: %.1f%%" % [c.name, d.year, d.month, d.day, c.population, c.treasury, c.debt, world.total_annual_revenue(), c.annual_spending, world.policy_annual_cost(), world.debt_interest(), world.annual_balance(), world.daily_balance(), c.income_tax_rate * 100.0, c.approval]
	var budget_lines := PackedStringArray(["ANNUAL CATEGORY SPENDING"])
	var consumption_revenue: float = world.additional_tax_revenue("consumption")
	var corporate_revenue: float = world.additional_tax_revenue("corporate")
	budget_lines.append("Tax revenue (fixed test bases): income $%.0f | consumption $%.0f | corporate $%.0f | other revenue $%.0f" % [world.income_tax_revenue(), consumption_revenue, corporate_revenue, c.annual_revenue - world.income_tax_revenue() - consumption_revenue - corporate_revenue])
	budget_lines.append("Fictional partner contributions: $%.0f/year | cooperation costs: $%.0f/year" % [world.diplomacy.annual_partner_contribution(), world.diplomacy.annual_agreement_cost()])
	for category in World.CATEGORY_SHARES:
		budget_lines.append("%s: $%.0f | service %.1f/100 | target %.1f" % [category, c.spending_categories[category], world.services.levels[category], world.service_target(category, c.spending_categories[category])])
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
	lines.append("Test policy requires a majority, takes %d days and then costs $%.0f per year. Next illustrative election: January 1, %d. Seat allocation is a simplified placeholder." % [ceili(100.0 / float(world.policy_rules.procurement_progress_per_day)), world.policy_rules.procurement_annual_cost, world.next_election_year()])
	politics_summary.text = "\n".join(lines)
	var bill = world.congress
	congress_summary.text = "HOUSE: 435 seats (Civic 230, Liberty 205) | SENATE: 100 seats (Civic 52, Liberty 48) | PRESIDENT: player (Civic)\nFictional vote support: House %d/435, Senate %d/100. All members vote; support can cross party lines.\nBill stage: %s | Authorization: $%.0fM/year\nIntroduction → House → Senate → presidential signature or veto → House and Senate override. A successful signature or override changes the existing healthcare policy.\nThis is an illustrative separate path: fixed seats and votes, no committees, Senate cloture, absences, amendments or presidential deadlines. The old single-chamber controls below and in Laws remain fictional alternatives." % [bill.votes("house", world.healthcare.rules.funding_options), bill.votes("senate", world.healthcare.rules.funding_options), bill.stage.replace("_", " ").capitalize(), bill.funding / 1000000.0]
	var people := PackedStringArray(["POPULATION APPROVAL — fictional test groups", "National approval is the population-share weighted average of group approval. Raw approval includes the initial value and prior tax responses; it is not a breakdown of individual causes. Services add a separate contribution. Displayed approval is clamped to 0–100%."])
	for i in range(world.politics.groups.size()):
		var group: Dictionary = world.politics.groups[i]
		people.append("%s | %.0f%% of population (~%.0f people) | approval %.1f%%\n  Raw %.1f + services %+.1f points | sensitivity to +1 percentage point tax: income -%.2f, consumption -%.2f, corporate -%.2f points before limits." % [group.name, group.share * 100.0, c.population * group.share, group.approval, group.raw_approval, group.service_bonus, group.tax_sensitivity / 100.0, world.politics.ADDITIONAL_TAX_SENSITIVITIES.consumption[i] / 100.0, world.politics.ADDITIONAL_TAX_SENSITIVITIES.corporate[i] / 100.0])
	people.append("Service contribution responds gradually to the average condition of the five services. The three groups and all sensitivities are placeholders, not real demographic data or a model of individual personalities.")
	population_summary.text = "\n\n".join(people)
	var diplomatic_lines := PackedStringArray(["DIPLOMACY — fictional test rules", "Talks take 30 days; completion or cancellation starts a 90-day cooldown. Dialogue adds 5 relations. Accepted cooperation adds 10 and creates or renews a 365-day agreement with a $20 million annual partner contribution and $10 million annual cost; ending it early costs 5 relations. These are fictional assumptions, not trade estimates. Only one negotiation can run at a time. No trade or conflict effects are modeled."])
	for partner in world.diplomacy.PARTNERS:
		diplomatic_lines.append("%s: relations %.1f / 100 | cooldown %d days | cooperation %d days remaining" % [world.diplomacy.PARTNERS[partner], world.diplomacy.relations[partner], world.diplomacy.cooldowns[partner], world.diplomacy.agreements[partner]])
	if not world.diplomacy.active.is_empty():
		diplomatic_lines.append("Active: %s — %s | day %d / 30" % [world.diplomacy.PARTNERS[world.diplomacy.active], world.diplomacy.PROPOSALS[world.diplomacy.proposal].name, world.diplomacy.progress])
	else:
		diplomatic_lines.append("No active talks.")
	var chosen_partner: String = world.diplomacy.PARTNERS.keys()[diplomacy_picker.selected]
	var chosen_proposal: String = world.diplomacy.PROPOSALS.keys()[proposal_picker.selected]
	diplomatic_lines.append("Selected: %s — %s | current test response: %s | cooperation threshold %.0f." % [world.diplomacy.PARTNERS[chosen_partner], world.diplomacy.PROPOSALS[chosen_proposal].name, "accept" if world.diplomacy.will_accept(chosen_partner, chosen_proposal) else "decline", world.diplomacy.COOPERATION_MINIMUM[chosen_partner]])
	diplomacy_summary.text = "\n".join(diplomatic_lines)
	_refresh_directive()
	_refresh_healthcare()
	_refresh_law_catalog()
	_refresh_history()
	_update_tax_preview(tax.value)
	_update_additional_tax_preview(additional_tax.value)
	_update_spending_preview(spending.value)
	_update_category_preview(category_amount.value)

func _update_speed_status() -> void:
	if elapsed >= 1.0:
		speed_status.text = "%s — %d simulation days queued. The game processes the backlog over multiple frames." % ["Running" if running else "Paused", int(elapsed)]
	else:
		speed_status.text = "Simulation %s." % ("running" if running else "paused")

func _refresh_history() -> void:
	var category: String = "" if event_filter.selected == 0 else World.EVENT_CATEGORIES[event_filter.selected - 1]
	var records: Array = world.filtered_events(category)
	var lines := PackedStringArray()
	for record in records.slice(0, 30):
		lines.append(record.text)
	history.text = "\n".join(lines) if not lines.is_empty() else "No events in this category."

func _refresh_directive() -> void:
	var model = world.institutions
	var selected := "reporting" if directive_picker.selected == 0 else "override"
	var choice: Dictionary = model.rules.cases[selected]
	var active_name: String = model.rules.cases[model.kind].name if model.rules.cases.has(model.kind) else "None"
	directive_summary.text = "EXECUTIVE DIRECTIVES — fictional test rules\nSelected: %s. %s\nScenario authority: %s. Review after %d days; directives exceeding authority are suspended after %d.\nCurrent: %s | status: %s | elapsed: %d days | agency progress: %d/%d\nImplemented reporting adds %.1f to the administration target and costs $%.0f/year until revoked. Override has no modeled effect. Values are fictional." % [choice.name, choice.description, "within authority" if choice.within_authority else "exceeds authority", model.rules.review_day, model.rules.injunction_day, active_name, model.status, model.days, model.progress, model.rules.implementation_days, world.policy_rules.reporting_admin_target_bonus, world.policy_rules.reporting_annual_cost]

func _update_tax_preview(value: float) -> void:
	_invalidate_comparison()
	var preview: Dictionary = world.preview_income_tax(value / 100.0)
	if preview.is_empty():
		tax_preview.text = "Tax preview unavailable."
		return
	var lines := PackedStringArray(["TAX PREVIEW (fictional immediate model)", "Projected annual revenue: $%.0f | National approval: %.1f%%" % [preview.annual_revenue, preview.approval]])
	for group in preview.groups:
		lines.append("%s: %.1f%% approval" % [group.name, group.approval])
	tax_preview.text = "\n".join(lines)

func _update_additional_tax_preview(value: float) -> void:
	_invalidate_comparison()
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
	_invalidate_comparison()
	var preview: Dictionary = world.preview_annual_spending(value * 1000000.0)
	if preview.is_empty():
		spending_preview.text = "Spending preview unavailable."
		return
	spending_preview.text = "TOTAL BUDGET PREVIEW (resets category shares)\nAnnual balance: $%.0f | Daily net flow: $%.2f\nService and approval changes develop over time; employment and wider economic effects are not modeled." % [preview.annual_balance, preview.daily_balance]

func _update_category_preview(value: float) -> void:
	var name := category_picker.get_item_text(category_picker.selected)
	var preview: Dictionary = world.preview_category_spending(name, value * 1000000.0)
	if budget_chart != null:
		_refresh_budget_breakdown()
	if preview.is_empty():
		category_preview.text = "Category preview unavailable: total exceeds budget limit."
		return
	var service_target: float = world.service_target(name, value * 1000000.0)
	category_preview.text = "%s budget preview: annual balance $%.0f | daily net flow $%.2f | long-run service target %.1f/100 (fictional)" % [name, preview.annual_balance, preview.daily_balance, service_target]

func _refresh_budget_breakdown() -> void:
	var category := category_picker.get_item_text(category_picker.selected)
	var result: Dictionary = BudgetBreakdown.calculate(world, category, category_amount.value * 1000000.0)
	var proposed_view := budget_mode.selected == 1
	var shown: Dictionary = result.proposed if proposed_view else result.current
	var shown_total: float = result.proposed_total if proposed_view else result.current_total
	if proposed_view and not result.valid:
		budget_chart.set_data({}, 0.0, "Unavailable")
	else:
		budget_chart.set_data(shown, shown_total, "Proposed" if proposed_view else "Current")
	for name in result.current:
		var cells: Array = budget_rows[name]
		cells[0].text = "$%.1fM" % (float(result.current[name]) / 1000000.0)
		cells[1].text = "$%.1fM" % (float(result.proposed[name]) / 1000000.0) if result.valid else "—"
		cells[2].text = "%.1f%%" % (100.0 * float(shown[name]) / shown_total) if shown_total > 0.0 and (result.valid or not proposed_view) else "—"
	budget_chart_note.text = "Share uses %s annual expenses. Proposed changes apply only to the selected category and are not enacted. Policy costs and debt interest are separate from the five category budgets. Figures are fictional." % ("proposed" if proposed_view else "current") if result.valid else "Proposed category amount is unavailable because the total exceeds the budget limit. Current spending remains unchanged."
