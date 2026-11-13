extends Control

const World = preload("res://simulation/world.gd")
const Decisions = preload("res://simulation/decisions.gd")
const Diagnostics = preload("res://simulation/diagnostics.gd")
const WorldMap = preload("res://ui/world_map.gd")
const MapScenarioRegistry = preload("res://ui/map_scenario_registry.gd")
const WorldLab = preload("res://ui/world_lab.gd")
const GovernmentTheme = preload("res://ui/government_theme.gd")
const BudgetBreakdown = preload("res://ui/budget_breakdown.gd")
const BudgetChart = preload("res://ui/budget_chart.gd")
const LawCatalogData = preload("res://ui/law_catalog_data.gd")
const IndicatorChart = preload("res://ui/indicator_chart.gd")
const USReference = preload("res://ui/us_reference.gd")
const FederalBudget = preload("res://simulation/federal_budget.gd")
const SCENARIOS := [
	{"id": "test_republic", "name": "Federal Republic (fictional)", "path": "res://data/scenarios/test_republic.json"},
	{"id": "coastal_test", "name": "Coastal Republic (fictional)", "path": "res://data/scenarios/coastal_test.json"},
	{"id": "usa_sandbox", "name": "United States sandbox (mixed data)", "path": "res://data/scenarios/usa_sandbox.json"},
]
const MAX_DAYS_PER_FRAME := 30
const DEFAULT_SIMULATION_BUDGET_USEC := 8000
const BASE_CANVAS_SIZE := Vector2i(1152, 648)
const MIN_CANVAS_SCALE := 2.0
const UI_SCALES := [1.5, 2.0, 2.5]
const UI_PREFERENCES_PATH := "user://ui_preferences.cfg"
var ui_size_index := 1
var ui_size_picker: OptionButton
var world = World.new()
var running := false
var elapsed := 0.0
var summary: Label
var history: Label
var indicator_picker: OptionButton
var indicator_chart: Control
var indicator_summary: Label
var tax: SpinBox
var pause_button: Button
var main_save_button: Button
var main_load_button: Button
var main_backup_button: Button
var scenario_start_button: Button
var mode_notice: Label
var status: Label
var speed_status: Label
var simulation_budget_usec := DEFAULT_SIMULATION_BUDGET_USEC
var spending: SpinBox
var speed := 1
var explanation: Label
var politics_summary: Label
var congress_summary: Label
var congress_funding: OptionButton
var congress_buttons: Dictionary = {}
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
var forecast_horizon: OptionButton
var comparison_label: Label
var comparison_scope: OptionButton
var forecast_current := false
var comparison_current := false
var population_summary: Label
var diplomacy_picker: OptionButton
var diplomacy_summary: Label
var proposal_picker: OptionButton
var event_filter: OptionButton
var scenario_picker: OptionButton
var new_game_confirmation: ConfirmationDialog
var pending_scenario_index := -1
var diagnostic_steps: TextEdit
var world_map: Control
var map_selection: Label
var map_search: LineEdit
var map_search_scope: OptionButton
var map_results: ItemList
var map_search_status: Label
var map_hover: Label
var map_zoom_label: Label
var map_focus_button: Button
var map_clear_button: Button
var map_simulation: Label
var map_scenario_button: Button
var map_layer_picker: OptionButton
var map_legend: Label
var map_bindings: Array = []
var map_binding_error := ""
var world_lab: VBoxContainer
var lab_handoff_dialog: ConfirmationDialog
var pending_lab_handoff: Dictionary = {}
var main_to_lab_dialog: ConfirmationDialog
var pending_main_to_lab: Dictionary = {}
var shared_world_active := false
var shared_entry_dialog: ConfirmationDialog
var pending_shared_entry: Dictionary = {}
var shared_switch_dialog: ConfirmationDialog
var pending_shared_switch: Dictionary = {}
var shared_restore_dialog: ConfirmationDialog
var pending_shared_restore: Dictionary = {}
var shared_map_panel: VBoxContainer
var shared_partner_picker: OptionButton
var shared_proposal_picker: OptionButton
var shared_diplomacy_details: Label
var shared_talk_button: Button
var shared_cancel_button: Button
var shared_talk_dialog: ConfirmationDialog
var pending_shared_talk: Dictionary = {}
var shared_diplomacy_note: Label
var legacy_diplomacy_controls: Array = []
var shared_country_heading: Label
var shared_country_overview: VBoxContainer
var shared_country_rows: Dictionary = {}
var preserve_shared_picker := false
var inspector_buttons: Array[Button] = []
var inspector_selected := 0
var inspector_sections: Array = []
var inspector_reference: Label
var map_inspector_scroll: ScrollContainer
var map_layout: BoxContainer
var map_navigation: HBoxContainer
var map_controls: HBoxContainer
var map_view_button: Button
var map_inspector_button: Button
var map_back_button: Button
var map_tab_scroll: ScrollContainer
var map_inspector_view := false
var government_status: Label
var budget_chart: Control
var budget_mode: OptionButton
var budget_chart_note: Label
var budget_rows: Dictionary = {}
var law_categories: TabBar
var law_search: LineEdit
var law_search_all: CheckBox
var law_catalog: Tree
var law_catalog_note: Label
var law_catalog_data: Dictionary = {}
var law_catalog_error := ""
var law_edit_panel: VBoxContainer
var law_edit_kind := ""
var law_edit_amount: SpinBox
var law_edit_category: OptionButton
var law_edit_preview: Label
var law_edit_button: Button
var selected_law_id := ""
var healthcare_panel: VBoxContainer
var procurement_panel: VBoxContainer
var procurement_detail: Label
var review_dialog: ConfirmationDialog
var pending_decision: Dictionary = {}
var review_snapshot := ""
const SAVE_PATH := "user://prototype_save.json"

static func _canvas_size_for_window(pixels: Vector2i, minimum_scale: float = MIN_CANVAS_SCALE) -> Vector2i:
	if pixels.x <= 0 or pixels.y <= 0:
		return BASE_CANVAS_SIZE
	var safe_scale := clampf(minimum_scale, UI_SCALES[0], UI_SCALES[2])
	return Vector2i(mini(BASE_CANVAS_SIZE.x, maxi(1, floori(pixels.x / safe_scale))), mini(BASE_CANVAS_SIZE.y, maxi(1, floori(pixels.y / safe_scale))))

static func _read_ui_size(path: String) -> int:
	var settings := ConfigFile.new()
	if settings.load(path) != OK:
		return 1
	var value: Variant = settings.get_value("display", "small_window_size", 1)
	return value if value is int and value >= 0 and value < UI_SCALES.size() else 1

static func _write_ui_size(path: String, index: int) -> String:
	if index < 0 or index >= UI_SCALES.size():
		return "Invalid UI size."
	var settings := ConfigFile.new()
	if FileAccess.file_exists(path) and settings.load(path) != OK:
		return "Could not read existing UI preferences; the file was not overwritten."
	settings.set_value("display", "small_window_size", index)
	return "" if settings.save(path) == OK else "Could not save UI preferences."

func _set_ui_size(index: int) -> void:
	if index < 0 or index >= UI_SCALES.size():
		return
	ui_size_index = index
	_update_canvas_size()
	var error := _write_ui_size(UI_PREFERENCES_PATH, index)
	status.text = "Small-window UI size saved." if error.is_empty() else error + " Size changed for this run."

func _update_canvas_size() -> void:
	var window := get_window()
	var pixels := window.size
	if pixels.x <= 0 or pixels.y <= 0:
		return
	window.content_scale_size = _canvas_size_for_window(pixels, UI_SCALES[ui_size_index])
	_update_map_layout.call_deferred()

func _update_map_layout() -> void:
	if not is_instance_valid(map_layout) or not is_instance_valid(map_inspector_scroll) or not is_instance_valid(map_back_button):
		return
	_apply_map_layout(get_viewport_rect().size.x < 800.0)

func _apply_map_layout(compact: bool) -> void:
	map_layout.vertical = compact
	map_navigation.visible = compact
	map_controls.visible = not compact or not map_inspector_view
	map_back_button.visible = compact
	world_map.visible = not compact or not map_inspector_view
	map_inspector_scroll.visible = not compact or map_inspector_view
	map_view_button.set_pressed_no_signal(not map_inspector_view)
	map_inspector_button.set_pressed_no_signal(map_inspector_view)

func _set_map_view(inspector: bool) -> void:
	map_inspector_view = inspector
	_update_map_layout()
	if is_instance_valid(map_tab_scroll):
		map_tab_scroll.scroll_vertical = 0

