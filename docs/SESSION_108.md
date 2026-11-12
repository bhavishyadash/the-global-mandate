# Session 108: population trend history

## Delivered

- Monthly indicator samples now record population, and the History chart offers a Population series with whole-person values and a visible range.
- Save format 25 supports mixed histories from older saves: prior samples without population remain unchanged, while new monthly samples record it. The chart omits unavailable older population values and explains the gap rather than inventing them.
- Validation rejects negative, fractional or non-finite population values and a missing sample after population recording has begun. Other indicator series and demographic rules are unchanged.

## Validation and limitations

- Tests cover old format-24 history, the first new monthly population sample, mixed-history round trips, invalid population and gaps, long-run save continuity, and the no-data UI state.
- Population remains the fictional aggregate model from session 107; there are no age cohorts, geographic breakdowns or policy effects on birth, death or migration rates. Values are monthly snapshots, not estimates of intervening daily changes.
