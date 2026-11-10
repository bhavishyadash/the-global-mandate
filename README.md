# The Global Mandate

A work-in-progress Godot 4.7 prototype for a political and geopolitical simulation. The current scenario and economic figures are fictional; the existing tax, approval and spending calculations are simplified placeholders.

Open `project.godot` in Godot 4.7 and press F5. Use the on-screen controls to advance time, adjust tax and spending, and save or load the prototype scenario.

The source-controlled project is this repository's `project.godot`. The earlier project in `Documents/the-global-mandate` is a separate copy; changes in it do not automatically appear here. To compare them without changing either folder, run `python tools/compare_projects.py "C:\Users\Shadow\Documents\the-global-mandate"` from this repository. The comparison ignores generated Godot data, documentation and tooling; it reports differences but never synchronizes files. Review differences before manually copying anything.

The `docs/` directory contains the living development report, initial milestone and partial GPS feature survey. Sessions 6–15 added a small fictional political prototype; see the report for its limits.

Run the headless checks with a Godot 4.7 executable:

```text
godot --headless --path . --script res://tests/simulation_test.gd
godot --headless --path . --script res://tests/ui_test.gd
godot --headless --path . --script res://tests/integration_test.gd
```

For a timeout-protected run of all three checks, use `python tools/run_tests.py --godot PATH_TO_GODOT_CONSOLE`. The runner requires Python 3 and returns a nonzero exit code if a test times out, fails, or does not report its completion marker.

GitHub Actions runs the Python utility tests and Godot headless checks on pull requests and pushes to `main`; its Godot 4.7.2 download is checksum-verified. This hosted check does not replace visual playtesting or Windows-specific compatibility testing.

Save files are stored in Godot's user data directory, not in the repository.
