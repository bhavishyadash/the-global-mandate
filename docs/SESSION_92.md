# Session 92: shared country switching

## Delivered

- Added **Review switching main control to selected country** in World Lab while shared-world mode is active. The picker or map chooses a country to inspect; it becomes the main controlled country only after the switch is reviewed and confirmed.
- The review pauses the shared clock and states that no save file is written. Cancelling leaves the same country controlled; accepting clears queued unprocessed time and refreshes main controls for the new live country. A stale world or changed selection rejects the switch.
- Switching keeps both countries, policies, date, bilateral talks, relationship and agreements in the same registry. The main clock remains authoritative. The lab marks the currently controlled country and disables switching to it again. Previous pending main decision reviews are cleared on a successful switch.
- Tests verify view selection versus control, cancellation, stale review rejection, changing control, correct tax effects per country and continuing synchronized diplomacy afterward.

## Limits and next work

This remains an experimental fictional two-country world. Shared-mode identity is not yet stored in saves; load the lab world and explicitly enter shared mode again. The main map does not represent the fictional Coastal Republic, and country switching does not model elections, political authority or consequences. The single-country diplomacy screen is still separate from lab bilateral diplomacy. Target-hardware validation remains open.

Next: safe direct shared-world save/load with controlled-country metadata, a unified diplomacy interface and broader country data with provenance.
