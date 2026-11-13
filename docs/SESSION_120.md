# Session 120: US tax revenue calibration

## Completed
- Anchored the US scenario's income and corporate tax revenue scales to FY 2026 CBO estimates, so tax changes produce meaningful projected budget effects.
- Added scenario-specific tax bases with validation and preserved existing behavior for scenarios and saves without calibration.
- Clarified that the income tax control is a simplified index and that estimates are not a progressive tax model; added scenario, forecast, save and packaged-data coverage.

## Validation
- Full Godot test suite passed, including demographic, political opinion, UI, replay and stress checks.
- Resource pack export and packaged scenario checks passed.

## Limitations
- The 20% income index is a modeling assumption, not an actual federal statutory rate; impacts use a fixed linear base and are not a revenue forecast. Consumption tax remains a prototype assumption. Low-end hardware validation remains open.
- Sources: https://www.cbo.gov/system/files/2026-11/61986-MBR.pdf and https://www.irs.gov/instructions/i1120.