func _ready() -> void:
	ui_size_index = _read_ui_size(UI_PREFERENCES_PATH)
	get_window().size_changed.connect(_update_canvas_size)
	_update_canvas_size()
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
	mode_notice = Label.new()
	mode_notice.text = "FICTIONAL TEST SCENARIO  ·  Early simulation prototype"
	mode_notice.add_theme_color_override("font_color", GovernmentTheme.MUTED)
	layout.add_child(mode_notice)
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
	tax_label.text = "Test income tax (%) "
	controls.add_child(tax_label)
	tax = SpinBox.new()
	tax.min_value = 0.0
	tax.max_value = 60.0
	tax.step = 1.0
	tax.value = 20.0
	controls.add_child(tax)
	var apply := Button.new()
	apply.text = "Review income tax"
	apply.pressed.connect(func(): _request_review("set_income_tax", {"rate": tax.value / 100.0}))
	controls.add_child(apply)
	main_save_button = Button.new()
	main_save_button.text = "Save"
	main_save_button.pressed.connect(_save_game)
	controls.add_child(main_save_button)
	main_load_button = Button.new()
	main_load_button.text = "Load"
	main_load_button.pressed.connect(_load_game)
	controls.add_child(main_load_button)
	main_backup_button = Button.new()
	main_backup_button.text = "Load backup"
	main_backup_button.pressed.connect(_load_backup)
	controls.add_child(main_backup_button)
	var restore_controls := HFlowContainer.new()
	layout.add_child(restore_controls)
	var shared_restore := Button.new()
	shared_restore.text = "Review restore shared world"
	shared_restore.pressed.connect(func(): _request_shared_restore(world_lab.LAB_SAVE))
	restore_controls.add_child(shared_restore)
	var shared_backup_restore := Button.new()
	shared_backup_restore.text = "Review shared backup"
	shared_backup_restore.pressed.connect(func(): _request_shared_restore(world_lab.LAB_SAVE + ".bak"))
	restore_controls.add_child(shared_backup_restore)
	var ui_size_label := Label.new()
	ui_size_label.text = "Small-window UI:"
	restore_controls.add_child(ui_size_label)
	ui_size_picker = OptionButton.new()
	for size_name in ["Compact", "Standard", "Large"]:
		ui_size_picker.add_item(size_name)
	ui_size_picker.select(ui_size_index)
	ui_size_picker.tooltip_text = "Changes the minimum interface size in smaller windows; larger windows retain the usual layout."
	ui_size_picker.item_selected.connect(_set_ui_size)
	restore_controls.add_child(ui_size_picker)
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
	apply_spending.text = "Review spending"
	apply_spending.pressed.connect(func(): _request_review("set_total_spending", {"amount": spending.value * 1000000.0}))
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
	category_button.text = "Review category ($ millions)"
	category_button.pressed.connect(func(): _request_review("set_category_spending", {"category": category_picker.get_item_text(category_picker.selected), "amount": category_amount.value * 1000000.0}))
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
	additional_tax_button.text = "Review selected tax (%)"
	additional_tax_button.pressed.connect(func(): _request_review("set_additional_tax", {"kind": _additional_tax_kind(), "rate": additional_tax.value / 100.0}))
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
	explanation.text = "Balance = revenue minus categories, policy costs and debt interest. Deficits increase public debt; surpluses repay debt up to zero. Surplus beyond zero debt is not allocated. Category funding gradually affects service conditions and approval in the fictional test model. Resetting the total restores initial shares."
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
	map_tab_scroll = map_tab.get_parent() as ScrollContainer
	var executive := _make_dashboard_tab("Executive Orders")
	var lab_tab := _make_dashboard_tab("World Lab")
	var us_reference_tab := _make_dashboard_tab("US Reference")
	_build_us_reference(us_reference_tab)
	world_lab = WorldLab.new()
	lab_tab.add_child(world_lab)
	map_navigation = HBoxContainer.new()
	map_tab.add_child(map_navigation)
	var map_view_group := ButtonGroup.new()
	map_view_button = Button.new()
	map_view_button.text = "Map"
	map_view_button.toggle_mode = true
	map_view_button.button_group = map_view_group
	map_view_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_view_button.pressed.connect(func(): _set_map_view(false))
	map_navigation.add_child(map_view_button)
	map_inspector_button = Button.new()
	map_inspector_button.text = "Country panel"
	map_inspector_button.toggle_mode = true
	map_inspector_button.button_group = map_view_group
	map_inspector_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_inspector_button.pressed.connect(func(): _set_map_view(true))
	map_navigation.add_child(map_inspector_button)
	map_controls = HBoxContainer.new()
	map_tab.add_child(map_controls)
	var map_help := Label.new()
	map_help.text = "Click select  •  Double-click focus  •  Drag pan  •  Wheel zoom"
	map_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	map_zoom_label = Label.new()
	map_zoom_label.text = "1.0×"
	map_controls.add_child(map_zoom_label)
	map_layout = BoxContainer.new()
	map_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_tab.add_child(map_layout)
	get_viewport().size_changed.connect(_update_map_layout)
	world_map = WorldMap.new()
	world_map.tooltip_text = "With the map focused: arrow keys pan, + and - zoom, and Home resets the view."
	world_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	world_map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_layout.add_child(world_map)
	var map_binding_data: Variant = MapScenarioRegistry.read()
	map_binding_error = MapScenarioRegistry.validate(map_binding_data, world_map.countries, SCENARIOS)
	if map_binding_error.is_empty():
		map_bindings = map_binding_data.bindings.duplicate(true)
	var map_sidebar_scroll := ScrollContainer.new()
	map_inspector_scroll = map_sidebar_scroll
	map_sidebar_scroll.custom_minimum_size = Vector2(290, 360)
	map_sidebar_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_sidebar_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	map_layout.add_child(map_sidebar_scroll)
	var map_sidebar := VBoxContainer.new()
	map_sidebar.custom_minimum_size = Vector2(270, 0)
	map_sidebar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_sidebar_scroll.add_child(map_sidebar)
	map_back_button = Button.new()
	map_back_button.text = "Back to map"
	map_back_button.pressed.connect(func(): _set_map_view(false))
	map_sidebar.add_child(map_back_button)
	var map_heading := Label.new()
	map_heading.text = "EXPLORE THE WORLD"
	map_sidebar.add_child(map_heading)
	map_layer_picker = OptionButton.new()
	map_layer_picker.add_item("Layer: geography")
	map_layer_picker.add_item("Layer: sandbox availability")
	map_layer_picker.item_selected.connect(func(_index: int): _refresh_map_layer())
	map_sidebar.add_child(map_layer_picker)
	map_legend = Label.new()
	map_legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_sidebar.add_child(map_legend)
	map_search = LineEdit.new()
	map_search.placeholder_text = "Search name or country code"
	map_search.tooltip_text = "Type a country, city, or country code. Press Enter to open the first result."
	map_sidebar.add_child(map_search)
	map_search_scope = OptionButton.new()
	for scope in ["Search: all places", "Search: countries", "Search: cities"]:
		map_search_scope.add_item(scope)
	map_search_scope.item_selected.connect(func(_index: int): _search_map(map_search.text))
	map_sidebar.add_child(map_search_scope)
	map_search_status = Label.new()
	map_search_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_sidebar.add_child(map_search_status)
	var city_filter := OptionButton.new()
	for name in ["Cities: automatic", "Cities: capitals", "Cities: all", "Cities: hidden"]:
		city_filter.add_item(name)
	map_sidebar.add_child(city_filter)
	city_filter.item_selected.connect(func(index: int): world_map.set_city_mode(index))
	map_hover = Label.new()
	map_hover.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_hover.text = "Hover over a country or city"
	map_sidebar.add_child(map_hover)
	var selection_controls := HBoxContainer.new()
	map_sidebar.add_child(selection_controls)
	map_focus_button = Button.new()
	map_focus_button.text = "Focus"
	map_focus_button.disabled = true
	selection_controls.add_child(map_focus_button)
	map_clear_button = Button.new()
	map_clear_button.text = "Clear"
	map_clear_button.disabled = true
	selection_controls.add_child(map_clear_button)
	map_focus_button.pressed.connect(func(): world_map.focus_selection())
	map_clear_button.pressed.connect(func(): world_map.clear_selection())
	map_scenario_button = Button.new()
	map_scenario_button.visible = false
	map_scenario_button.pressed.connect(_map_scenario_action)
	map_sidebar.add_child(map_scenario_button)
	map_simulation = Label.new()
	map_simulation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_sidebar.add_child(map_simulation)
	shared_map_panel = VBoxContainer.new()
	map_sidebar.add_child(shared_map_panel)
	var shared_heading := Label.new()
	shared_heading.text = "SHARED WORLD COUNTRY"
	shared_map_panel.add_child(shared_heading)
	shared_partner_picker = OptionButton.new()
	shared_partner_picker.fit_to_longest_item = false
	shared_partner_picker.clip_text = true
	shared_map_panel.add_child(shared_partner_picker)
	shared_partner_picker.item_selected.connect(_shared_country_picker_changed)
	var inspector_navigation := GridContainer.new()
	inspector_navigation.columns = 2
	shared_map_panel.add_child(inspector_navigation)
	var inspector_group := ButtonGroup.new()
	for section_title in ["Overview", "Government", "Economy", "Diplomacy"]:
		var section_button := Button.new()
		section_button.text = section_title
		section_button.toggle_mode = true
		section_button.button_group = inspector_group
		section_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var section_index := inspector_buttons.size()
		section_button.pressed.connect(func(): _set_inspector_section(section_index))
		inspector_navigation.add_child(section_button)
		inspector_buttons.append(section_button)
	inspector_reference = Label.new()
	inspector_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspector_reference.text = "REFERENCE ONLY — no simulated government, economic or diplomatic data is available. Select a simulated country above."
	shared_map_panel.add_child(inspector_reference)
	shared_country_overview = VBoxContainer.new()
	shared_map_panel.add_child(shared_country_overview)
	shared_country_heading = Label.new()
	shared_country_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	shared_country_heading.add_theme_color_override("font_color", GovernmentTheme.ACCENT)
	shared_country_overview.add_child(shared_country_heading)
	for section_name in ["OVERVIEW", "GOVERNMENT", "ECONOMY", "DIPLOMACY"]:
		var section := VBoxContainer.new()
		section.name = section_name
		shared_country_overview.add_child(section)
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 14)
		grid.add_theme_constant_override("v_separation", 5)
		section.add_child(grid)
		inspector_sections.append(section)
	for row_name in ["Date", "Government bloc", "Population", "Approval", "Income tax", "Annual revenue", "Base spending", "Annual balance", "Debt", "Diplomacy"]:
		var section_index := 0
		if row_name in ["Government bloc", "Approval"]:
			section_index = 1
		elif row_name in ["Income tax", "Annual revenue", "Base spending", "Annual balance", "Debt"]:
			section_index = 2
		elif row_name == "Diplomacy":
			section_index = 3
		var country_rows: GridContainer = inspector_sections[section_index].get_child(0)
		var caption := Label.new()
		caption.text = row_name
		caption.add_theme_color_override("font_color", GovernmentTheme.MUTED)
		country_rows.add_child(caption)
		var value := Label.new()
		value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		country_rows.add_child(value)
		shared_country_rows[row_name] = value
	var country_note := Label.new()
	country_note.text = "Fictional test data. Government bloc seats use a simplified 100-seat model."
	country_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	country_note.add_theme_color_override("font_color", GovernmentTheme.MUTED)
	inspector_sections[1].add_child(country_note)
	var economy_note := Label.new()
	economy_note.text = "Starting US finances may be sourced; tax and service effects are simulated. Annual balance includes policy costs and interest."
	economy_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	economy_note.add_theme_color_override("font_color", GovernmentTheme.MUTED)
	inspector_sections[2].add_child(economy_note)
	var shared_diplomacy_heading := Label.new()
	shared_diplomacy_heading.text = "DIPLOMACY"
	inspector_sections[3].add_child(shared_diplomacy_heading)
	shared_proposal_picker = OptionButton.new()
	shared_proposal_picker.add_item("Open dialogue")
	shared_proposal_picker.add_item("Cooperation agreement")
	shared_proposal_picker.item_selected.connect(func(_index: int): _refresh_shared_diplomacy())
	inspector_sections[3].add_child(shared_proposal_picker)
	shared_diplomacy_details = Label.new()
	shared_diplomacy_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspector_sections[3].add_child(shared_diplomacy_details)
	shared_talk_button = Button.new()
	shared_talk_button.text = "Review talks"
	shared_talk_button.pressed.connect(_request_shared_talk)
	inspector_sections[3].add_child(shared_talk_button)
	shared_cancel_button = Button.new()
	shared_cancel_button.text = "Cancel active talks"
	shared_cancel_button.pressed.connect(_cancel_shared_talk)
	inspector_sections[3].add_child(shared_cancel_button)
	map_results = ItemList.new()
	map_results.custom_minimum_size = Vector2(0, 150)
	map_results.visible = false
	map_sidebar.add_child(map_results)
	map_search.text_changed.connect(_search_map)
	map_search.text_submitted.connect(_submit_map_search)
	map_results.item_selected.connect(_select_map_result)
	map_selection = Label.new()
	map_selection.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_selection.text = "WORLD MAP\n\nSelect a country or city.\n\nUS starting population and federal finances use historical sources; politics and behavioral rules remain fictional."
	map_sidebar.add_child(map_selection)
	map_sidebar.move_child(map_results, map_search_status.get_index() + 1)
	map_sidebar.move_child(map_selection, shared_map_panel.get_index())
	world_map.country_selected.connect(_map_country_selected)
	world_map.city_selected.connect(_map_city_selected)
	world_map.selection_cleared.connect(_map_selection_cleared)
	world_map.hover_changed.connect(func(text: String): map_hover.text = text if not text.is_empty() else "Hover over a country or city")
	world_map.zoom_changed.connect(func(value: float): map_zoom_label.text = "%.1f×" % value)
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
	scenario_start_button = Button.new()
	scenario_start_button.text = "Start selected scenario"
	scenario_controls.add_child(scenario_start_button)
	new_game_confirmation = ConfirmationDialog.new()
	new_game_confirmation.title = "Start a new scenario?"
	new_game_confirmation.dialog_text = "This replaces your current session. Save first if you want to keep your progress."
	add_child(new_game_confirmation)
	scenario_start_button.pressed.connect(func(): _request_new_scenario(scenario_picker.selected))
	new_game_confirmation.confirmed.connect(_confirm_new_scenario)
	new_game_confirmation.canceled.connect(func(): pending_scenario_index = -1)
	lab_handoff_dialog = ConfirmationDialog.new()
	lab_handoff_dialog.title = "Copy lab country to main game?"
	lab_handoff_dialog.ok_button_text = "Copy to main game"
	lab_handoff_dialog.dialog_autowrap = true
	lab_handoff_dialog.min_size = Vector2i(600, 0)
	lab_handoff_dialog.confirmed.connect(_confirm_lab_handoff)
	lab_handoff_dialog.canceled.connect(_cancel_lab_handoff)
	add_child(lab_handoff_dialog)
	world_lab.copy_to_main_requested.connect(_request_lab_handoff)
	main_to_lab_dialog = ConfirmationDialog.new()
	main_to_lab_dialog.title = "Create a new lab world?"
	main_to_lab_dialog.ok_button_text = "Create lab world"
	main_to_lab_dialog.dialog_autowrap = true
	main_to_lab_dialog.min_size = Vector2i(600, 0)
	main_to_lab_dialog.confirmed.connect(_confirm_main_to_lab)
	main_to_lab_dialog.canceled.connect(_cancel_main_to_lab)
	add_child(main_to_lab_dialog)
	world_lab.copy_from_main_requested.connect(_request_main_to_lab)
	shared_entry_dialog = ConfirmationDialog.new()
	shared_entry_dialog.title = "Enter shared world?"
	shared_entry_dialog.ok_button_text = "Enter shared world"
	shared_entry_dialog.dialog_autowrap = true
	shared_entry_dialog.min_size = Vector2i(600, 0)
	shared_entry_dialog.confirmed.connect(_confirm_shared_entry)
	shared_entry_dialog.canceled.connect(func(): pending_shared_entry.clear())
	add_child(shared_entry_dialog)
	world_lab.shared_world_requested.connect(_request_shared_entry)
	world_lab.shared_switch_requested.connect(_request_shared_switch)
	world_lab.leave_shared_world_requested.connect(_leave_shared_world)
	world_lab.lab_state_changed.connect(func(country_id: String):
		if shared_world_active:
			if country_id == world.country.id:
				tax.value = world.country.income_tax_rate * 100.0
			_refresh()
	)
	shared_switch_dialog = ConfirmationDialog.new()
	shared_switch_dialog.title = "Switch controlled country?"
	shared_switch_dialog.ok_button_text = "Switch country"
	shared_switch_dialog.dialog_autowrap = true
	shared_switch_dialog.min_size = Vector2i(600, 0)
	shared_switch_dialog.confirmed.connect(_confirm_shared_switch)
	shared_switch_dialog.canceled.connect(func(): pending_shared_switch.clear())
	add_child(shared_switch_dialog)
	shared_restore_dialog = ConfirmationDialog.new()
	shared_restore_dialog.title = "Restore shared world?"
	shared_restore_dialog.dialog_autowrap = true
	shared_restore_dialog.min_size = Vector2i(600, 0)
	shared_restore_dialog.confirmed.connect(_confirm_shared_restore)
	shared_restore_dialog.canceled.connect(func(): pending_shared_restore.clear())
	add_child(shared_restore_dialog)
	shared_talk_dialog = ConfirmationDialog.new()
	shared_talk_dialog.title = "Open shared-world talks?"
	shared_talk_dialog.dialog_autowrap = true
	shared_talk_dialog.min_size = Vector2i(600, 0)
	shared_talk_dialog.confirmed.connect(_confirm_shared_talk)
	shared_talk_dialog.canceled.connect(func(): pending_shared_talk.clear())
	add_child(shared_talk_dialog)
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
	forecast_horizon = OptionButton.new()
	for days in [30, 90, 180, 365]:
		forecast_horizon.add_item("Forecast horizon: %d days" % days, days)
	forecast_horizon.select(3)
	forecast_horizon.item_selected.connect(func(_index: int): _invalidate_forecasts())
	finances.add_child(forecast_horizon)
	var forecast_button := Button.new()
	forecast_button.text = "Run fiscal forecast"
	forecast_button.pressed.connect(_forecast_budget)
	finances.add_child(forecast_button)
	forecast_label = Label.new()
	forecast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	forecast_label.text = "Forecast on demand; rerun after changing settings or advancing time."
	finances.add_child(forecast_label)
	comparison_scope = OptionButton.new()
	comparison_scope.add_item("Compare total budget (reset shares)")
	comparison_scope.add_item("Compare selected category only")
	comparison_scope.item_selected.connect(func(_index: int): _invalidate_comparison())
	finances.add_child(comparison_scope)
	var compare_button := Button.new()
	compare_button.text = "Compare entered tax and budget proposal"
	compare_button.pressed.connect(_compare_budget)
	finances.add_child(compare_button)
	comparison_label = Label.new()
	comparison_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	comparison_label.text = "Comparison uses entered taxes and the selected budget proposal; it does not apply them."
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
	congress_funding.item_selected.connect(func(_index: int): _refresh_congress())
	var bill_controls := HBoxContainer.new()
	government.add_child(bill_controls)
	for spec in [["Introduce bill", "introduce_congress_bill"], ["Vote in chamber", "congress_vote"], ["Sign", "sign"], ["Veto", "veto"]]:
		var button := Button.new()
		button.text = spec[0]
		var action: String = spec[1]
		button.pressed.connect(func(): _request_congress_action(action))
		bill_controls.add_child(button)
		congress_buttons[action] = button
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
	legacy_diplomacy_controls = [diplomacy_picker, proposal_picker, talk_button, cancel_talks_button, end_agreement_button, diplomacy_summary]
	shared_diplomacy_note = Label.new()
	shared_diplomacy_note.text = "SHARED WORLD: open World Map and select a country or use the shared-world country selector in the map panel. Talks and relationships use the live World Lab registry."
	shared_diplomacy_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	diplomacy_tab.add_child(shared_diplomacy_note)
	var open_shared_map := Button.new()
	open_shared_map.text = "Open country diplomacy on map"
	open_shared_map.pressed.connect(func(): dashboard_tabs.current_tab = 8)
	shared_diplomacy_note.add_child(open_shared_map)
	# Keep the button in the layout instead of overlaying the label.
	open_shared_map.reparent(diplomacy_tab)
	shared_diplomacy_note.set_meta("map_button", open_shared_map)
	for node in [heading, history]:
		node.reparent(decisions)
	event_filter = OptionButton.new()
	event_filter.add_item("All events")
	for category in World.EVENT_CATEGORIES:
		event_filter.add_item(category.capitalize())
	event_filter.item_selected.connect(func(_index: int): _refresh_history())
	decisions.add_child(event_filter)
	decisions.move_child(event_filter, 1)
	var indicator_panel := VBoxContainer.new()
	decisions.add_child(indicator_panel)
	decisions.move_child(indicator_panel, 0)
	var indicator_title := Label.new()
	indicator_title.text = "MONTHLY INDICATORS — fictional values"
	indicator_panel.add_child(indicator_title)
	indicator_picker = OptionButton.new()
	for spec in [["Approval (%)", "approval"], ["Annual deficit", "deficit"], ["Debt ($ millions)", "debt"], ["Annual revenue ($ millions)", "revenue"], ["Annual balance ($ millions)", "balance"], ["Population (people)", "population"]]:
		indicator_picker.add_item(spec[0])
		indicator_picker.set_item_metadata(indicator_picker.item_count - 1, spec[1])
	indicator_picker.item_selected.connect(func(_index: int): _refresh_indicators())
	indicator_panel.add_child(indicator_picker)
	indicator_chart = IndicatorChart.new()
	indicator_chart.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	indicator_panel.add_child(indicator_chart)
	indicator_summary = Label.new()
	indicator_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	indicator_panel.add_child(indicator_summary)
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
	law_heading.text = "LAW CATALOGUE — US-ORIENTED POLICY TOPICS"
	laws.add_child(law_heading)
	var law_explanation := Label.new()
	law_explanation.text = "Choose a category or search across categories. Planned topics are not playable laws; existing prototypes use fictional rules. Federal and state authority is not yet modeled."
	law_explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	laws.add_child(law_explanation)
	var law_data: Variant = LawCatalogData.read()
	law_catalog_error = LawCatalogData.validate(law_data)
	if law_catalog_error.is_empty():
		law_catalog_data = law_data.duplicate(true)
	law_categories = TabBar.new()
	for category in law_catalog_data.get("categories", ["Unavailable"]):
		law_categories.add_tab(category)
	laws.add_child(law_categories)
	law_search = LineEdit.new()
	law_search.placeholder_text = "Search policy topics"
	laws.add_child(law_search)
	law_search_all = CheckBox.new()
	law_search_all.text = "Search all categories"
	laws.add_child(law_search_all)
	law_catalog = Tree.new()
	law_catalog.columns = 3
	law_catalog.hide_root = true
	law_catalog.column_titles_visible = true
	law_catalog.set_column_title(0, "Law")
	law_catalog.set_column_title(1, "Status")
	law_catalog.set_column_title(2, "Annual cost")
	law_catalog.set_column_expand(0, true)
	law_catalog.custom_minimum_size = Vector2(0, 240)
	laws.add_child(law_catalog)
	law_catalog_note = Label.new()
	law_catalog_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	laws.add_child(law_catalog_note)
	law_edit_panel = VBoxContainer.new()
	law_edit_panel.name = "LawEditPanel"
	laws.add_child(law_edit_panel)
	law_edit_category = OptionButton.new()
	law_edit_category.name = "LawEditCategory"
	for category in World.CATEGORY_SHARES:
		law_edit_category.add_item(category)
	law_edit_panel.add_child(law_edit_category)
	law_edit_amount = SpinBox.new()
	law_edit_amount.name = "LawEditAmount"
	law_edit_amount.step = 0.1
	law_edit_panel.add_child(law_edit_amount)
	law_edit_preview = Label.new()
	law_edit_preview.name = "LawEditPreview"
	law_edit_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	law_edit_panel.add_child(law_edit_preview)
	law_edit_button = Button.new()
	law_edit_button.name = "LawEditReview"
	law_edit_button.text = "Review change"
	law_edit_panel.add_child(law_edit_button)
	law_edit_amount.value_changed.connect(func(_value: float): _refresh_law_edit_preview())
	law_edit_category.item_selected.connect(func(_index: int): _sync_law_edit_value())
	law_edit_button.pressed.connect(_review_law_edit)
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
	law_search_all.toggled.connect(func(_pressed: bool): _refresh_law_catalog())
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

