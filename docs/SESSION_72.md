# Session 72: configurable baseline policy rules

## Delivered

The baseline procurement annual cost and implementation step, plus the reporting directive's annual cost and administration target bonus, now come from `data/rules/baseline_policy_v1.json` or a validated scenario-v5 override. Scenario versions 1–4 retain defaults. Save v20 preserves all active healthcare, institution and baseline policy rules; older versions migrate using defaults. Fiscal forecasts clone the active rules and the Government UI displays the configured values.

Tests exercise custom costs, rollout, directive effects, save/load, forecasting, invalid values and old-save migration. Ten Godot suites passed locally. Rule values and behavioral algorithms remain fictional, and the available policy types and two directive IDs remain fixed; an extensible policy authoring catalog is separate future work under issue #42.
