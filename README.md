# The Global Mandate

A work-in-progress Godot 4.7 prototype for a political and geopolitical simulation. The current scenario and economic figures are fictional; the existing tax, approval and spending calculations are simplified placeholders.

Open `project.godot` in Godot 4.7 and press F5. Use the on-screen controls to advance time, adjust tax and spending, and save or load the prototype scenario.

The prototype starts maximized for readability; the normal window controls can restore or resize it.

The header shows the current fictional scenario, date, cash, annual balance and approval. Income-tax controls and their previews are grouped in **Tax previews**.

**Budget & services** shows current annual expenses as a chart and text table. Enter a category proposal and select **Proposed category** to preview it; use **Apply category** to change the budget. Policy costs and debt interest appear separately from category spending. The available categories and values are fictional.

The **World Map** tab displays offline Natural Earth reference geography. Hover to identify a country or city; click to select, double-click or choose **Focus** to zoom to it. Drag or use arrow keys to pan; use the mouse wheel, plus/minus keys or buttons to zoom. Search by name or choose which cities are visible. **Clear** removes the selection and **Reset map** restores the world view. The optional **sandbox availability** layer shows available and active sandboxes; all other countries remain reference-only. Select the US and choose **Start US sandbox** to start its optional scenario after confirmation. Its population, finances, parties and behavior are fictional test values, not US data. While active, the US panel displays live sandbox values and a Government shortcut. Cities remain reference geography. See [map data and limitations](data/map/README.md).

The Overview tab offers three fictional starting scenarios. Select one and choose **Start selected scenario**; confirming replaces the current session, so save first if you want to keep it. They currently share the same simplified institutional rules.

In **Laws**, search the selected category and choose an implemented law. Healthcare and Finance currently contain one law each; the other category tabs are placeholders. Select a healthcare authorization and review party support and the projected budget before submitting a vote. After passage, choose an appropriation from 0% to 100% and review the vote. Advance days to see rollout, service conditions and approval change. The figures and party positions are fictional; deficits are automatically financed through debt.

The **Executive Orders** tab contains two fictional directive options with automatic court review under prototype rules. Submitting a law or directive opens a review first; canceling does not submit it. Opening a review pauses a running game and leaves it paused. These fictional institutions are not a model of US constitutional procedure.

**World Lab** is a separate experimental world with two fictional countries. Its independent clock can run at different speeds or advance 1 or 30 days; the 30-day advance can be cancelled. You can select a country, change its income tax and negotiate fictional dialogue or cooperation. Cooperation requires sufficient relations and cash, charges each country once and expires after 365 days. Its own map lets you select the US sandbox; the fictional Coastal Republic has no map location. Lab save/load uses a separate slot, and loading the primary or backup confirms before replacing lab progress. Opening a load prompt pauses the lab and clears queued days, even if cancelled. The lab continues running on other tabs until paused; the main game's clock, map, policies and save are independent. See [session 88](docs/SESSION_88.md).

To use a lab country in the main single-country interface, choose **Review copy of selected country to main game** in World Lab. The review pauses both clocks and requires confirmation before replacing the current main session; save the main game first if you want to keep it. Neither save file is written by the copy. Lab-level relationships and agreements are not transferred, and the worlds do not synchronize afterward. See [session 89](docs/SESSION_89.md).

To carry the current main US sandbox into a fresh two-country lab instead, choose **Review new lab world from main US sandbox** in World Lab. It copies the current US state and starts a fresh fictional Coastal Republic on the same date. Review warns before replacing lab progress; neither save file is written. The resulting worlds remain separate. See [session 90](docs/SESSION_90.md).

For an experimental shared world, select a World Lab country and choose **Review playing selected country in shared world**. After confirmation, the main controls change that live lab country and the main clock advances both countries. Main **Save shared world** uses the separate lab save slot; loading and starting a different scenario are disabled until you choose **Leave shared world and keep country copy** in World Lab. Neither entry nor exit writes a save. The single-country fiscal forecasts are unavailable in shared mode because they do not include lab diplomacy. Lab country selection does not automatically change the main controlled country. See [session 91](docs/SESSION_91.md).

The **Government** tab also offers a separate US-inspired healthcare bill demonstration. Choose a proposal, introduce it, vote in the House and Senate, then sign or veto it. After a veto, both chambers may vote on an override. The screen shows available actions, expected votes, projected costs and recorded results. The seats, party control and vote support are fictional and all members are assumed to vote. Signing or overriding changes the existing healthcare policy. The older single-chamber actions remain available separately. This demonstration omits important US procedures; see [session 80](docs/SESSION_80.md) and [session 81](docs/SESSION_81.md).

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
godot --headless --path . --script res://tests/budget_breakdown_test.gd
```

For a timeout-protected run of all twelve checks, use `python tools/run_tests.py --godot PATH_TO_GODOT_CONSOLE`. The runner requires Python 3 and returns a nonzero exit code if a test times out, fails, or does not report its completion marker.

The `Windows Development` export preset includes scenario, rules and compact world-map JSON data. After importing assets with `godot --headless --path . --editor --quit`, run `python tools/check_export.py --godot PATH_TO_GODOT_CONSOLE` to export a temporary resource pack and run its scenario and map from an empty directory. The check reports failure if Godot reports an error or the packaged data does not load.

On Windows with matching Godot 4.7.2 Windows export templates installed, `python tools/build_windows.py --godot PATH_TO_GODOT_CONSOLE --output artifacts/NEW_EMPTY_FOLDER` produces `TheGlobalMandate.exe` and its accompanying `TheGlobalMandate.pck` and checks headless startup. Keep both files together. It refuses to overwrite an existing build; choose a new output folder. These development builds are ignored by Git. Headless startup does not replace graphical or target-hardware testing.

GitHub Actions runs the Python utility tests, Godot headless checks and resource-pack smoke test on pull requests and pushes to `main`; its Godot 4.7.2 download is checksum-verified. This hosted check does not replace visual playtesting or Windows-specific compatibility testing.

The experimental multi-country registry is exposed separately in World Lab, not integrated into the main game or map. Its synthetic benchmark can be run with `godot --headless --path . --script res://tools/benchmark_registry.gd`; it is not a real-world balance or target-hardware test.

See [performance targets and benchmarks](docs/PERFORMANCE_TARGETS.md) for the playable scheduler, save/load and 720p graphical measurement procedures. Results from other hardware do not validate the provisional low-end target.

Developers can use `simulation/replay_record.gd` to record a versioned scenario, seed and decisions into a JSON-compatible reproduction record. The recorder must own all decision and day-advance calls; it is not yet wired into the game UI. See [session 66](docs/SESSION_66.md) for limitations.

Save files are stored in Godot's user data directory, not in the repository.
