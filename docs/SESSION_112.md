# Session 112: Federal budget accounting foundation

## Target
Introduce a reusable, validated federal budget accounting component backed by the official FY2025 reference, with explicit net offsets and interest already included in function outlays. Exercise adjustment previews and reconciliation without mutating the fictional sandbox. Related: #159, #10, #39.

## Scope
A standalone accounting foundation is not yet a calibrated playable fiscal simulation. Existing saves, tax rates, service effects and forecast remain unchanged until integrated deliberately.

## Completed
- Added a non-mutating federal accounting preview and controls to the US Reference tab. Changes are in whole millions, matching Treasury source precision.
- Anchored totals to Treasury's reported outlays; the $1 million difference caused by rounded component figures remains unallocated. Net interest is already in the reported total, and negative offset functions cannot be edited as ordinary positive spending.
- A preview changes one nonnegative function, holds receipts constant and recalculates total outlays and the deficit (negative deficit means surplus). It does not model behavioral responses or affect the live game.
- Tests cover historical reconciliation, changed outlays and deficit, source immutability, invalid inputs and UI interaction.

## Remaining
- A playable federal-scale model, dynamic tax receipts, legal budget process, debt mechanics, economic reactions and integration with save games remain open under #159 and related issues. All existing sandbox gameplay remains fictional.
