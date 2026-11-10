# Session 21 — reliable test invocation

Related to issue #8. Provide one repeatable headless test command with a timeout and clear failure status so a failed assertion cannot leave the test process running indefinitely. Preserve the existing Godot test scripts. The CI issue remains open until an actual CI workflow is implemented and verified.

## Result

`tools/run_tests.py --godot PATH` runs both Godot test scripts with per-test timeouts, temporary logs, required success markers and a nonzero failure exit. Python unit tests cover success, missing markers, failed processes and timeout. The runner and both Godot suites passed on Godot 4.7.2. The program requires Python 3 and a user-provided Godot console executable; no CI workflow or cross-platform test has been added yet.
