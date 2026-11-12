# Session 103: selected-category budget comparison

## Delivered

- The fiscal forecast accepts a single validated category-spending proposal and simulates it on a detached world. Other category allocations stay unchanged. A request containing both a total reset and category change is rejected as ambiguous.
- The Budget & services comparison now offers either a total-budget reset or the selected category proposal, combined with entered tax values. It describes which mode is being modeled, and changing the category, amount or comparison mode marks the result out of date.
- This is a fictional 365-day forecast, not a promise or a realistic economic model. It does not apply the proposed decisions. Shared-world comparisons remain disabled because bilateral events are not included.

## Validation and limitations

- Tests compare the category projection with an independently advanced world, verify live-state isolation, and reject invalid categories, non-finite amounts, excessive spending and ambiguous requests. UI checks cover both modes and stale invalidation.
- The forecast does not model future player choices, shocks, employment or broader economic feedback. Low-end hardware and real-world calibration remain open.
