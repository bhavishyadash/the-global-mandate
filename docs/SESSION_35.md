# Session 35: Fiscal accounting history

## Delivered

- Record daily collected revenue, category spending, policy costs and debt interest; separately record borrowing and repayment. Calculations use the same fictional annual rates as the budget, including leap-year daily divisors.
- Show current-year recorded totals and the previous year's totals alongside projections. A new year archives the current record and starts a new one.
- Version 8 saves preserve both periods and validate their fields. Version 1–7 saves start a partial current-year record: prior transactions cannot be reconstructed, and the interface labels this explicitly.
- Simulation checks cover annual rollover and totals, deficit borrowing, interest, repayment, the cash/debt accounting identity, save/load continuity, malformed history and old-save migration. UI and integrated scenario checks also run.

## Limitations and next work

This is an aggregate ledger, not a transaction journal or a historical database: it retains only the current and preceding calendar year. Existing financial assumptions are illustrative, not calibrated to real countries. It does not model payment timing, debt markets, bonds, defaults, inflation, or budget execution delays. Manual visual testing of the growing interface remains important.