func _build_us_reference(column: VBoxContainer) -> void:
	var notice := Label.new()
	notice.text = "OFFICIAL HISTORICAL REFERENCE — NOT LIVE SIMULATION VALUES"
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(notice)
	var data: Variant = USReference.read()
	var error: String = USReference.validate(data)
	if not error.is_empty():
		notice.text += "\n" + error
		return
	var description := Label.new()
	description.text = "Census resident population estimate, %s: %s people\n\nFederal budget: %s\nAmounts below are millions of US dollars. Spending includes net interest. Negative functions are offsets; figures may differ by rounding. Sources appear below the table." % [data.population.period, str(int(data.population.value)), data.budget.period]
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(description)
	var economy := Label.new()
	economy.text = "Current-dollar GDP: $%.1f billion (%s)\nUnemployment: %.1f%% (%s)" % [data.economy.gdp_billions, data.economy.gdp_period, data.economy.unemployment_percent, data.economy.unemployment_period]
	economy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(economy)
	var table := Tree.new()
	table.name = "USReferenceTable"
	table.columns = 2
	table.column_titles_visible = true
	table.set_column_title(0, "Federal receipts and outlays")
	table.set_column_title(1, "Millions USD")
	table.set_column_expand(0, true)
	table.set_column_expand(1, false)
	table.set_column_custom_minimum_width(1, 120)
	table.hide_root = true
	table.custom_minimum_size = Vector2(0, 360)
	column.add_child(table)
	var root_item := table.create_item()
	for row in [["Total receipts", data.budget.receipts_millions], ["Total outlays", data.budget.outlays_millions], ["Deficit", data.budget.deficit_millions]]:
		var item := table.create_item(root_item)
		item.set_text(0, row[0])
		item.set_text(1, str(int(row[1])))
	for row in data.budget.functions:
		var item := table.create_item(root_item)
		item.set_text(0, row.name)
		item.set_text(1, str(int(row.millions)))
	var preview_heading := Label.new()
	preview_heading.text = "HISTORICAL BUDGET WHAT-IF (REFERENCE ONLY)"
	column.add_child(preview_heading)
	var preview_note := Label.new()
	preview_note.text = "Change one nonnegative function in millions of dollars. This is arithmetic only: receipts, policy behavior and economic effects are held fixed. It does not change the game."
	preview_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(preview_note)
	var picker := OptionButton.new()
	picker.name = "USBudgetFunction"
	for row in data.budget.functions:
		if row.millions >= 0:
			picker.add_item(row.name)
			picker.set_item_metadata(picker.item_count - 1, row.millions)
	column.add_child(picker)
	var amount := SpinBox.new()
	amount.name = "USBudgetAmount"
	amount.min_value = 0
	amount.max_value = FederalBudget.MAX_MILLIONS
	amount.step = 1
	amount.value = picker.get_item_metadata(0)
	amount.suffix = "million USD"
	column.add_child(amount)
	var result := Label.new()
	result.name = "USBudgetPreview"
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(result)
	var update_preview := func():
		var preview: Dictionary = FederalBudget.preview(data, picker.get_item_text(picker.selected), amount.value)
		result.text = "Preview unavailable: " + preview.error if not preview.error.is_empty() else "Change: %+.0f million USD\nTotal outlays: %.0f million USD\nDeficit (negative means surplus): %.0f million USD" % [preview.delta_millions, preview.outlays_millions, preview.deficit_millions]
	picker.item_selected.connect(func(_index: int): amount.value = picker.get_item_metadata(picker.selected); update_preview.call())
	amount.value_changed.connect(func(_value: float): update_preview.call())
	update_preview.call()
	var sources := Label.new()
	sources.text = "Census: " + data.sources.census + "\n\nTreasury: " + data.sources.treasury + "\n\nBEA: " + data.sources.bea + "\n\nBLS: " + data.sources.bls + "\n\nRetrieved: " + data.retrieved + ". New US games use the Census population and FY2026 federal finances; GDP and unemployment remain reference only."
	sources.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(sources)

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
	_select_shared_map_country(id)
	var capital := "Not in dataset"
	var count := 0
	for city in world_map.cities:
		if city.country == id:
			count += 1
			if city.capital:
				capital = city.name
	map_focus_button.disabled = false
	map_clear_button.disabled = false
	map_selection.text = "%s\n\nCOUNTRY  •  %s\nCapital: %s\nMapped places: %d\n\nGeography and place names are reference data. Regional simulation is not implemented." % [country_name, id, capital, count]
	_refresh_map_simulation()
	if map_layout.vertical:
		_set_map_view(true)
	if shared_world_active:
		_open_country_inspector.call_deferred()

