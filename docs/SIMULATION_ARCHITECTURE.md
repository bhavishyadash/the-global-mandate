# Simulation architecture: prototype baseline

This documents implemented behavior as of session 17, not the final game design. Country values and policy coefficients are fictional placeholders. Country-specific systems, stochastic behavior, actual economic dynamics and legal constraints are not implemented.

## Ownership and boundaries

- `simulation/world.gd` owns the date, country dictionary, bounded text event history, daily financial update, policy entry points and save/load orchestration.
- `simulation/politics.gd` owns three fictional population groups, three parties, seat counts, procurement state, implementation progress and illustrative election count.
- `ui/main.gd` displays state, provides player controls, schedules simulation days and calls world methods. The engine is usable without the graphical UI; the headless simulation tests instantiate it directly.
- The model is mutable in memory: dictionaries and arrays are not yet encapsulated. Only operations called through the existing methods are validated. This is a limitation, not a guarantee that arbitrary state writes are safe.

## Data and units

| Field | Unit / meaning |
|---|---|
| date | Gregorian year, month, day; initial 2026-01-01 |
| population | Whole people; currently fixed at 10 million |
| treasury | Fictional USD stock; may be negative; debt is not separately modeled |
| annual revenue and spending | Fictional USD per year; held fixed until changed by a decision |
| income tax | Fraction from 0 to 0.60; flat placeholder, not a real tax system |
| group share | Fraction of the total population; group shares sum to one |
| group and national approval | Percentage points from 0 to 100; national approval is a weighted average |
| seats | Integers totaling 100 in the test legislature |
| procurement progress | Integer from 0 to 100, advanced one point per simulated day |

## One simulated day

`World.advance_day` adds annual revenue minus annual spending, divided by the number of days in the current year, to the treasury. If the balance crosses below zero, it records a warning. It then advances procurement implementation and records completion, if applicable. Finally it advances the Gregorian calendar. Events generated during the update use the starting date of that day.

The UI accumulates real time at the selected speed and calls `advance_day` once per simulated day. It processes at most 30 days per frame, preserving any remaining backlog. It does not run the simulation while paused, though the single-day button deliberately advances it regardless of pause state. Loading clears the UI's elapsed backlog.

## Decisions and consequences

- Income tax accepts a finite fraction between 0 and 0.60. Revenue changes using a fixed fictional $2 billion base; each group changes an internal approval value by the rate change multiplied by its fictional sensitivity. Displayed approval is clamped to 0–100 without discarding the internal excess. National approval is recalculated. Effects are immediate.
- Spending accepts a finite annual amount from $0 to $10 billion and updates the budget and event log. It does not currently affect services, employment or approval.
- Procurement passes only once and only if supporting parties hold more than 50 seats. It starts a 100-day implementation counter; it has no economic effect yet.
- A test election occurs on January 1 every four years beginning in 2030. It maps national approval to the government party's seats, gives the remaining seats to the opposition and sets the third party to zero. The schedule is derived from the date, and older saves do not retroactively simulate missed elections. It is not a realistic electoral system.
- The event log holds at most 200 newest-first text strings. It is not yet a structured, replayable event system.

## Persistence

Version 3 JSON saves include date, country, events and political state, including internal approval. The loader validates expected fields and ranges before replacing live state. Version 1 migration initializes each group with the old national approval; version 2 migration initializes internal approval from each visible group approval. Previously clipped history cannot be recovered. A temporary file and previous-save backup are used; the UI exposes save, load and load backup, and pauses after loading. An invalid primary is preserved as `.invalid` instead of replacing the good backup. This is not a general transaction or full crash-recovery guarantee.

During valid-primary rotation, an older backup is temporarily retained as `.bak.previous`; the code attempts rollback if a rename fails. An existing `.bak.previous` blocks further rotation for manual recovery. Rename failure and crash scenarios are not yet exhaustively tested.

## Quality and future contracts

Headless checks cover dates, accounting, tax reactions, spending, votes, policy progress, election seat totals, save migration and UI actions. They do not establish empirical accuracy. Future work should introduce typed/versioned scenario definitions, explicit command results and structured events, deterministic random state, clearer module interfaces, atomic migration tests and cross-system invariant checks. Any new model needs its own documented units, assumptions, data provenance and test scenarios.
