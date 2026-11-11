extends SceneTree

var screen: Control
var last_tick := 0
var warmup := 60
var samples: Array[float] = []
var measured_usec := 0
var interactions := 0

func _initialize() -> void:
	call_deferred("start")

func start() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Display benchmark requires a graphical display.")
		quit(1)
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	if DisplayServer.window_get_size() != Vector2i(1280, 720):
		push_error("Could not set a 1280x720 window.")
		quit(1)
		return
	screen = load("res://main.tscn").instantiate()
	root.add_child(screen)
	screen._vote_healthcare()
	screen._issue_directive()
	screen.speed = 5
	screen.running = true
	last_tick = Time.get_ticks_usec()
	process_frame.connect(_sample)

func _sample() -> void:
	var current := Time.get_ticks_usec()
	var elapsed_ms := (current - last_tick) / 1000.0
	last_tick = current
	if warmup > 0:
		warmup -= 1
		return
	samples.append(elapsed_ms)
	measured_usec += int(elapsed_ms * 1000.0)
	if measured_usec >= (interactions + 1) * 1000000:
		screen.dashboard_tabs.current_tab = (screen.dashboard_tabs.current_tab + 1) % screen.dashboard_tabs.get_tab_count()
		screen._refresh()
		interactions += 1
	if measured_usec < 10000000:
		return
	var total := 0.0
	for value in samples:
		total += value
	samples.sort()
	print("DISPLAY_BENCHMARK size=1280x720 warmup_frames=60 measured_frames=%d measured_seconds=%.2f tab_changes=%d mean_frame_ms=%.3f p95_frame_ms=%.3f max_frame_ms=%.3f estimated_mean_fps=%.1f queued_days=%.2f simulated_days=%d" % [samples.size(), total / 1000.0, interactions, total / samples.size(), samples[ceili(samples.size() * 0.95) - 1], samples[-1], 1000.0 * samples.size() / total, screen.elapsed, screen.world.fiscal.days])
	quit(0)