func _map_city_selected(city: Dictionary) -> void:
	_select_shared_map_country(city.get("country", ""))
	map_focus_button.disabled = false
	map_clear_button.disabled = false
	map_selection.text = "%s\n\n%s  •  %s\nLatitude: %.2f°\nLongitude: %.2f°\n\nReference city marker only. Detailed city art and simulation are not implemented yet." % [city.name, "National capital" if city.capital else "City", city.country, float(city.point[1]), float(city.point[0])]
	_refresh_map_simulation()
	if map_layout.vertical:
		_set_map_view(true)
	if shared_world_active:
		_open_country_inspector.call_deferred()

func _open_country_inspector() -> void:
	# Let the selected-country text wrap and the containers settle before scrolling.
	await get_tree().process_frame
	await get_tree().process_frame
	if shared_world_active and is_instance_valid(map_inspector_scroll):
		map_inspector_scroll.scroll_vertical = roundi(shared_map_panel.position.y)

func _map_selection_cleared() -> void:
	if not preserve_shared_picker:
		_select_shared_map_country("")
	map_focus_button.disabled = true
	map_clear_button.disabled = true
	map_selection.text = "WORLD MAP\n\nSelect a country or city.\n\nUS starting population and federal finances use historical sources; politics and behavioral rules remain fictional."
	_refresh_map_simulation()

func _map_scenario_index(id: String) -> int:
	var binding := _map_binding(id)
	if binding.is_empty():
		return -1
	for index in range(SCENARIOS.size()):
		if SCENARIOS[index].id == binding.scenario_id:
			return index
	return -1

func _map_binding(id: String) -> Dictionary:
	for binding in map_bindings:
		if binding.map_id == id:
			return binding
	return {}

func _map_binding_active(binding: Dictionary) -> bool:
	return not binding.is_empty() and world.scenario_id == binding.scenario_id and world.country.id == binding.country_id

func _shared_partner_id() -> String:
	if shared_partner_picker.item_count == 0 or shared_partner_picker.selected < 0:
		return ""
	return str(shared_partner_picker.get_item_metadata(shared_partner_picker.selected))

func _select_shared_map_country(map_id: String) -> void:
	if not shared_world_active or shared_partner_picker == null:
		return
	var binding := _map_binding(map_id)
	var target: String = binding.get("country_id", "")
	for index in range(shared_partner_picker.item_count):
		if str(shared_partner_picker.get_item_metadata(index)) == target:
			shared_partner_picker.select(index)
			break
	_set_inspector_section(0)
	_refresh_shared_diplomacy()

func _shared_country_picker_changed(_index: int) -> void:
	var binding := _map_binding(world_map.selected_id)
	if not world_map.selected_id.is_empty() and binding.get("country_id", "") != _shared_partner_id():
		preserve_shared_picker = true
		world_map.clear_selection()
		preserve_shared_picker = false
	_set_inspector_section(0)
	_refresh_shared_diplomacy()

func _set_inspector_section(index: int) -> void:
	inspector_selected = clampi(index, 0, 3)
	for i in range(inspector_buttons.size()):
		inspector_buttons[i].set_pressed_no_signal(i == inspector_selected)
	for i in range(inspector_sections.size()):
		inspector_sections[i].visible = i == inspector_selected
	if inspector_reference != null:
		inspector_reference.text = "REFERENCE ONLY — no simulated %s data is available. Select a simulated country above." % ["country", "government", "economic", "diplomatic"][inspector_selected]

func _refresh_shared_country_overview(target: String, ids: Array) -> void:
	shared_country_overview.visible = target in ids
	inspector_reference.visible = not shared_country_overview.visible
	_set_inspector_section(inspector_selected)
	if not shared_country_overview.visible:
		return
	var selected = world_lab.registry.controlled_country(target)
	var c: Dictionary = selected.country
	var date: Dictionary = selected.date
	shared_country_heading.text = ("YOUR GOVERNMENT" if target == world.country.id else "OTHER SIMULATED COUNTRY") + "\n" + c.name
	if target == WorldLab.COAST:
		shared_country_heading.text += "\nFictional country; no map location"
	var party: Dictionary = selected.politics.parties[0]
	var activity: Array[String] = []
	for other in ids:
		if other == target:
			continue
		var progress: int = world_lab.registry.dialogue_progress(target, other)
		var days: int = world_lab.registry.agreement_days(target, other)
		var other_name: String = world_lab.registry.country_snapshot(other).country.name
		if progress >= 0:
			activity.append("%s: %s day %d/%d" % [other_name, world_lab.registry.talk_kind(target, other), progress, WorldLab.Registry.TALK_DAYS])
		if days > 0:
			activity.append("%s: agreement %d days" % [other_name, days])
	var values := {
		"Date": "%04d-%02d-%02d" % [date.year, date.month, date.day],
		"Government bloc": "%s · %d / 100" % [party.name, party.seats],
		"Population": str(c.population),
		"Approval": "%.1f%%" % c.approval,
		"Income tax": "%.1f%%" % (c.income_tax_rate * 100.0),
		"Annual revenue": "$%.1fM" % (selected.total_annual_revenue() / 1000000.0),
		"Base spending": "$%.1fM" % (c.annual_spending / 1000000.0),
		"Annual balance": "$%.1fM" % (selected.annual_balance() / 1000000.0),
		"Debt": "$%.1fM" % (c.debt / 1000000.0),
		"Diplomacy": "None active" if activity.is_empty() else "\n".join(activity),
	}
	for key in values:
		shared_country_rows[key].text = values[key]

func _refresh_shared_diplomacy() -> void:
	if shared_map_panel == null or shared_diplomacy_note == null:
		return
	shared_map_panel.visible = shared_world_active
	shared_diplomacy_note.visible = shared_world_active
	shared_diplomacy_note.get_meta("map_button").visible = shared_world_active
	for control in legacy_diplomacy_controls:
		control.visible = not shared_world_active
	if not shared_world_active or not world_lab.initialized:
		return
	var ids: Array = world_lab.registry.country_ids()
	var current := _shared_partner_id()
	if shared_partner_picker.item_count != ids.size() + 1:
		shared_partner_picker.clear()
		shared_partner_picker.add_item("Select a simulated country")
		shared_partner_picker.set_item_metadata(0, "")
		for id in ids:
			var label: String = world_lab.registry.country_snapshot(id).country.name
			if id == WorldLab.COAST:
				label += " (fictional, unmapped)"
			shared_partner_picker.add_item(label)
			shared_partner_picker.set_item_metadata(shared_partner_picker.item_count - 1, id)
		shared_partner_picker.select(0)
		for index in range(shared_partner_picker.item_count):
			if str(shared_partner_picker.get_item_metadata(index)) == current:
				shared_partner_picker.select(index)
	var target := _shared_partner_id()
	_refresh_shared_country_overview(target, ids)
	var valid: bool = target in ids and target != world.country.id
	shared_talk_button.disabled = true
	shared_cancel_button.disabled = true
	if not valid:
		shared_diplomacy_details.text = "Select another simulated country. Coastal Republic is fictional and has no geographic map location." if target.is_empty() else "This is your controlled country. Choose another country for diplomacy."
		return
	var registry = world_lab.registry
	var progress: int = registry.dialogue_progress(world.country.id, target)
	var remaining: int = registry.agreement_days(world.country.id, target)
	var kind := "cooperation" if shared_proposal_picker.selected == 1 else "dialogue"
	var state := "No active talks." if progress < 0 else "%s talks: day %d / %d." % [registry.talk_kind(world.country.id, target).capitalize(), progress, WorldLab.Registry.TALK_DAYS]
	var rules := "Dialogue completes after 30 days, adding 5 relations without a direct cost."
	if kind == "cooperation":
		rules = "Cooperation concludes after 30 days. If relations are at least 5, each borrows $5M for a one-time cost, relations rise by 10, and an agreement lasts 365 days. Eligibility now: %s. Conditions are checked at completion." % ("yes" if registry.cooperation_eligible(world.country.id, target) else "no")
	shared_diplomacy_details.text = "FICTIONAL TEST VALUES\nRelations: %.1f / 100\n%s\nAgreement: %s\n\n%s" % [registry.relationship(world.country.id, target), state, "%d days remaining" % remaining if remaining > 0 else "none", rules]
	shared_talk_button.disabled = progress >= 0 or (kind == "cooperation" and remaining > 0)
	shared_cancel_button.disabled = progress < 0

