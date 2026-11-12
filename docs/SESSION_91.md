# Session 91: shared world prototype

## Delivered

- Added an opt-in **shared world** entry from the selected World Lab country. A review pauses both clocks, identifies the country, warns that the current main session will be replaced and explains save behavior. Cancellation leaves both states intact; confirmation rejects stale changes in either world or a changed selection.
- In shared mode the main controls operate on the selected live country in the lab registry. The main clock advances both lab countries and their bilateral talks together. The lab's independent clock is disabled, so it cannot double-advance the world. Selecting another country inside the lab does not change which country the main game controls.
- **Save shared world** writes the separate experimental world slot. Main and lab load controls and starting a new main scenario are disabled while shared, to avoid replacing a live country object. Leave shared world first to use those actions. No save is written on entry or exit; queued, unprocessed clock time is cleared when entering or leaving.
- Leaving creates a validated independent copy of the controlled country for the main interface, leaving the lab world intact and both clocks paused. The main country's copied history remains, but lab-level relationships, talks and agreements remain with the lab.
- Disabled single-country fiscal forecasting/comparison in shared mode because it does not model upcoming bilateral events. The existing single-country Diplomacy tab still represents its own fictional partner model; bilateral lab negotiations are accessed in World Lab.
- Tests cover cancellation, stale entry, shared country identity, synchronized days, policy changes in both interfaces, guarded load/new-scenario paths, forecast limitation and detaching without further lab changes.

## Limits and next work

This is an experimental two-country shared-state prototype, not the final world simulation. Both countries, policy values and diplomacy are fictional. The currently controlled country cannot be changed without leaving and re-entering; the main map does not show all lab countries, and the fictional Coastal Republic has no real location. Shared-mode selection itself is not saved; loading the lab later and re-entering restores shared play. Existing single-country and lab saves remain separate. Low-end hardware validation remains open.

Next: add safe loading directly into shared mode, controlled-country switching, real map-to-world coverage and a unified diplomacy interface with migration-safe saves and meaningful playtesting.
