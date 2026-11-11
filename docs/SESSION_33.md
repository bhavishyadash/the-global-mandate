# Session 33 — additional tax instruments

Related to issues #10, #11, #13, #20, #45 and #48. Extend the fictional revenue model with separately adjustable consumption and corporate taxes, fixed illustrative tax bases, group-specific approval effects, revenue breakdowns, non-mutating previews, validated save migration and integrated tests. The broader tax, household and political models remain open; fixed bases and coefficients are not real-world calibration.

## Result

- Added consumption and corporate tax rates from 0–60%, in addition to the existing income tax. Fictional fixed annual bases are $1.5 billion and $1 billion respectively; their revenue is shown separately alongside income-tax and residual other revenue.
- Each instrument changes the groups' unclamped tax-related approval using distinct fictional sensitivities; service effects remain separate. The UI previews revenue and group approval without mutating state before applying a decision.
- Version-6 saves persist and validate both rates; older saves migrate with both rates at zero without changing their existing revenue or opinion. The underlying taxable bases do not change with consumption, profits, avoidance or the economy.
- All three local Godot suites passed, covering previews, invalid input, differing group responses, both revenue calculations, v5 migration, v6 save/load, invalid tax data rejection and the UI path. Visual playtesting and real-world calibration remain outstanding.