func _request_shared_talk() -> void:
	_refresh_shared_diplomacy()
	if not shared_world_active or shared_talk_button.disabled:
		return
	if running:
		_toggle_pause()
	var target := _shared_partner_id()
	var kind := "cooperation" if shared_proposal_picker.selected == 1 else "dialogue"
	pending_shared_talk = {"controlled": world.country.id, "target": target, "kind": kind, "snapshot": JSON.stringify(world_lab.registry.export_snapshot())}
	shared_talk_dialog.dialog_text = "Open %s talks between %s and %s? Talks conclude after 30 shared-world days. The clock has been paused. %s" % [kind, world.country.name, world_lab.registry.country_snapshot(target).country.name, shared_diplomacy_details.text]
	shared_talk_dialog.popup_centered()

func _confirm_shared_talk() -> void:
	if pending_shared_talk.is_empty():
		return
	var request := pending_shared_talk.duplicate(true)
	pending_shared_talk.clear()
	if not shared_world_active or running or world.country.id != request.controlled or _shared_partner_id() != request.target or ("cooperation" if shared_proposal_picker.selected == 1 else "dialogue") != request.kind or JSON.stringify(world_lab.registry.export_snapshot()) != request.snapshot:
		status.text = "Diplomacy review is out of date. Review it again."
		return
	status.text = "Shared-world talks opened." if world_lab.registry.start_talks(request.controlled, request.target, request.kind) else "Talks are unavailable."
	_refresh()

func _cancel_shared_talk() -> void:
	var target := _shared_partner_id()
	if not shared_world_active or target.is_empty() or target == world.country.id:
		return
	status.text = "Shared-world talks cancelled." if world_lab.registry.cancel_talks(world.country.id, target) else "No shared-world talks are active."
	_refresh()

func _refresh_map_layer() -> void:
	if map_layer_picker == null or world_map == null:
		return
	var available: Array = []
	var active := ""
	for binding in map_bindings:
		available.append(binding.map_id)
		if _map_binding_active(binding):
			active = binding.map_id
	world_map.set_scenario_layer(map_layer_picker.selected, available, active)
	if not map_binding_error.is_empty():
		map_legend.text = "Sandbox layer unavailable: " + map_binding_error
	elif map_layer_picker.selected == 1:
		map_legend.text = "Gold: sandbox available  •  Teal: active sandbox  •  Slate: reference only"
	else:
		map_legend.text = "Geographic reference view"

func _refresh_map_simulation() -> void:
	if map_simulation == null:
		return
	_refresh_map_layer()
	var selected: String = world_map.selected_id
	var index := _map_scenario_index(selected)
	var binding := _map_binding(selected)
	map_scenario_button.visible = index >= 0
	if shared_world_active and not _map_binding_active(binding):
		map_scenario_button.visible = false
	if selected.is_empty():
		map_simulation.text = ""
	elif not map_binding_error.is_empty():
		map_simulation.text = "Sandbox links are unavailable: " + map_binding_error
	elif index < 0:
		map_simulation.text = "REFERENCE ONLY\nNo playable country scenario is linked here yet."
	elif _map_binding_active(binding):
		map_scenario_button.text = "Open government"
		map_simulation.text = "ACTIVE %s — MIXED OR FICTIONAL DATA\nPopulation: %d\nApproval: %.1f%%\nAnnual deficit: %s\nNew US games start with historical Census and Treasury data; politics and future outcomes are simulated. Older saves may differ. City simulation is not implemented." % [binding.short_name.to_upper(), world.country.population, world.country.approval, world.format_deficit(world.annual_deficit())]
	elif shared_world_active:
		map_simulation.text = "SHARED WORLD COUNTRY\nUse the diplomacy panel below to inspect this country. Scenario changes are unavailable while sharing a world."
	else:
		map_scenario_button.text = "Start " + binding.short_name
		map_simulation.text = "%s AVAILABLE\nNew games use a Census population estimate and FY2026 federal finances; other values are fictional. Starting replaces the current session after confirmation." % binding.short_name.to_upper()

func _map_scenario_action() -> void:
	var index := _map_scenario_index(world_map.selected_id)
	if index < 0:
		return
	if _map_binding_active(_map_binding(world_map.selected_id)):
		dashboard_tabs.current_tab = 3
	else:
		_request_new_scenario(index)

func _search_map(query: String) -> void:
	map_results.clear()
	var text := query.strip_edges().to_lower()
	map_results.visible = not text.is_empty()
	map_search_status.text = ""
	if text.is_empty():
		return
	var matches: Array[Dictionary] = []
	for kind in ["country", "city"]:
		if (map_search_scope.selected == 1 and kind != "country") or (map_search_scope.selected == 2 and kind != "city"):
			continue
		var entries: Array = world_map.countries if kind == "country" else world_map.cities
		for i in range(entries.size()):
			var name: String = entries[i].name.to_lower()
			var code: String = str(entries[i].get("id", "")).to_lower() if kind == "country" else str(entries[i].get("country", "")).to_lower()
			if text not in name and text != code:
				continue
			var rank := 0 if name == text or code == text else (1 if name.begins_with(text) else 2)
			matches.append({"kind": kind, "index": i, "name": entries[i].name, "rank": rank})
	matches.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.rank != b.rank:
			return a.rank < b.rank
		if a.kind != b.kind:
			return a.kind == "country"
		return a.name.naturalnocasecmp_to(b.name) < 0
	)
	for result in matches.slice(0, 30):
		map_results.add_item("%s • %s" % ["Country" if result.kind == "country" else "City", result.name])
		map_results.set_item_metadata(map_results.item_count - 1, {"kind": result.kind, "index": result.index})
	map_search_status.text = "No matches." if matches.is_empty() else ("Showing 30 of %d results. Enter opens the first." % matches.size() if matches.size() > 30 else "%d result(s). Enter opens the first." % matches.size())

func _submit_map_search(_query: String) -> void:
	if map_results.visible and map_results.item_count > 0:
		_select_map_result(0)

func _select_map_result(index: int) -> void:
	if index < 0 or index >= map_results.item_count:
		return
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

func _fiscal_forecast(days: int, changes: Dictionary = {}) -> Dictionary:
	return world_lab.registry.forecast_fiscal(world.country.id, days, changes) if shared_world_active else world.forecast_fiscal(days, changes)

func _forecast_budget() -> void:
	forecast_current = false
	var days := forecast_horizon.get_selected_id()
	var result: Dictionary = _fiscal_forecast(days)
	if result.is_empty():
		forecast_label.text = "Forecast unavailable for this state."
		return
	var d: Dictionary = result.end_date
	var warning := _forecast_deficit_summary(result)
	var model_note := "Shared-world model includes existing bilateral talks and agreements." if shared_world_active else "Single-country model."
	forecast_label.text = "%d-DAY FORECAST to %04d-%02d-%02d (current settings; rerun after changes)\nPopulation %d | Debt $%.0f | Approval %.1f%%\nRevenue $%.0f | Spending $%.0f | Policy $%.0f | Interest $%.0f\n%s %s Fictional model; no unmodeled future shocks or decisions." % [days, d.year, d.month, d.day, result.population, result.debt, result.approval, result.revenue, result.spending, result.policy, result.interest, warning, model_note]
	forecast_current = true

func _forecast_deficit_summary(result: Dictionary) -> String:
	return "Period deficit: %s (negative means surplus)." % world.format_deficit(result.spending + result.policy + result.interest - result.revenue)

func _compare_budget() -> void:
	comparison_current = false
	var days := forecast_horizon.get_selected_id()
	var baseline: Dictionary = _fiscal_forecast(days)
	var kind := _additional_tax_kind()
	var changes := {"income_tax": tax.value / 100.0}
	var budget_description := ""
	if comparison_scope.selected == 0:
		changes["spending"] = spending.value * 1000000.0
		budget_description = "total budget $%.0f; this resets category shares" % changes.spending
	else:
		var category := category_picker.get_item_text(category_picker.selected)
		changes["category_spending"] = {"category": category, "amount": category_amount.value * 1000000.0}
		budget_description = "%s category $%.0f; other category amounts are unchanged" % [category, changes.category_spending.amount]
	changes[kind + "_tax"] = additional_tax.value / 100.0
	var proposed: Dictionary = _fiscal_forecast(days, changes)
	if baseline.is_empty() or proposed.is_empty():
		comparison_label.text = "Comparison unavailable for these inputs."
		return
	var model_note := "Shared-world forecast includes existing bilateral talks and agreements." if shared_world_active else "Single-country forecast."
	comparison_label.text = "%d-DAY COMPARISON (does not apply changes; rerun after edits)\nProposed: income %.1f%%, %s %.1f%%, %s.\nDebt: $%.0f → $%.0f (change $%+.0f)\nApproval: %.1f%% → %.1f%% (change %+.1f points)\nCurrent: %s\nProposal: %s\nChanges are proposal minus current settings. %s Fictional rules; no future decisions or shocks." % [days, tax.value, kind, additional_tax.value, budget_description, baseline.debt, proposed.debt, proposed.debt - baseline.debt, baseline.approval, proposed.approval, proposed.approval - baseline.approval, _forecast_deficit_summary(baseline), _forecast_deficit_summary(proposed), model_note]
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
			_advance_world_tick()
			processed += 1
		if processed > 0:
			_refresh()

func _toggle_pause() -> void:
	running = not running
	pause_button.text = "Pause" if running else "Resume"
	_update_speed_status()

func _advance_day() -> void:
	_advance_world_tick()
	_refresh()

func _advance_world_tick() -> void:
	if shared_world_active:
		world_lab.registry.advance_day()
	else:
		world.advance_day()

func _request_new_scenario(index: int) -> void:
	if shared_world_active:
		status.text = "Leave the shared world before starting another scenario."
		return
	if index < 0 or index >= SCENARIOS.size():
		status.text = "Select a built-in scenario first."
		return
	pending_scenario_index = index
	new_game_confirmation.dialog_text = "Start %s? This replaces your current session. Save first if you want to keep your progress." % SCENARIOS[index].name
	new_game_confirmation.popup_centered()

func _confirm_new_scenario() -> void:
	var index := pending_scenario_index
	pending_scenario_index = -1
	if index >= 0 and index < SCENARIOS.size():
		_start_scenario(SCENARIOS[index].path)

func _start_scenario(path: String) -> bool:
	if shared_world_active:
		status.text = "Leave the shared world before starting another scenario."
		return false
	var error: String = world.apply_scenario(World.Scenario.read_file(path))
	if not error.is_empty():
		status.text = "Could not start scenario: " + error
		return false
	running = false
	elapsed = 0.0
	pause_button.text = "Resume"
	tax.value = world.country.income_tax_rate * 100.0
	_additional_tax_selected(additional_tax_picker.selected)
	_sync_budget_bounds()
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
	if shared_world_active and world_lab.selected_id() == world.country.id:
		world_lab.tax.value = world.country.income_tax_rate * 100.0
	_refresh()

