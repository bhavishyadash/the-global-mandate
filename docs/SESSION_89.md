# Session 89: lab-to-main handoff

## Delivered

- Added **Review copy of selected country to main game** in World Lab. The player can copy either lab country's current single-country state into the main session after reviewing the country and date.
- The review pauses both clocks and warns that the current main session will be replaced. It does not write or overwrite either save file. Cancelling keeps both worlds unchanged, although both clocks remain paused.
- A candidate is validated before the review. Confirmation rejects the copy if either world or the selected country changed, or if a clock resumed or a lab batch began. A successful import refreshes the main controls and opens Overview, with the main game paused.
- The lab remains an independent multi-country world. The copy includes the selected country's current cash, fiscal ledger, policies, population, events and date, but not lab-level bilateral relationships, pending talks or agreements. Later changes do not synchronize in either direction.
- Tests cover cancellation, stale lab and main states, successful copying, refreshed identity and time, and independence after the copy. The existing save paths remain separate and unchanged.

## Limits and next work

This is an explicit one-way snapshot copy, not a unified multi-country game or an ongoing synchronization mechanism. A copied country may contain historic event text about lab cooperation even though the lab agreement itself is not transferred. Data is fictional, and this feature does not automatically preserve unsaved main progress; the player must save first if desired. Low-end hardware testing remains open.

Next, develop a unified world session with a single authoritative clock, explicit player-controlled country, shared diplomacy and a migration-safe save format. Preserve the existing independent lab and single-country saves until the integrated workflow is tested.
