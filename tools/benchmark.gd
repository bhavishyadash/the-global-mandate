extends SceneTree

const World = preload("res://simulation/world.gd")

# Synthetic benchmark of independent copies, not a coupled world simulation.
func _initialize() -> void:
	print("Synthetic independent-world benchmark | Godot %s | OS %s" % [Engine.get_version_info().string, OS.get_name()])
	for count in [1, 50, 200]:
		var worlds: Array = []
		var started := Time.get_ticks_usec()
		for i in range(count):
			worlds.append(World.new())
		var initialized := Time.get_ticks_usec()
		for day in range(30):
			for world in worlds:
				world.advance_day()
		var finished := Time.get_ticks_usec()
		print("worlds=%d days=30 init_ms=%.3f tick_ms=%.3f world_days_per_second=%.0f" % [count, (initialized - started) / 1000.0, (finished - initialized) / 1000.0, count * 30.0 * 1000000.0 / maxf(1.0, finished - initialized)])
	quit(0)
