extends SceneTree

const World = preload("res://simulation/world.gd")
const Registry = preload("res://simulation/world_registry.gd")

# Synthetic copies and simplified bilateral dialogue; not a real-world model.
func _initialize() -> void:
	var base: Variant = World.Scenario.read_file(World.DEFAULT_SCENARIO)
	print("Synthetic coupled registry | Godot %s | OS %s" % [Engine.get_version_info().string, OS.get_name()])
	for count in [2, 50, 200]:
		var scenarios: Array = []
		for i in range(count):
			var scenario: Dictionary = base.duplicate(true)
			scenario.country.id = "country_%03d" % i
			scenario.country.name = "Synthetic country %03d" % i
			scenarios.append(scenario)
		var registry = Registry.new()
		var started := Time.get_ticks_usec()
		var error: String = registry.initialize(scenarios)
		if not error.is_empty():
			push_error(error)
			quit(1)
			return
		var initialized := Time.get_ticks_usec()
		var negotiations := 0
		var tick_samples: Array[float] = []
		for day in range(365):
			if day % 90 == 0:
				for i in range(count - 1):
					if registry.start_dialogue("country_%03d" % i, "country_%03d" % (i + 1)):
						negotiations += 1
			var tick_started := Time.get_ticks_usec()
			registry.advance_day()
			tick_samples.append((Time.get_ticks_usec() - tick_started) / 1000.0)
		var finished := Time.get_ticks_usec()
		tick_samples.sort()
		print("countries=%d days=365 dialogues=%d init_ms=%.3f total_ms=%.3f average_daily_work_ms=%.3f p95_tick_ms=%.3f max_tick_ms=%.3f" % [count, negotiations, (initialized - started) / 1000.0, (finished - initialized) / 1000.0, (finished - initialized) / 365000.0, tick_samples[346], tick_samples[364]])
	quit(0)
