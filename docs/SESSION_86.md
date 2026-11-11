# Session 86: world lab map and recovery

## Delivered

- Added an independent geographic map inside World Lab. Selecting the US or a US city chooses the lab's US sandbox, while selecting other real countries only identifies reference geography and does not change the selected lab country. Selecting the fictional Coastal Republic in the picker clears the mapped selection because it has no location.
- Added pan and zoom through the existing map control, plus zoom and reset buttons. The lab map is a separate view and does not change the main game's map, country or simulation state.
- Added **Load lab backup** alongside the primary load. Both require in-game confirmation and validate the candidate world before replacing the lab. Cancelling leaves the world untouched; the main game's save slot is never used.
- Tests cover clicking mapped and unmapped locations, keeping the lab country unchanged for reference-only countries, backup confirmation/cancellation and restoring an earlier lab state from its actual `.bak` file.

## Limits and next work

Only the US sandbox has a map location, and all its figures are fictional. Coastal Republic has no claimed real-world position. The lab is still an independent two-country experiment with a separate manual clock, decisions and save; it is not yet the main playable multi-country world. The map uses simplified Natural Earth geography. No new real-country datasets, real diplomacy or city simulation were introduced. Low-end hardware validation remains open.

Next: design a unified country-control and world-clock workflow that preserves both the main-game and lab saves, then add a reversible migration and broader playtesting before replacing existing single-country workflows.
