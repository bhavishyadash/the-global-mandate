# Session 32 — public services and population response

Related to issues #12, #18, #19, #20, #45 and #48. Build a connected, explicitly fictional service layer for the five budget categories: delayed service-condition changes, group-specific approval contributions, clear indicators and save migration. Verify baseline stability, under- and over-funding, group differences, save/load and integration with tax decisions. These broad issues remain open until their complete acceptance criteria are met.

## Result

- Each category has a 0–100 fictional service indicator. Its long-run target scales with spending per resident relative to a fictional baseline and is clamped to 0–100; each day the indicator moves 1/180 of the gap toward the target. These coefficients are design placeholders, not empirical measurements.
- Mean service condition contributes differently to the three test groups' approval: sensitivities are 0.35, 0.25 and 0.15 approval points per point away from 50. Tax-driven raw approval and the service contribution remain separate, and visible approval remains bounded.
- The UI shows each service condition and target, plus a projected target when a category amount is selected. Budget previews remain fiscal snapshots; they are not forecasts of future approval.
- Version-5 saves store service conditions and group contributions, validating their consistency. Older saves initialize services at 50 and contributions at zero; they do not reconstruct historical conditions.
- Local simulation, UI and integrated checks passed, including baseline stability, spending increases/cuts, delayed group responses, tax previews after service effects, v4 migration, invalid service data rejection, and save/load continuation.

There is no modeling yet of service quality by region, staffing, capital, inflation, private services, individual demographics, actual surveys or empirically calibrated reactions. Visual playtesting remains outstanding.
