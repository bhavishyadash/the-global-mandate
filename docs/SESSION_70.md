# Session 70: versioned healthcare configuration

## Delivered

Healthcare's three funding options, rollout duration, target coefficient and party support thresholds now come from a versioned, validated rules definition. The default fictional definition is `data/rules/healthcare_v1.json`, included in the exported package. Scenario schema 3 can embed different `healthcare_rules`; scenario versions 1–2 use the default. The Laws tab reads the active options and duration, including after loading or switching scenarios.

Save format 18 persists the exact rules; older saves receive the default definition. Forecast copies preserve active rules. Tests cover invalid definitions, custom funding options and party votes, custom rollout and service effects, saving/loading the rules, and forecast agreement. Values remain fictional and party count, the healthcare algorithm and institutional definitions remain code; this is not the complete data-driven catalog requested by issue #5.
