# The Global Mandate

A work-in-progress Godot 4.7 prototype for a political and geopolitical simulation. The current scenario and economic figures are fictional; the existing tax, approval and spending calculations are simplified placeholders.

Open `project.godot` in Godot 4.7 and press F5. Use the on-screen controls to advance time, adjust tax and spending, and save or load the prototype scenario.

The prototype starts maximized for readability; the normal window controls can restore or resize it.

The **World Map** tab displays offline Natural Earth reference geography. Drag or use arrow keys to pan; use the mouse wheel, plus/minus keys or buttons to zoom. Select a country or city on the map, or search for its name and choose a result to zoom to it. The map is not yet linked to the fictional playable scenario. See [map data and limitations](data/map/README.md).

The Overview tab offers two fictional starting scenarios. Select one and choose **Start selected scenario**; confirming replaces the current session, so save first if you want to keep it. Both scenarios currently share the same simplified institutional rules.

In **Laws**, select a healthcare authorization and inspect party support and the projected budget before submitting a vote. After passage, choose an appropriation from 0% to 100%, review party support and vote to change it. Advance days to see administrative rollout, service conditions and group approval change. The figures and party positions are fictional; deficits are automatically financed through debt.

The source-controlled project is this repository's `project.godot`. The earlier project in `Documents/the-global-mandate` is a separate copy; changes in it do not automatically appear here. To compare them without changing either folder, run `python tools/compare_projects.py "C:\Users\Shadow\Documents\the-global-mandate"` from this repository. The comparison ignores generated Godot data, documentation and tooling; it reports differences but never synchronizes files. Review differences before manually copying anything.

The `docs/` directory contains the living development report, initial milestone and partial GPS feature survey. Sessions 6–15 added a small fictional political prototype; see the report for its limits.

If an interrupted save blocks saving or the primary cannot be loaded, see [save recovery](docs/SAVE_RECOVERY.md) before moving or replacing files.

Run the headless checks with a Godot 4.7 executable:

```text
godot --headless --path . --script res://tests/simulation_test.gd
godot --headless --path . --script res://tests/ui_test.gd
godot --headless --path . --script res://tests/integration_test.gd
godot --headless --path . --script res://tests/replay_test.gd
godot --headless --path . --script res://tests/stress_test.gd
godot --headless --path . --script res://tests/world_registry_test.gd
godot --headless --path . --script res://tests/healthcare_test.gd
godot --headless --path . --script res://tests/save_failure_test.gd
godot --headless --path . --script res://tests/diagnostics_test.gd
godot --headless --path . --script res://tests/institution_rules_test.gd
```

For a timeout-protected run of all ten checks, use `python tools/run_tests.py --godot PATH_TO_GODOT_CONSOLE`. The runner requires Python 3 and returns a nonzero exit code if a test times out, fails, or does not report its completion marker.

The `Windows Development` export preset includes scenario, rules and compact world-map JSON data. After importing assets with `godot --headless --path . --editor --quit`, run `python tools/check_export.py --godot PATH_TO_GODOT_CONSOLE` to export a temporary resource pack and run its scenario and map from an empty directory. The check reports failure if Godot reports an error or the packaged data does not load.

On Windows with matching Godot 4.7.2 Windows export templates installed, `python tools/build_windows.py --godot PATH_TO_GODOT_CONSOLE --output artifacts/NEW_EMPTY_FOLDER` produces `TheGlobalMandate.exe` and its accompanying `TheGlobalMandate.pck` and checks headless startup. Keep both files together. It refuses to overwrite an existing build; choose a new output folder. These development builds are ignored by Git. Headless startup does not replace graphical or target-hardware testing.

GitHub Actions runs the Python utility tests, Godot headless checks and resource-pack smoke test on pull requests and pushes to `main`; its Godot 4.7.2 download is checksum-verified. This hosted check does not replace visual playtesting or Windows-specific compatibility testing.

The experimental multi-country registry is headless and not yet integrated into the playable screen. Its synthetic benchmark can be run with `godot --headless --path . --script res://tools/benchmark_registry.gd`; it is not a real-world balance or target-hardware test.

See [performance targets and benchmarks](docs/PERFORMANCE_TARGETS.md) for the playable scheduler, save/load and 720p graphical measurement procedures. Results from other hardware do not validate the provisional low-end target.

Developers can use `simulation/replay_record.gd` to record a versioned scenario, seed and decisions into a JSON-compatible reproduction record. The recorder must own all decision and day-advance calls; it is not yet wired into the game UI. See [session 66](docs/SESSION_66.md) for limitations.

Save files are stored in Godot's user data directory, not in the repository.
