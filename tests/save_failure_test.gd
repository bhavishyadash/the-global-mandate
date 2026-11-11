extends SceneTree

const World = preload("res://simulation/world.gd")
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

func _initialize() -> void:
	for suffix in SUFFIXES:
		if FileAccess.file_exists(SAVE + suffix):
			push_error("Refusing to overwrite existing test file: " + SAVE + suffix)
			quit(1)
			return
	# Fail the three rotation steps separately, then fail both final replacement
	# and either rollback. Original primary and backup must remain recoverable.
	for failures in [[1], [2], [3], [2, 3], [3, 4], [3, 5], [3, 4, 5]]:
		var world = World.new()
		assert(world.save_game(SAVE).is_empty())
		assert(world.set_income_tax(0.25))
		assert(world.save_game(SAVE).is_empty())
		var primary := FileAccess.get_file_as_string(SAVE)
		var backup := FileAccess.get_file_as_string(SAVE + ".bak")
		assert(world.set_income_tax(0.30))
		var injector = FailureInjector.new()
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
	print("Save failure matrix checks passed")
	quit(0)
