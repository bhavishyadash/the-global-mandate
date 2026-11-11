extends SceneTree

const World = preload("res://simulation/world.gd")
const SAVE := "res://tests/foundation_benchmark_save.json"

func _initialize() -> void:
	call_deferred("run_benchmark")

func run_benchmark() -> void:
	for suffix in ["", ".bak", ".tmp", ".invalid", ".bak.previous"]:
		if FileAccess.file_exists(SAVE + suffix):
			push_error("Benchmark save path already exists: " + SAVE + suffix)
			quit(1)
			return
	var began := Time.get_ticks_usec()
	var screen = load("res://main.tscn").instantiate()
	root.add_child(screen)
	screen.set_process(false)
	var initialized := Time.get_ticks_usec()
	screen._vote_healthcare()
	screen._issue_directive()
	screen.running = true
	screen.speed = 5
	var work_started := Time.get_ticks_usec()
	var samples: Array[float] = []
	for frame in range(600):
		var started := Time.get_ticks_usec()
		screen._process(1.0 / 60.0)
		samples.append((Time.get_ticks_usec() - started) / 1000.0)
	var ended := Time.get_ticks_usec()
	samples.sort()
	var save_started := Time.get_ticks_usec()
	var error: String = screen.world.save_game(SAVE)
	var saved := Time.get_ticks_usec()
	var restored = World.new()
	if not error.is_empty() or not restored.load_game(SAVE).is_empty():
		push_error("Benchmark could not save and reload its scenario.")
		quit(1)
		return
	var loaded := Time.get_ticks_usec()
	if JSON.parse_string(JSON.stringify(restored.export_snapshot())) != JSON.parse_string(JSON.stringify(screen.world.export_snapshot())):
		push_error("Benchmark save round trip did not match.")
		quit(1)
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
	print("FOUNDATION_BENCHMARK ui_init_ms=%.3f ui_frames=600 ui_simulated_days=%d ui_work_total_ms=%.3f ui_work_p95_ms=%.3f ui_work_max_ms=%.3f save_ms=%.3f load_ms=%.3f engine_static_mib=%.2f" % [(initialized - began) / 1000.0, screen.world.fiscal.days, (ended - work_started) / 1000.0, samples[569], samples[599], (saved - save_started) / 1000.0, (loaded - saved) / 1000.0, Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0])
	screen.queue_free()
	quit(0)
