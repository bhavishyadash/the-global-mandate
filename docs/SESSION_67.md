# Session 67: save failure matrix

## Delivered

Added a deterministic failure matrix for the single-country save rotation. Tests inject failures in each rename and combined rollback failures, then verify both pre-existing valid save versions remain accessible somewhere among the primary, backup and recovery artifacts. The normal runtime still uses operating-system rename; the injectable callable is used by tests. Existing tests cover invalid candidate state, corrupt primary, backup restoration, interrupted temporary files and a real rename obstruction. Version migration and save/load remain covered by the existing suites.

Eight Godot suites pass locally. Failure injection models returned rename errors; it does not simulate power loss, disk caches, write failures or every filesystem, and cannot establish crash-durable atomic transactions. Manual recovery can still be required; see [save recovery](SAVE_RECOVERY.md). The separate experimental world-registry save uses its own rotation implementation and is outside this failure matrix.
