# Simulation architecture: prototype baseline

This documents the implemented prototype through session 64, not the final game design. Country values and policy coefficients are fictional placeholders. Country-specific systems, stochastic gameplay, actual economic dynamics and realistic legal constraints are not implemented.

## Ownership and boundaries

- `simulation/world.gd` owns the date, country dictionary, bounded categorized event history, seeded random state, daily financial update, policy entry points and save/load orchestration.
- `simulation/politics.gd` owns three fictional population groups, three parties, seat counts, procurement state, implementation progress and illustrative election count.
- `simulation/services.gd` owns fictional service conditions, spending-per-resident targets and group service contributions.
- `simulation/healthcare.gd` owns the fictional law's authorization, appropriation, party positions and administrative rollout. The world connects its actual cost and target bonus to the fiscal and service models. Save format 16 persists the appropriation; version 15 migrates to full funding and earlier saves start with the law inactive.
- Healthcare appropriation changes use the current legislature and a fictional per-party support rule; a majority passes the change immediately. Initial enactment remains fully funded. Rejected proposals retain their previous funding and produce an event.
- `simulation/institutions.gd` owns a fictional single-directive lifecycle, fixed authority cases, court outcomes and agency implementation progress.
- `simulation/diplomacy.gd` owns two fictional partners, talks and agreements; `simulation/scenario.gd` validates versioned single-country scenario data.
- `simulation/decisions.gd` validates UI command requests and returns explicit results; `simulation/replay.gd` runs ordered commands on an isolated world.
- `simulation/world_registry.gd` is an experimental headless multi-country layer with synchronized clocks, bilateral dialogue and separately versioned world snapshots/saves. It is not yet connected to the playable UI or its older single-country diplomacy model.
- `ui/main.gd` displays state, provides player controls, schedules simulation days and calls world methods. The engine is usable without the graphical UI; the headless simulation tests instantiate it directly.
- The model is mutable in memory: dictionaries and arrays are not yet encapsulated. Only operations called through the existing methods are validated. This is a limitation, not a guarantee that arbitrary state writes are safe.

## Data and units

| Field | Unit / meaning |
|---|---|
| date | Gregorian year, month, day; initial 2026-01-01 |
| population | Whole people; initial values are scenario-defined and do not yet change over time |
| treasury and debt | Nonnegative fictional USD stocks. Negative legacy treasury migrates to debt. |
| annual revenue and spending | Fictional USD per year; spending is split into five categories and total changes reset them to default shares |
| income tax | Fraction from 0 to 0.60; flat placeholder, not a real tax system |
| consumption and corporate tax | Fractions from 0 to 0.60; fictional fixed taxable bases of $1.5 billion and $1 billion respectively |
| group share | Fraction of the total population; group shares sum to one |
| group and national approval | Percentage points from 0 to 100; national approval is a weighted average |
| seats | Integers totaling 100 in the test legislature |
| procurement progress | Integer from 0 to 100, advanced one point per simulated day |

## One simulated day

`World.advance_day` calculates annual revenue minus category spending, active policy costs and 3% of outstanding debt, divided by days in the current year. Deficits use cash then increase debt; surpluses repay debt then add cash. It updates service conditions and the three groups' service-related approval contributions, then advances procurement implementation and records completion, if applicable. Finally it advances the Gregorian calendar. Events generated during the update use the starting date of that day. All rates are simplified assumptions.

The UI accumulates real time at the selected speed and calls `advance_day` once per simulated day. It processes at most 30 days per frame, preserving any remaining backlog. It does not run the simulation while paused, though the single-day button deliberately advances it regardless of pause state. Loading clears the UI's elapsed backlog.

## Decisions and consequences

