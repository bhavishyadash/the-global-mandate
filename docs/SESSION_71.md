# Session 71: versioned institutional rules

## Delivered

Fictional directive names, descriptions and authority, plus injunction, review and implementation timings, are now validated institutional rules in `data/rules/institutions_v1.json`. Scenario v4 embeds these alongside healthcare rules; v1–v3 use the default institution definition. Changing authority affects whether a directive is suspended and struck down or upheld and implemented. The Government tab reflects the active definitions and timings.

Save format 19 persists the rules, and forecasts clone them. Tests invert the two directives' fictional authority, exercise custom timing, save/load during an injunction, forecast and invalid-rule rejection, and load a v18 save with defaults. Ten Godot suites pass locally. The two directive IDs and their reporting/override effects are still fixed code, as are procurement rules and other modeled policies. This remains a prototype, not an accurate country-specific court model.
