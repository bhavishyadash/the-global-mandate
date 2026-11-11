extends SceneTree

const World = preload("res://simulation/world.gd")
const Registry = preload("res://simulation/world_registry.gd")
const SAVE := "res://tests/save_failure_matrix.json"
const SUFFIXES := ["", ".bak", ".tmp", ".bak.previous", ".invalid"]

class FailureInjector:
	extends RefCounted
	var calls := 0
	var failures: Array = []
	func rename_file(source: String, destination: String) -> Error:
		calls += 1
		if calls in failures:
			return ERR_CANT_CREATE
		return DirAccess.rename_absolute(source, destination)
	func partial_write(path: String, _contents: String) -> Error:
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file == null:
			return ERR_CANT_OPEN
		file.store_string("partial save")
		file.close()
		return ERR_FILE_CANT_WRITE

func _initialize() -> void:
	for suffix in SUFFIXES:
		if FileAccess.file_exists(SAVE + suffix):
			push_error("Refusing to overwrite existing test file: " + SAVE + suffix)
			quit(1)
			return
	# Fail the three rotation steps separately, then fail both final replacement
	# and either rollback. Original primary and backup must remain recoverable.
	for registry_mode in [false, true]:
		for failures in [[1], [2], [3], [2, 3], [3, 4], [3, 5], [3, 4, 5]]:
			_run_case(registry_mode, failures)
	print("Save failure matrix checks passed")
	quit(0)

func _run_case(registry_mode: bool, failures: Array) -> void:
		var world: Variant = Registry.new() if registry_mode else World.new()
		if registry_mode:
			var federal: Variant = World.Scenario.read_file(World.DEFAULT_SCENARIO)
			var coastal: Variant = World.Scenario.read_file("res://data/scenarios/coastal_test.json")
			assert(world.initialize([federal, coastal]).is_empty())
		assert(world.save_game(SAVE).is_empty())
		world.advance_day()
		assert(world.save_game(SAVE).is_empty())
		var primary := FileAccess.get_file_as_string(SAVE)
		var backup := FileAccess.get_file_as_string(SAVE + ".bak")
		world.advance_day()
		var injector = FailureInjector.new()
		assert(not world.save_game(SAVE, Callable(), injector.partial_write).is_empty())
		assert(FileAccess.get_file_as_string(SAVE) == primary and FileAccess.get_file_as_string(SAVE + ".bak") == backup)
		assert(not FileAccess.file_exists(SAVE + ".tmp"))
		var temp_directory := ProjectSettings.globalize_path(SAVE + ".tmp")
		assert(DirAccess.make_dir_absolute(temp_directory) == OK)
		assert(not world.save_game(SAVE).is_empty())
		assert(DirAccess.dir_exists_absolute(temp_directory))
		assert(DirAccess.remove_absolute(temp_directory) == OK)
		injector.failures = failures
		assert(not world.save_game(SAVE, injector.rename_file).is_empty())
		var found_primary := false
		var found_backup := false
		for suffix in SUFFIXES:
			if FileAccess.file_exists(SAVE + suffix):
				var content := FileAccess.get_file_as_string(SAVE + suffix)
				found_primary = found_primary or content == primary
				found_backup = found_backup or content == backup
		assert(found_primary and found_backup)
		for suffix in SUFFIXES:
			if FileAccess.file_exists(SAVE + suffix):
				assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE + suffix)) == OK)