- Income tax accepts a finite fraction between 0 and 0.60. Revenue changes using a fixed fictional $2 billion base; each group changes an internal approval value by the rate change multiplied by its fictional sensitivity. Displayed approval is clamped to 0–100 without discarding the internal excess. National approval is recalculated. Effects are immediate.
- Consumption and corporate tax use separate fixed fictional bases and separate group response coefficients. They provide non-mutating previews and immediate changes to revenue and tax-related approval; economic incidence, tax avoidance and behavioral feedback are not modeled.
- Total spending accepts a finite annual amount from $0 to $10 billion and resets category shares; individual categories can also be changed within the same total limit. Fiscal previews are non-mutating. Per-resident category funding gradually changes service conditions and contributes to group approval using fictional coefficients; employment and wider economic effects are not modeled.
- Procurement passes only once and only if supporting parties hold more than 50 seats. It starts a 100-day implementation counter; once complete, a fictional $10 million annual policy cost reduces the projected budget balance and accrues starting the next simulated day. Existing saves with completed implementation acquire this cost. The policy has no modeled procurement benefit or wider economic effect.
- A repeal vote succeeds if parties opposing the policy hold more than 50 seats. It clears implementation and stops future costs; the policy may be proposed again. This rule is a placeholder for legislative procedure.
- One fictional executive directive may be active. The reporting case is upheld on day 30 and implemented on day 60; once implemented, it costs $5 million annually and raises the Administration service target by 10 until revoked. The spending-limit override is enjoined on day 10 and struck down on day 30. These deterministic scenario rules are fictional and do not represent actual law.
- A test election occurs on January 1 every four years beginning in 2030. It maps national approval to government seats and splits remaining seats between the other parties proportionally to their prior seat counts, or evenly if neither held seats. The schedule is derived from the date, and older saves do not retroactively simulate missed elections. It is not a realistic electoral system; a zero-seat party cannot recover unless both other parties had zero seats.
- Diplomacy has two fictional partners. Dialogue and cooperation negotiations last 30 days, with deterministic acceptance and a 90-day cooldown. Accepted cooperation creates or renews a 365-day agreement, with a fictional annual $20 million partner contribution and $10 million government cost. Early termination reduces relations by five points. There is no modeled trade, military, treaty law or diplomatic AI.
- The event log holds at most 200 newest-first text strings with matching categorized dated records. Old text-only saves migrate with unknown structured date/category. Records do not yet include structured actors or causal payloads; the log is not an event-sourcing system.

## Persistence

Version 14 JSON saves include scenario/country IDs, seeded random state, categorized event records, current and previous fiscal records, and diplomatic relationships, talks and agreements, alongside date, country, politics, debt, spending categories, services, taxes and institutions. Before v12, IDs migrate to the default fictional scenario; before v13, event text migrates as legacy records; before v14, the unused random generator starts at the documented default. Saves before v8 start a partial ledger, before v9 receive default fictional diplomatic relations, v9 active talks migrate as dialogue, and before v11 start with no agreements. Older already-implemented reporting directives acquire current effects and existing v11 agreements acquire the partner contribution, without rewriting fiscal history. Version 1 migration initializes group approval from national approval; version 2 initializes raw approval from visible approval. Previously clipped history cannot be recovered. Versions 1–3 use default spending shares and convert negative treasury into debt; versions 1–4 initialize service conditions at 50 and service contributions at zero; versions 1–5 initialize additional tax rates at zero; versions 1–6 start without an active directive. A new temporary save is validated before rotating the primary and backup. An invalid primary is preserved as `.invalid` instead of replacing the good backup. These measures are not a general transaction or full crash-recovery guarantee.

During valid-primary rotation, an older backup is temporarily retained as `.bak.previous`; the code attempts rollback if a rename fails. An existing `.bak.previous` blocks further rotation for manual recovery. Rename failure and crash scenarios are not yet exhaustively tested.

## Quality and future contracts

Headless checks cover dates, accounting, tax reactions, spending, votes, policy progress, election seat totals, save migration, UI actions, deterministic replay and a ten-year stress scenario. They do not establish empirical accuracy. Scenario schema v2 defines one country's initial state; existing structures still assume three groups and parties and fixed partner IDs. The seeded generator is persisted but unused by current gameplay. Future work needs stronger encapsulation, richer event payloads, filesystem fault injection, coupled-world and graphical tests. Any new model needs its own documented units, assumptions, data provenance and test scenarios.