func _start_talks() -> void:
	if shared_world_active:
		return
	var keys: Array = world.diplomacy.PARTNERS.keys()
	var partner: String = keys[diplomacy_picker.selected]
	var choice: String = world.diplomacy.PROPOSALS.keys()[proposal_picker.selected]
	status.text = Decisions.execute(world, {"id": "start_talks", "args": {"partner": partner, "proposal": choice}}).message
	_refresh()

func _cancel_talks() -> void:
	if shared_world_active:
		return
	status.text = Decisions.execute(world, {"id": "cancel_talks", "args": {}}).message
	_refresh()

func _end_cooperation() -> void:
	if shared_world_active:
		return
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
	if not law_catalog_error.is_empty():
		law_catalog_note.text = law_catalog_error
		healthcare_panel.visible = false
		procurement_panel.visible = false
		law_edit_panel.visible = false
		return
	var category := law_categories.get_tab_title(law_categories.current_tab)
	var query := law_search.text.strip_edges().to_lower()
	var first_id := ""
	var selected_row: TreeItem = null
	for law in law_catalog_data.laws:
		if not law_search_all.button_pressed and law.category != category:
			continue
		var search_text: String = (law.name + " " + law.category + " " + " ".join(law.keywords)).to_lower()
		if not query.is_empty() and query not in search_text:
			continue
		var state := "Planned"
		var cost := 0.0
		match law.id:
			"healthcare":
				state = "Active" if world.healthcare.active else "Not enacted"
				cost = world.healthcare.annual_cost()
			"procurement":
				state = "Active" if world.politics.procurement_policy else "Not enacted"
				cost = float(world.policy_rules.procurement_annual_cost) if world.politics.procurement_policy and world.politics.procurement_progress >= 100 else 0.0
			"test_budget_category", "test_income_tax", "test_corporate_tax", "test_consumption_tax":
				state = "Editable prototype"
		var row := law_catalog.create_item(root_item)
		row.set_text(0, (law.category + " — " if law_search_all.button_pressed else "") + law.name)
		row.set_text(1, state)
		row.set_text(2, "Not modeled" if state == "Planned" else ("See preview" if state == "Editable prototype" else "$%.1fM / year" % (cost / 1000000.0)))
		row.set_metadata(0, law.id)
		if first_id.is_empty():
			first_id = law.id
			row.select(0)
		if law.id == selected_law_id:
			selected_row = row
	if first_id.is_empty():
		law_catalog_note.text = "No policy topics match this category and search."
		healthcare_panel.visible = false
		procurement_panel.visible = false
		law_edit_panel.visible = false
		return
	if selected_row != null:
		selected_row.select(0)
		_show_law_detail(selected_law_id)
	else:
		_show_law_detail(first_id)

func _law_catalog_selected() -> void:
	var selected := law_catalog.get_selected()
	if selected != null:
		_show_law_detail(str(selected.get_metadata(0)))

func _show_law_detail(id: String) -> void:
	selected_law_id = id
	healthcare_panel.visible = id == "healthcare"
	procurement_panel.visible = id == "procurement"
	law_edit_panel.visible = id in ["test_budget_category", "test_income_tax", "test_corporate_tax", "test_consumption_tax"]
	law_catalog_note.text = "Prototype: values and political rules are fictional." if id in ["healthcare", "procurement"] or law_edit_panel.visible else "Planned topic: not yet a proposal or enacted law. Legal authority, options, costs and effects are not modeled."
	if law_edit_panel.visible:
		law_edit_kind = id
		law_edit_category.visible = id == "test_budget_category"
		law_edit_amount.max_value = World.Scenario.spending_limit(world.country) / 1000000.0 if law_edit_category.visible else 60.0
		law_edit_amount.suffix = "million USD / year" if law_edit_category.visible else "%"
		_sync_law_edit_value()
	if id == "procurement":
		procurement_detail.text = "PROCUREMENT POLICY — fictional test rules\nCurrent: %s | rollout: %d%% | votes for adoption: %d/100 | votes for repeal: %d/100\nOnce fully implemented, the policy costs $%.1fM per year. A majority is required." % ["active" if world.politics.procurement_policy else "not enacted", world.politics.procurement_progress, world.politics.votes_for_policy(), world.politics.votes_for_repeal(), float(world.policy_rules.procurement_annual_cost) / 1000000.0]

func _sync_law_edit_value() -> void:
	if not law_edit_panel.visible:
		return
	match law_edit_kind:
		"test_budget_category": law_edit_amount.value = float(world.country.spending_categories[law_edit_category.get_item_text(law_edit_category.selected)]) / 1000000.0
		"test_income_tax": law_edit_amount.value = float(world.country.income_tax_rate) * 100.0
		"test_corporate_tax": law_edit_amount.value = float(world.country.corporate_tax_rate) * 100.0
		"test_consumption_tax": law_edit_amount.value = float(world.country.consumption_tax_rate) * 100.0
	_refresh_law_edit_preview()

func _law_edit_request() -> Dictionary:
	match law_edit_kind:
		"test_budget_category": return {"id": "set_category_spending", "args": {"category": law_edit_category.get_item_text(law_edit_category.selected), "amount": law_edit_amount.value * 1000000.0}}
		"test_income_tax": return {"id": "set_income_tax", "args": {"rate": law_edit_amount.value / 100.0}}
		"test_corporate_tax", "test_consumption_tax": return {"id": "set_additional_tax", "args": {"kind": "corporate" if law_edit_kind == "test_corporate_tax" else "consumption", "rate": law_edit_amount.value / 100.0}}
	return {}

func _refresh_law_edit_preview() -> void:
	if not is_instance_valid(law_edit_panel) or not law_edit_panel.visible:
		return
	var request := _law_edit_request()
	var details := _review_text(request.id, request.args) if not request.is_empty() else ""
	law_edit_button.disabled = details.is_empty()
	law_edit_preview.text = "Preview unavailable for this amount." if details.is_empty() else details

func _review_law_edit() -> void:
	var request := _law_edit_request()
	if not request.is_empty():
		_request_review(request.id, request.args)

func _review_text(id: String, args: Dictionary) -> String:
	match id:
		"set_income_tax", "set_additional_tax":
			var kind: String = "income" if id == "set_income_tax" else str(args.kind)
			var rate: float = float(args.rate)
			var preview: Dictionary = world.preview_income_tax(rate) if kind == "income" else world.preview_additional_tax(kind, rate)
			if preview.is_empty():
				return ""
			var field: String = "income_tax_rate" if kind == "income" else world.ADDITIONAL_TAXES[kind].field
			var lines := PackedStringArray(["%s TAX — fictional fixed-base model" % kind.to_upper(), "Rate: %.1f%% → %.1f%%" % [float(world.country[field]) * 100.0, rate * 100.0], "Annual revenue: $%.1fM → $%.1fM" % [world.total_annual_revenue() / 1000000.0, preview.annual_revenue / 1000000.0], "National approval: %.1f%% → %.1f%%" % [world.country.approval, preview.approval]])
			lines.append("Annual deficit: %s → %s (negative means surplus)" % [world.format_deficit(world.annual_deficit()), world.format_deficit(world.annual_deficit() + world.total_annual_revenue() - preview.annual_revenue)])
			for group in preview.groups:
				lines.append("%s approval: %.1f%%" % [group.name, group.approval])
			lines.append("This prototype applies the change immediately; legal passage and wider economic effects are not modeled.")
			return "\n".join(lines)
		"set_total_spending", "set_category_spending":
			var amount: float = float(args.amount)
			var is_total := id == "set_total_spending"
			var preview: Dictionary = world.preview_annual_spending(amount) if is_total else world.preview_category_spending(str(args.category), amount)
			if preview.is_empty():
				return ""
			var label: String = "Total category spending" if is_total else str(args.category) + " category"
			var previous: float = world.country.annual_spending if is_total else world.country.spending_categories[args.category]
			var explanation := "This resets every category to the scenario's default shares." if is_total else "Other category amounts remain unchanged."
			return "%s — simplified budget model\n\nAnnual amount: $%.1fM → $%.1fM\nAnnual deficit: %s → %s (negative means surplus)\n\n%s Service and approval effects develop over time; wider economic effects are not modeled." % [label, previous / 1000000.0, amount / 1000000.0, world.format_deficit(world.annual_deficit()), world.format_deficit(-preview.annual_balance), explanation]
		"introduce_congress_bill":
			var preview: Dictionary = world.preview_healthcare(float(args.funding))
			if preview.is_empty():
				return ""
			return "Introduce a healthcare bill with $%.0fM annual authorization into the fictional House? No policy takes effect at introduction. If enacted under the current appropriation, annual healthcare spending would be $%.0fM and the annual balance $%.0fM. Actual costs depend on funding when enacted." % [float(args.funding) / 1000000.0, preview.annual_cost / 1000000.0, preview.annual_balance / 1000000.0]
		"congress_vote":
			var stage: String = world.congress.stage
			if stage not in ["house", "senate", "override_house", "override_senate"]:
				return ""
			var house := stage in ["house", "override_house"]
			var override := stage in ["override_house", "override_senate"]
			var total := 435 if house else 100
			var yes: int = world.congress.votes("house" if house else "senate", world.healthcare.rules.funding_options)
			var required: int = ceili(total * 2.0 / 3.0) if override else floori(total / 2.0) + 1
			return "%s %s vote: %d of %d fictional members support the bill; %d votes required. Projected outcome: %s. All members are assumed to vote. A successful final override enacts the bill." % ["House" if house else "Senate", "override" if override else "passage", yes, total, required, "passes" if yes >= required else "fails"]
		"congress_president":
			if world.congress.stage != "president":
				return ""
			var preview: Dictionary = world.preview_healthcare(world.congress.funding)
			return "Presidential action: %s. %s\n\nIf enacted at current appropriation: healthcare cost $%.0fM/year; annual balance $%.0fM. These are fictional estimates at current conditions." % [args.action, "Signing enacts the healthcare authorization." if args.action == "sign" else "A veto returns the bill to the House; both chambers must override to enact it.", preview.annual_cost / 1000000.0, preview.annual_balance / 1000000.0]
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

