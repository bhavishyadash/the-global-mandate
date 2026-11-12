# Session 90: main-to-world migration

## Delivered

- Added **Review new lab world from main US sandbox** in World Lab. It is available when the main session is the US sandbox and the date is supported.
- The new world preserves the current US country's full validated snapshot. A fresh fictional Coastal Republic is initialized on the same date, with a partial fiscal period where appropriate. Bilateral relations begin neutral, with no talks or agreements.
- The review pauses both clocks and clearly warns that current lab progress will be replaced. Neither save file is written. Cancelling leaves both worlds unchanged, with clocks paused. Confirmation rejects stale reviews if either world changes before acceptance.
- The candidate two-country world is validated before review and again before replacement. A failed or invalid candidate does not overwrite the existing lab. After migration the main and lab worlds remain independent; later decisions do not synchronize.
- Tests cover scenario eligibility, cancellation, stale main and lab state, invalid candidate rejection, preserved US state, synchronized dates, partial fiscal history and post-migration independence.

## Limits and next work

This is a one-way snapshot migration, not a unified live world. Only the US sandbox is supported as the source; the other country is a fresh fictional test scenario, not a real-country dataset. Existing lab relationships and agreements are deliberately not carried over into the new lab world. Both game worlds and their save slots remain separate; low-end hardware performance is unverified.

Next: build a genuinely shared playable world with a single authoritative clock, explicit player-controlled country, map integration and a migration-safe save architecture, while preserving the existing saves.
