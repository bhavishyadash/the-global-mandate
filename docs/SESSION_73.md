# Session 73: write-failure recovery

## Delivered

Extended the save failure matrix to both single-country and experimental registry saves. It injects a partial candidate write, each of the three rotation failures and combined rollback failures. Tests verify both previous valid files remain recoverable and a failed candidate write is removed. Existing temporary files and directories are protected; the prior implementation could remove an empty directory occupying the temporary filename after an open failure.

The normal save path uses the operating system's file write and rename methods. Optional callables are used for deterministic fault injection. Older-save migrations, invalid candidates, corrupted primary files, existing recovery artifacts, and direct backup loading are covered in the existing tests. Ten Godot suites pass locally.

These tests cover reported write/rename errors, not sudden power failure, operating-system cache durability, disk destruction or concurrent writers. Rotation is a sequence of filesystem operations, not a guaranteed crash-atomic transaction. Recovery artifacts may need manual attention; see [save recovery](SAVE_RECOVERY.md).
