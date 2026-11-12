# Session 105: fiscal forecast horizons

## Delivered

- Added 30-, 90-, 180- and 365-day horizons for the fiscal forecast and proposal comparison. Changing the horizon marks existing results out of date. The default remains 365 days.
- Comparisons now show current and proposed cash, debt and approval with proposal-minus-current changes, plus an end-of-day zero-cash warning for each path.
- Forecasts remain detached from live state and use the existing fictional single-country or shared-world model as appropriate. The cash warning describes end-of-day observations, not intraday cash movements.

## Validation and limitations

- UI checks cover horizon switching, stale invalidation, 30- and 365-day output, and shared-world and single-country forecasts. Existing tests continue to compare simulated results with independently advanced worlds.
- These remain deterministic prototype projections, not realistic economic forecasts. Additional time horizons, uncertainty, policy feedback and low-end hardware performance remain future work.
