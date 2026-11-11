# Session 63: healthcare appropriations

## Delivered

Healthcare laws authorize a yearly ceiling; the player separately chooses 0%, 25%, 50%, 75% or 100% of it in the Laws tab. A new law starts at 100%; an amendment preserves the existing percentage. The chosen share determines actual annual policy cost, rollout speed and the size of the health target bonus. Zero funding pauses rollout and removes the target bonus; existing service condition and group approval respond gradually. Repeal resets the share for a future law.

The screen previews the annual balance under the selected appropriation and displays authorized and actual spending. Changes take effect on subsequent simulated days. The budget model still borrows automatically when spending exceeds available revenue and cash. This appropriation is a direct player decision, not yet a separately voted annual budget, and the simple linear response is illustrative rather than a real healthcare model.

Save format 16 persists the appropriation. Version 15 migrates to 100%, preserving its previous spending behavior; older versions remain supported. Forecasts copy the choice. New tests cover partial and zero funding, invalid values, preview, save and migration, and the UI action; the existing suites cover the rest of the simulation.

## Open work

Legislative appropriations, periodic budget renewal, earmarked revenue, stronger funding constraints, researched effects and country-specific institutions remain future work. Low-end target-hardware validation remains open.
