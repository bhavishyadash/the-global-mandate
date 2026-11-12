# Session 106: monthly indicator history

## Delivered

- Each country records an initial indicator sample and one at the beginning of each following month, retaining at most 120 samples. Samples contain the date, cash, debt, national approval, annual revenue and annual balance; values use the existing fictional simulation.
- Save format 23 validates bounded, chronological, finite indicator samples before replacing live state. Older saves load with an empty history and begin recording at the next month; no historical values are invented. Shared-world saves carry each country's independent history through the existing registry.
- The History screen includes a selectable line chart, its actual date and value range, and the most recent 12 numerical samples. The chart auto-scales each selected metric and states that its values are not forecasts.

## Validation and limitations

- Automated checks cover month rollover, save round trip, old-save migration, invalid/future/duplicate history, non-finite values, the 120-sample bound, ten-year save continuity, and UI series selection.
- Visually checked the Windows History screen before and after a month elapsed; the chart and two dated samples appeared. Each chart uses its own vertical range, which is displayed beside it. Values are fictional and sampled monthly, so intervening changes are not shown.
- Future work includes richer comparisons, accessibility and low-end performance validation. The graph is not an empirical economic model.

- Synthetic headless registry benchmark on this machine after the change: 200 fictional countries over 365 days had 4.110 ms p95 and 6.676 ms maximum tick time. This is a bounded synthetic workload, not a target-hardware, rendering, multi-year, or full-game performance guarantee.