func _refresh_congress() -> void:
	if congress_summary == null:
		return
	var bill = world.congress
	var can_introduce: bool = bill.stage in ["idle", "failed", "enacted"]
	var can_vote: bool = bill.stage in ["house", "senate", "override_house", "override_senate"]
	congress_buttons.introduce_congress_bill.disabled = not can_introduce
	congress_buttons.congress_vote.disabled = not can_vote
	congress_buttons.sign.disabled = bill.stage != "president"
	congress_buttons.veto.disabled = bill.stage != "president"
	congress_funding.disabled = not can_introduce
	var amount: float = world.healthcare.rules.funding_options[congress_funding.selected] if can_introduce else bill.funding
	var house_votes: int = bill.votes_for(amount, "house", world.healthcare.rules.funding_options)
	var senate_votes: int = bill.votes_for(amount, "senate", world.healthcare.rules.funding_options)
	var preview: Dictionary = world.preview_healthcare(amount)
	var lines := PackedStringArray(["HOUSE: 435 seats (Civic 230, Liberty 205) | SENATE: 100 seats (Civic 52, Liberty 48) | PRESIDENT: player (Civic)", "Fictional support for %s: House %d/435 | Senate %d/100. All members vote; support can cross party lines." % ["selected proposal" if can_introduce else "current bill", house_votes, senate_votes], "Bill stage: %s | Bill authorization: $%.0fM/year" % [bill.stage.replace("_", " ").capitalize(), bill.funding / 1000000.0], "If %s is enacted under current appropriation: healthcare cost $%.0fM/year; projected annual balance $%.0fM." % ["selected proposal" if can_introduce else "current bill", preview.annual_cost / 1000000.0, preview.annual_balance / 1000000.0], "RECORDED ACTIONS (current bill)"])
	if bill.history.is_empty():
		lines.append("None recorded. Older saves do not contain past vote details.")
	else:
		for record in bill.history:
			if record.step == "president":
				lines.append("President: %s" % record.result)
			else:
				lines.append("%s: %d/%d — %s" % [record.step.replace("_", " ").capitalize(), int(record.yes), int(record.total), record.result])
	lines.append("Introduction → House → Senate → presidential signature or veto → House and Senate override. The last override or a signature enacts the bill.")
	lines.append("Fictional fixed seats and votes; all members vote. Committees, cloture, absences, amendments and presidential deadlines are not modeled. The older single-chamber controls in Laws remain a separate fictional path.")
	congress_summary.text = "\n".join(lines)

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
	var result: Dictionary = Decisions.execute(world, request)
	status.text = result.message
	if result.ok and request.id in ["set_income_tax", "set_additional_tax", "set_total_spending", "set_category_spending"]:
		tax.value = world.country.income_tax_rate * 100.0
		_additional_tax_selected(additional_tax_picker.selected)
		spending.value = world.country.annual_spending / 1000000.0
		_category_selected(category_picker.selected)
		if shared_world_active and world_lab.selected_id() == world.country.id:
			world_lab.tax.value = world.country.income_tax_rate * 100.0
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
	var error: String = world_lab.save_to(world_lab.LAB_SAVE) if shared_world_active else world.save_game(SAVE_PATH)
	status.text = ("Shared world saved to the lab slot." if shared_world_active else "Game saved.") if error.is_empty() else error

func _load_game() -> void:
	_load_from(SAVE_PATH)

func _load_backup() -> void:
	_load_from(SAVE_PATH + ".bak")

func _load_from(path: String) -> void:
	if shared_world_active:
		status.text = "Leave the shared world before loading a single-country save."
		return
	var error: String = world.load_game(path)
	if error.is_empty():
		_sync_loaded_world("Game loaded and paused.")
	else:
		status.text = error

func _sync_loaded_world(text: String) -> void:
	running = false
	elapsed = 0.0
	pause_button.text = "Resume"
	tax.value = world.country.income_tax_rate * 100.0
	_additional_tax_selected(additional_tax_picker.selected)
	_sync_budget_bounds()
	spending.value = world.country.annual_spending / 1000000.0
	_category_selected(category_picker.selected)
	_sync_scenario_picker()
	_sync_healthcare_picker()
	_sync_directive_picker()
	status.text = text
	_refresh()

func _sync_budget_bounds() -> void:
	var limit_millions: float = World.Scenario.spending_limit(world.country) / 1000000.0
	spending.max_value = limit_millions
	category_amount.max_value = limit_millions

func _request_lab_handoff(id: String) -> void:
	if shared_world_active:
		status.text = "Leave the shared world before copying a lab country."
		return
	if not world_lab.initialized or world_lab.batch_remaining > 0 or id != world_lab.selected_id():
		status.text = "Lab handoff is unavailable while a batch is running or selection changed."
		return
	var snapshot: Dictionary = world_lab.registry.country_snapshot(id)
	var candidate = World.new()
	var error: String = candidate.import_snapshot(snapshot)
	if not error.is_empty():
		status.text = "Lab country cannot be copied: " + error
		return
	if running:
		_toggle_pause()
	world_lab.running = false
	world_lab._refresh_clock()
	pending_lab_handoff = {"id": id, "snapshot": snapshot.duplicate(true), "main_snapshot": JSON.stringify(world.export_snapshot()), "lab_snapshot": JSON.stringify(snapshot)}
	var date: Dictionary = snapshot.date
	lab_handoff_dialog.dialog_text = "Copy %s at %04d-%02d-%02d into the main game? This replaces the current main session; save it first if you want to keep it. Both clocks have been paused. Neither save file is written. The lab stays separate: bilateral relationships and agreements are not transferred, and future changes do not synchronize." % [snapshot.country.name, date.year, date.month, date.day]
	lab_handoff_dialog.popup_centered()

func _cancel_lab_handoff() -> void:
	pending_lab_handoff.clear()

func _confirm_lab_handoff() -> void:
	if pending_lab_handoff.is_empty():
		return
	var request := pending_lab_handoff.duplicate(true)
	_cancel_lab_handoff()
	if shared_world_active or running or world_lab.running or world_lab.batch_remaining > 0 or world_lab.selected_id() != request.id or JSON.stringify(world.export_snapshot()) != request.main_snapshot or JSON.stringify(world_lab.registry.country_snapshot(request.id)) != request.lab_snapshot:
		status.text = "Lab handoff is out of date. Review it again."
		return
	var error: String = world.import_snapshot(request.snapshot)
	if not error.is_empty():
		status.text = "Lab country could not be copied: " + error
		return
	_sync_loaded_world("Lab country copied to the main game; both worlds remain separate.")
	dashboard_tabs.current_tab = 0

func _request_main_to_lab() -> void:
	if shared_world_active:
		status.text = "Leave the shared world before replacing the lab."
		return
	if not world_lab.initialized or world_lab.batch_remaining > 0:
		status.text = "Cannot create a lab world while a batch is running."
		return
	var snapshot: Dictionary = world.export_snapshot()
	var result: Dictionary = world_lab.build_from_main(snapshot)
	if not result.error.is_empty():
		status.text = result.error
		return
	if running:
		_toggle_pause()
	world_lab.running = false
	world_lab._refresh_clock()
	pending_main_to_lab = {"main_snapshot": JSON.stringify(snapshot), "lab_snapshot": JSON.stringify(world_lab.registry.export_snapshot()), "proposed": result.snapshot.duplicate(true)}
	var date: Dictionary = snapshot.date
	main_to_lab_dialog.dialog_text = "Create a new lab world from the main US sandbox at %04d-%02d-%02d? This replaces the current lab session; save it first if you want to keep it. A fresh fictional Coastal Republic starts on the same date, with no bilateral history. Both clocks have been paused. Neither save file is written; the two worlds remain independent." % [date.year, date.month, date.day]
	main_to_lab_dialog.popup_centered()

func _cancel_main_to_lab() -> void:
	pending_main_to_lab.clear()

func _confirm_main_to_lab() -> void:
	if pending_main_to_lab.is_empty():
		return
	var request := pending_main_to_lab.duplicate(true)
	_cancel_main_to_lab()
	if shared_world_active or running or world_lab.running or world_lab.batch_remaining > 0 or JSON.stringify(world.export_snapshot()) != request.main_snapshot or JSON.stringify(world_lab.registry.export_snapshot()) != request.lab_snapshot:
		status.text = "New lab world review is out of date. Review it again."
		return
	var error: String = world_lab.replace_world(request.proposed)
	if not error.is_empty():
		status.text = "Could not create the lab world: " + error
		return
	status.text = "Lab world created from main US sandbox; both worlds remain separate."
	dashboard_tabs.current_tab = 10

func _request_shared_entry(id: String) -> void:
	if shared_world_active or not world_lab.initialized or world_lab.batch_remaining > 0 or id != world_lab.selected_id():
		status.text = "Shared world entry is unavailable while a batch is running or selection changed."
		return
	var state: Dictionary = world_lab.registry.country_snapshot(id)
	var candidate = World.new()
	var error: String = candidate.import_snapshot(state)
	if not error.is_empty():
		status.text = "Cannot enter shared world: " + error
		return
	if running:
		_toggle_pause()
	world_lab.running = false
	world_lab._refresh_clock()
	pending_shared_entry = {"id": id, "main": JSON.stringify(world.export_snapshot()), "lab": JSON.stringify(world_lab.registry.export_snapshot())}
	shared_entry_dialog.dialog_text = "Play %s in the shared lab world? This replaces the current main session; save it first if needed. Both clocks are paused and queued time will be cleared. The main clock will advance both lab countries. Main Save writes the separate lab world slot; load and new-scenario controls are disabled until you leave. Neither save is written now. Bilateral lab diplomacy is separate from the legacy Diplomacy tab." % state.country.name
	shared_entry_dialog.popup_centered()

func _confirm_shared_entry() -> void:
	if pending_shared_entry.is_empty():
		return
	var request := pending_shared_entry.duplicate(true)
	pending_shared_entry.clear()
	if shared_world_active or running or world_lab.running or world_lab.batch_remaining > 0 or world_lab.selected_id() != request.id or JSON.stringify(world.export_snapshot()) != request.main or JSON.stringify(world_lab.registry.export_snapshot()) != request.lab:
		status.text = "Shared world review is out of date. Review it again."
		return
	var selected: Variant = world_lab.registry.controlled_country(request.id)
	if selected == null:
		status.text = "Shared country is unavailable."
		return
	world = selected
	shared_world_active = true
	world_lab.set_shared_mode(true, request.id)
	_update_shared_controls()
	_sync_loaded_world("Shared world active; main clock advances both countries.")
	dashboard_tabs.current_tab = 0

func _request_shared_switch(id: String) -> void:
	if not shared_world_active or id != world_lab.selected_id() or id == world.country.id:
		status.text = "Select a different country in the shared world first."
		return
	var state: Dictionary = world_lab.registry.country_snapshot(id)
	var candidate = World.new()
	var error: String = candidate.import_snapshot(state)
	if not error.is_empty():
		status.text = "Cannot switch country: " + error
		return
	if running:
		_toggle_pause()
	pending_shared_switch = {"id": id, "controlled_id": world.country.id, "lab": JSON.stringify(world_lab.registry.export_snapshot())}
	shared_switch_dialog.dialog_text = "Switch main control from %s to %s? Both countries and their relationships remain in the same world. The shared clock has been paused; queued time will be cleared if you switch. No save file is written. The selected country's policies and data will appear in the main interface." % [world.country.name, state.country.name]
	shared_switch_dialog.popup_centered()

func _request_shared_restore(path: String) -> void:
	if not world_lab.initialized or world_lab.batch_remaining > 0:
		status.text = "Shared restore is unavailable while a lab batch is running."
		return
	var candidate = WorldLab.Registry.new()
	var error: String = candidate.load_game(path)
	if error.is_empty():
		error = world_lab._check_lab_identity(candidate)
	if error.is_empty() and candidate.saved_controlled_id.is_empty():
		error = "This lab save has no shared controlled country; load it in World Lab and enter shared mode manually."
	if not error.is_empty():
		status.text = "Cannot restore shared world: " + error
		return
	if running:
		_toggle_pause()
	world_lab.running = false
	world_lab._refresh_clock()
	pending_shared_restore = {"path": path, "snapshot": JSON.stringify(candidate.export_snapshot()), "id": candidate.saved_controlled_id, "main": JSON.stringify(world.export_snapshot()), "lab": JSON.stringify(world_lab.registry.export_snapshot()), "shared": shared_world_active}
	shared_restore_dialog.dialog_text = "Restore the saved shared world as %s? This replaces both current sessions. Save them first if needed. Both clocks are paused; restoring clears queued time. No save file is written." % candidate.country_snapshot(candidate.saved_controlled_id).country.name
	shared_restore_dialog.popup_centered()

