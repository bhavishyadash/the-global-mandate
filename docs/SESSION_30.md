# Session 30 — integrated policy scenario

Related to issue #48. Add a reproducible end-to-end test that exercises tax decisions, procurement adoption, implementation costs, saving, a scheduled election, repeal and budget consequences together. Integrate it into the bounded local and GitHub test runner. Broader simulation validation and realistic gameplay remain future work.

## Result

Added a headless integrated scenario that increases tax, passes the procurement policy, waits for its cost, saves and reloads, advances to the 2030 election, repeals the policy and verifies the budget and subsequent save. The test refuses to overwrite an existing test-save file. The bounded runner now invokes all three Godot suites; all passed locally. This verifies consistency of the fictional prototype, not real-world accuracy or visual usability.