func _confirm_shared_restore() -> void:
	if pending_shared_restore.is_empty():
		return
	var request := pending_shared_restore.duplicate(true)
	pending_shared_restore.clear()
	var candidate = WorldLab.Registry.new()
	var error: String = candidate.load_game(request.path)
	if error.is_empty():
		error = world_lab._check_lab_identity(candidate)
	if not error.is_empty() or running or world_lab.running or world_lab.batch_remaining > 0 or shared_world_active != request.shared or JSON.stringify(world.export_snapshot()) != request.main or JSON.stringify(world_lab.registry.export_snapshot()) != request.lab or JSON.stringify(candidate.export_snapshot()) != request.snapshot or candidate.saved_controlled_id != request.id:
		status.text = "Shared restore is out of date or invalid. Review it again."
		return
	_cancel_review()
	review_dialog.hide()
	world_lab._accept_registry(candidate, "Shared world restored.")
	world = candidate.controlled_country(request.id)
	shared_world_active = true
	world_lab.set_shared_mode(true, request.id)
	_update_shared_controls()
	_sync_loaded_world("Shared world restored and paused.")
	dashboard_tabs.current_tab = 0

func _confirm_shared_switch() -> void:
	if pending_shared_switch.is_empty():
		return
	var request := pending_shared_switch.duplicate(true)
	pending_shared_switch.clear()
	if not shared_world_active or running or world_lab.running or world_lab.selected_id() != request.id or world.country.id != request.controlled_id or JSON.stringify(world_lab.registry.export_snapshot()) != request.lab:
		status.text = "Country switch review is out of date. Review it again."
		return
	var selected: Variant = world_lab.registry.controlled_country(request.id)
	if selected == null:
		status.text = "Selected country is unavailable."
		return
	_cancel_review()
	review_dialog.hide()
	world = selected
	world_lab.shared_controlled_id = request.id
	_sync_loaded_world("Main control switched within the shared world; the clock is paused.")
	dashboard_tabs.current_tab = 0

func _leave_shared_world() -> void:
	if not shared_world_active:
		return
	var detached = World.new()
	var error: String = detached.import_snapshot(world.export_snapshot())
	if not error.is_empty():
		status.text = "Cannot leave shared world: " + error
		return
	world = detached
	shared_world_active = false
	world_lab.set_shared_mode(false)
	_update_shared_controls()
	_sync_loaded_world("Shared world left; main country is now an independent copy.")

func _update_shared_controls() -> void:
	main_save_button.text = "Save shared world" if shared_world_active else "Save"
	main_load_button.disabled = shared_world_active
	main_backup_button.disabled = shared_world_active
	scenario_start_button.disabled = shared_world_active
	mode_notice.text = "US SANDBOX  ·  Census population and FY2026 federal finances; politics and tax model fictional" if world.country.has("fiscal_calibration") else ("MIXED-DATA US SANDBOX  ·  July 2025 Census starting population; other inputs fictional" if world.country.get("name", "") == "United States (mixed-data sandbox)" else ("SHARED WORLD  ·  Fictional test values  ·  Diplomacy on World Map" if shared_world_active else "FICTIONAL TEST SCENARIO  ·  Early simulation prototype"))

func _refresh() -> void:
	_invalidate_forecasts()
	_update_speed_status()
	_update_shared_controls()
	if shared_world_active:
		world_lab.refresh()
	_refresh_map_simulation()
	_refresh_shared_diplomacy()
	world_lab.set_main_import_available(world.scenario_id == "usa_sandbox" and world.country.id == "usa_sandbox" and world.date.year <= 9998)
	var c: Dictionary = world.country
	var d: Dictionary = world.date
	government_status.text = "%s   |   %04d-%02d-%02d   |   Annual deficit %s   |   Approval %.1f%%" % [c.name, d.year, d.month, d.day, world.format_deficit(world.annual_deficit()), c.approval]
	summary.text = "%s\nDate: %04d-%02d-%02d\nPopulation: %d\nDebt: $%.0f\nAnnual revenue: $%.0f   |   Category spending: $%.0f\nAnnual policy cost: $%.0f  |  Debt interest: $%.0f\nAnnual deficit: %s (negative means surplus)\nIncome tax: %.1f%%   |   Approval: %.1f%%" % [c.name, d.year, d.month, d.day, c.population, c.debt, world.total_annual_revenue(), c.annual_spending, world.policy_annual_cost(), world.debt_interest(), world.format_deficit(world.annual_deficit()), c.income_tax_rate * 100.0, c.approval]
	var budget_lines := PackedStringArray(["ANNUAL CATEGORY SPENDING"])
	if c.has("fiscal_calibration"):
		budget_lines.append("Starting figures use FY2026 federal receipts, outlays and public debt. GDP is the latest Q3 2026 annualized estimate and remains fixed; this mixed-period ratio differs from CBO fiscal-year GDP. Five categories are a provisional crosswalk; interest is separate. Tax rates, tax responses, service scores and political effects are fictional assumptions. Historical annual totals are not forecasts.")
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
	_refresh_congress()
	var demographic_rules: Dictionary = world.demographics.rules
	var people := PackedStringArray(["POPULATION AND APPROVAL — fictional test groups", "Population: %d | assumed annual rates per 1,000: births %.1f, deaths %.1f, net migration %+.1f. Population changes daily using these fixed rates; values are fictional, not real statistics." % [c.population, demographic_rules.birth_rate_tenths / 10.0, demographic_rules.death_rate_tenths / 10.0, demographic_rules.migration_rate_tenths / 10.0], "National approval is the population-share weighted average of group approval. Raw approval includes the initial value and prior tax responses; it is not a breakdown of individual causes. Services add a separate contribution. Displayed approval is clamped to 0–100%."])
	if c.name == "United States (mixed-data sandbox)":
		people[1] = "Population: %d. New US games start at the Census Vintage 2025 estimate of 341,784,857 on July 1, 2025. Growth is not modeled; zero rates are placeholders, not observed birth, death or migration rates. Source: https://www.census.gov/quickfacts/fact/table/US/PST045222" % c.population
	var group_counts: Array = world.politics.population_counts(c.population)
	for i in range(world.politics.groups.size()):
		var group: Dictionary = world.politics.groups[i]
		var count_text := "%d people" % group_counts[i] if group_counts.size() == world.politics.groups.size() else "count unavailable"
		people.append("%s | %.0f%% of population (%s) | approval %.1f%%\n  Raw %.1f + services %+.1f points | effect of +1 percentage point tax: income %+.2f, consumption %+.2f, corporate %+.2f approval points before limits." % [group.name, group.share * 100.0, count_text, group.approval, group.raw_approval, group.service_bonus, -group.tax_sensitivity / 100.0, -group.additional_tax_sensitivity.consumption / 100.0, -group.additional_tax_sensitivity.corporate / 100.0])
	people.append("Group counts allocate whole people from fixed shares and sum to the country population; approval uses the unrounded shares. Service contribution responds gradually to the average condition of the five services. Group shares and tax bases stay fixed; age, fertility, employment, migration policy and individual personalities are not modeled. The three groups, rates and sensitivities are placeholders, not real demographic data.")
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
	_refresh_indicators()
	_update_tax_preview(tax.value)
	_update_additional_tax_preview(additional_tax.value)
	_update_spending_preview(spending.value)
	_update_category_preview(category_amount.value)

func _update_speed_status() -> void:
	if elapsed >= 1.0:
		speed_status.text = "%s — %d simulation days queued. The game processes the backlog over multiple frames." % ["Running" if running else "Paused", int(elapsed)]
	else:
		speed_status.text = "Simulation %s." % ("running" if running else "paused")

func _refresh_indicators() -> void:
	if indicator_picker == null or indicator_chart == null or indicator_summary == null:
		return
	var field: String = indicator_picker.get_item_metadata(indicator_picker.selected)
	var samples: Array = []
	for sample in world.indicator_history:
		if field == "deficit" and sample.has("balance"):
			var converted: Dictionary = sample.duplicate(true)
			converted["deficit"] = -float(sample.balance) / float(world.country.nominal_gdp) * 100.0 if world.country.has("nominal_gdp") else -float(sample.balance)
			samples.append(converted)
		elif sample.has(field):
			samples.append(sample)
	indicator_chart.set_series(samples, field)
	if samples.is_empty():
		indicator_summary.text = "No samples for this indicator yet. Older saves begin recording new values at the next month; missing past values are not invented."
		return
	var low := INF
	var high := -INF
	for sample in samples:
		low = minf(low, float(sample[field]))
		high = maxf(high, float(sample[field]))
	var first: Dictionary = samples.front().date
	var last: Dictionary = samples.back().date
	var is_gdp_ratio: bool = field == "deficit" and world.country.has("nominal_gdp")
	var divisor := 1.0 if field in ["approval", "population"] or is_gdp_ratio else 1000000.0
	var units := "% of GDP" if is_gdp_ratio else ("%" if field == "approval" else ("people" if field == "population" else "M USD"))
	var low_text := "%d" % int(low) if field == "population" else "%.1f" % (low / divisor)
	var high_text := "%d" % int(high) if field == "population" else "%.1f" % (high / divisor)
	var lines := PackedStringArray(["%d %s · %04d-%02d-%02d to %04d-%02d-%02d\nChart range: %s to %s %s. Each chart scales to its own range." % [samples.size(), "sample" if samples.size() == 1 else "samples", first.year, first.month, first.day, last.year, last.month, last.day, low_text, high_text, units], "RECENT SAMPLES (up to 12)"])
	for index in range(maxi(0, samples.size() - 12), samples.size()):
		var sample: Dictionary = samples[index]
		var d: Dictionary = sample.date
		var value_text := "%d" % int(sample[field]) if field == "population" else "%.1f" % (float(sample[field]) / divisor)
		lines.append("%04d-%02d-%02d  |  %s %s" % [d.year, d.month, d.day, value_text, units])
	if samples.size() < world.indicator_history.size():
		lines.append("Older samples lack this indicator; no past values were invented.")
	lines.append("Samples are recorded at scenario start and at the beginning of each month; up to 120 are retained. US starting population may be sourced; other values are fictional. These are not forecasts.")
	indicator_summary.text = "\n".join(lines)

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
	spending_preview.text = "TOTAL BUDGET PREVIEW (resets category shares)\nAnnual deficit: %s (negative means surplus)\nService and approval changes develop over time; employment and wider economic effects are not modeled." % [world.format_deficit(-preview.annual_balance)]

func _update_category_preview(value: float) -> void:
	_invalidate_comparison()
	var name := category_picker.get_item_text(category_picker.selected)
	var preview: Dictionary = world.preview_category_spending(name, value * 1000000.0)
	if budget_chart != null:
		_refresh_budget_breakdown()
	if preview.is_empty():
		category_preview.text = "Category preview unavailable: total exceeds budget limit."
		return
	var service_target: float = world.service_target(name, value * 1000000.0)
	category_preview.text = "%s budget preview: annual deficit %s (negative means surplus) | long-run service target %.1f/100 (fictional)" % [name, world.format_deficit(-preview.annual_balance), service_target]

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
