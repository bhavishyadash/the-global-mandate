# Geopolitical Simulator — Living Development Report

**Working title:** Geopolitical Simulator (final name undecided)  
**Report started:** 10 November 2026  
**Development stage:** Pre-production / discovery  
**Current milestone:** M1 — Core technical framework (M0 hardware and scope decisions remain open)  
**Report status:** Initial baseline; update throughout development  
**Owner / creative director:** You  
**Implementation and technical reporting:** Codex, working with your direction

> This is a living, editable Markdown document. You can open and change it in any text editor, GitHub, VS Code or the Codex app. Tables and simple status bars make progress visible without requiring Excel or Word. Update this file after meaningful work; add dated history entries instead of rewriting the past. A proposed target is not a completed feature.

## 1. At a glance

| Area | Status | What we know / need |
|---|---|---|
| Vision | Defined at a high level | Modern, highly detailed political simulation; diplomacy before war |
| Godot project | Located and updated | `C:\Users\Shadow\Documents\the-global-mandate`; Godot 4.7 project |
| Simulation | Framework prototype in original project | Gregorian calendar, fictional budget, tax decision and single-slot save/load |
| World data | Not started | Research sources, licensing, dates, gaps and uncertainty |
| Political systems | Early fictional prototype | Three population groups, a three-party legislature, one test law and a simplified election; real country institutions remain future work |
| Economy | Concept stage | Budget, sectors, households, employment, prices and trade |
| Diplomacy and military | Concept stage | Negotiations, escalation and strategic conflict; optional military models |
| GPS feature inventory | Initial partial survey | Installed manual reviewed; actual menus and formulas remain incomplete |
| Visual design | Not decided | Map style, UI references and low-end performance target needed |
| Playable build | Early framework prototype in original project | Headless scene launch verified; visual interaction not yet verified |
| Release date and budget | Not set | Establish targets after project inspection and first benchmarks |

**Progress by milestone** — bars show verified completion, not effort spent. Initial percentages are approximate tracking placeholders, not a schedule forecast.

```text
M0  Project foundation and scope       [######----]  60%  IN PROGRESS
M1  Core technical framework           [####------]  40%  IN PROGRESS
M2  World state and time               [----------]   0%  NOT STARTED
M3  First playable policy loop         [----------]   0%  NOT STARTED
M4  Economy and population foundation  [----------]   0%  NOT STARTED
M5  Institutions and domestic politics[----------]   0%  NOT STARTED
M6  Diplomacy and international system [----------]   0%  NOT STARTED
M7  Military and conflict             [----------]   0%  NOT STARTED
M8  Global content and country depth   [----------]   0%  NOT STARTED
M9  Playtesting and release readiness  [----------]   0%  NOT STARTED
```

The order is a dependency guide, not a waterfall: data, UI, testing, performance and research continue throughout. Features can be expanded across milestones once their foundation is usable.

## 2. Vision and design principles

Create a modern geopolitical game centered on governing: politics, law, economic management, society and international relationships. The player should feel the consequences of decisions through people, institutions and a changing world.

### Agreed direction

- **Political simulation first.** War is one part of geopolitics, not the default activity. Countries should consider diplomacy, bargaining, pressure, alliances and escalation risks.
- **Country-specific systems.** The same policy can encounter different authority, procedures, institutions and opposition depending on the country. US executive orders are one example.
- **Distinct societies with internal diversity.** Population groups have different interests, values and political experiences; private beliefs and public expression can diverge. Starting assumptions should be sourced and updated over time.
- **Realistic consequences with uncertainty.** Implemented policies affect the world through explainable mechanisms and delays; our models are approximations, not predictions or claims of perfect knowledge.
- **Accessible performance.** Optional military 3D models and configurable detail; symbols/counters when 3D visuals are disabled. Simulation performance is measured separately from graphics.
- **Original, moddable content.** Base-game people and portraits are fictional by current direction. Data-driven modding is planned. Legal implications of real-person content and promotion need independent review before distribution.
- **Quality is part of each milestone.** A feature is not complete because a button exists: it must work, explain results, save correctly and be tested.

### Open design decisions

| Decision | Current assumption | Owner / next step |
|---|---|---|
| Game name | Undecided | Director chooses later |
| Godot / C# | Recommended, not confirmed | Inspect actual project and tooling before committing |
| Map | Undecided: flat, globe or hybrid | Director chooses after reviewing prototypes |
| Initial playable geography | Fictional US-style test scenario proposed | Confirm during M0; world expansion follows |
| Real-time scale and pause | Pausable simulation proposed | Prototype and test |
| Military depth | Strategic-first; detailed mechanics undecided | Director defines desired control |
| Target hardware | Not specified | Set baseline PC and acceptable frame / simulation speeds in M0–M1 |
| Distribution, pricing, multiplayer | Not decided | Decide when supported by scope and testing |

## 3. Development layers

```text
Project and tools
       ↓
Core framework: time, state, decisions, events, save/load, testing
       ↓
One playable loop: propose → resolve → implement → react → explain
       ↓
Economy + population + institutions
       ↓
Country variation + diplomacy + military + world data
       ↓
Content breadth + balancing + optimization + release
```

The graphical layer displays the world and sends player decisions. The simulation owns the rules and world state, and should be runnable without the graphical interface. Country data and policy definitions feed the simulation through versioned, documented formats. This separation is a design goal to validate in the actual project.

## 4. Milestone targets

### M0 — Establish the project and scope

**Status:** IN PROGRESS  
**Purpose:** Know exactly what we are building on and define the first playable target.

- [ ] Locate and inspect the Godot project, its engine version, existing code, assets and instructions.
- [ ] Verify local Godot, language runtime, build and test tools; document any installation needed.
- [ ] Review the existing project structure and preserve existing work.
- [ ] Decide initial engine/language and create a version-control and backup approach.
- [ ] Agree on the first scenario, map presentation and target hardware.
- [ ] Expand the GPS feature inventory using the game menus and clearly label observations versus ideas.
- [ ] Establish a feature register with priorities, dependencies and acceptance criteria.

**Done when:** The project builds or opens, its baseline is recorded, and the next milestone is agreed and measurable.  
**Current limitation:** The original project is outside the normal writable roots; this session transferred the verified prototype with elevated access. Visual interaction remains untested.

### M1 — Core technical framework

**Status:** NOT STARTED

- [ ] Set up a simulation module independent of rendering and interface.
- [ ] Define world state, country IDs, game date, decisions, events and data validation.
- [ ] Add a predictable tick/update loop, pause and speed controls.
- [ ] Add versioned save/load, backup handling and reproducible scenario seeds.
- [ ] Add logging, error reporting and a headless simulation test runner.
- [ ] Establish automated build, test and performance baseline.

**Done when:** A test world advances, accepts a simple decision, saves and reloads identically, and its behavior is reproducible. Record build instructions, test results and performance numbers.

### M2 — World state, map and time

**Status:** NOT STARTED

- [ ] Add a selectable map or placeholder country view and a country information panel.
- [ ] Load sample countries from sourced, versioned scenario data.
- [ ] Show date, pause, speed, event history and selected national indicators.
- [ ] Define initial country, institution, population and policy schemas; validate missing/invalid values.
- [ ] Load a modest test world and a synthetic full-size world for performance testing.

**Done when:** The player can select a country, advance time and inspect data without state corruption or UI stalls under the agreed test load.

### M3 — First playable policy loop

**Status:** NOT STARTED

- [ ] Implement the initial fictional federal executive-action scenario described in `FIRST_MILESTONE.md`.
- [ ] Model legal authority, decision lifecycle, agency capacity, implementation delays and budget impact.
- [ ] Add varied stakeholder reactions, potential litigation, judicial review and political response.
- [ ] Display an explanation and timeline for the outcome; allow amendment or revocation.
- [ ] Test, save/reload and play through multiple outcomes.

**Done when:** A player can make a decision, understand its consequences, continue playing and reproduce the outcome. The director reviews the loop for clarity and realism.

### M4 — Economy and population foundation

**Status:** NOT STARTED

- [ ] Model government revenue, spending, deficit and debt with documented units and accounting.
- [ ] Add a small initial set of production sectors, employment, wages, households and prices.
- [ ] Add population cohorts and demographic changes; reconcile demographic totals.
- [ ] Connect taxes and spending to budgets, groups and economic behavior over time.
- [ ] Add initial trade and resource flows; document uncertainty and calibration.
- [ ] Provide explanations and historical graphs for major indicators.

**Done when:** A policy change produces traceable, bounded effects across budget, economy and population over multiple simulated years, with meaningful tests and director playtesting.

### M5 — Domestic politics and country institutions

**Status:** NOT STARTED

- [ ] Add parties, legislatures, legislative votes, elections and transfers of power.
- [ ] Model public and private attitudes, representation, political influence and organized groups.
- [ ] Add constitutional and legal authority, court challenges and government implementation.
- [ ] Add configurable federal/regional powers and a second substantially different institutional setup.
- [ ] Add protests, negotiation, government responses and institutional safeguards.
- [ ] Compare outcomes for equivalent proposals across the test countries.

**Done when:** At least two institutional systems produce explainably different outcomes, including a functioning election or transfer of power and reproducible save/load.

### M6 — Diplomacy and international systems

**Status:** NOT STARTED

- [ ] Add bilateral relations, national interests, negotiations and agreements.
- [ ] Add trade agreements, sanctions, international organizations and treaty obligations.
- [ ] Build AI that considers domestic interests, security, economy and uncertainty.
- [ ] Add crises with diplomatic options, credibility, de-escalation and escalation.
- [ ] Test cases for peaceful compromise, failed negotiation and unintended consequences.

**Done when:** AI countries can pursue and resolve nonmilitary disputes, explain major decisions and maintain valid agreements over a long simulation.

### M7 — Military, deterrence and conflict

**Status:** NOT STARTED

- [ ] Add military budgets, personnel, readiness, equipment, supplies and command structure.
- [ ] Model crises, alliances, mobilization, war costs and peace negotiations.
- [ ] Include nuclear deterrence and escalation risk as a geopolitical system; calibrate through research and scenario testing.
- [ ] Add initial 3D military representations and low-detail symbols/counters; settings control visibility and detail.
- [ ] Measure frame rate and simulation speed with 3D assets on and off.

**Done when:** A bounded conflict can start, evolve and end, with diplomatic alternatives and material economic and political consequences. Visual settings function correctly on the target hardware.

### M8 — Global content and country depth

**Status:** NOT STARTED

- [ ] Expand countries, laws, institutions, parties, population groups and economic sectors in prioritized batches.
- [ ] Research and document starting conditions, sources, dates, licenses and uncertainty for each dataset.
- [ ] Add scenario and policy authoring tools; validate data and mod compatibility.
- [ ] Compare the implemented feature register against the verified GPS inventory and our own design priorities.
- [ ] Run automated long-horizon simulations across diverse countries and scenarios.

**Done when:** The agreed launch countries and feature set meet coverage, data quality and performance targets. Full GPS parity is not presumed.

### M9 — Playtesting and release readiness

**Status:** NOT STARTED

- [ ] Complete usability testing, tutorials, accessibility, settings and localization plans.
- [ ] Run structured internal and external playtests; record and prioritize feedback.
- [ ] Test compatibility, long games, save migration, crashes and performance on target machines.
- [ ] Resolve release-blocking issues and document known issues.
- [ ] Verify asset and data rights; obtain appropriate legal review for release and mod policies.
- [ ] Prepare store materials, distribution, support, backups and post-release update plans.

**Done when:** Director approves a release candidate against explicit quality, coverage and performance targets. Exact release scope and date remain open.

## 5. Feature register

| ID | Feature | Current status | Depends on | Acceptance target / note |
|---|---|---|---|---|
| F001 | Simulation clock and pause | Prototype | M1 | Gregorian dates and leap years; pause UI needs continued testing |
| F002 | World state and scenario data | Planned | M1 | Validated, versioned, reproducible state |
| F003 | Save/load | Prototype | M1 | Single versioned slot; round-trip tested, manual UI test pending |
| F004 | Executive orders | Designed at concept level | M1–M3 | Authority, implementation and institutional response |
| F005 | Public and private opinion | Partial prototype | M3–M5 | Three groups react differently to tax; private opinion is not implemented |
| F006 | Government budget and debt | Concept | M4 | Revenues, expenses and financing reconcile |
| F007 | Elections and parties | Partial prototype | M5 | Three fixed parties and a manual illustrative election; real election rules are not implemented |
| F008 | Federal / regional authority | Concept | M5 | Powers differ by scenario and institution |
| F009 | Negotiation and treaties | Concept | M6 | AI considers goals, trust and constraints |
| F010 | Nuclear escalation risk | Concept | M6–M7 | Research-backed assumptions; uncertain outcomes |
| F011 | Optional 3D military models | Concept | M7 | On/off and level-of-detail options with benchmark |
| F012 | Modding and data tools | Concept | M1, M8 | Versioned definitions and validation |
| F013 | GPS law and decision inventory | Partial | Research / game access | List verified options and unverified gaps |

Add rows as features are proposed. Record whether each is an idea, designed, in progress, implemented, tested, accepted or deferred.

## 6. Data register

| Dataset / artifact | Status | Source / provenance | Next action |
|---|---|---|---|
| GPS 2026 manual survey | Partial | Installed game and modding manuals; `GPS_2026_inventory.md` | Compare with actual in-game menus |
| Country boundaries / map | Not selected | Must document source, version, license and disputed-area policy | Evaluate sources |
| Population and economy | Not imported | Candidate public datasets; source, reference year and license must be checked | Choose coverage and validation |
| Governments, parties and institutions | Not imported | Country-specific sources required | Define schema and research process |
| Laws, starting policies and authority | Not imported | Dated legal and policy sources needed | Research first scenario and countries |
| Military, alliances and treaties | Not imported | Source and reliability vary | Select appropriate public datasets |
| Fictional characters / art | Not created | Original or properly licensed | Establish art and content workflow |

For each adopted dataset record: source URL, access date, reference period, license and attribution, transformation method, coverage, missing values, uncertainty and update process. No dataset should silently be presented as current or exact.

## 7. Quality and performance dashboard

| Measure | Target | Current result | Status |
|---|---|---|---|
| Project opens and builds | Successful on documented setup | Not measured | UNKNOWN |
| Automated critical-rule tests | All required checks pass | No test suite yet | NOT STARTED |
| Save/load round trip | State preserved and version recorded | Test scenario round trip passed; manual UI test pending | IN PROGRESS |
| Reproducible simulation | Same inputs and seed reproduce outcomes | Not measured | NOT STARTED |
| Long-run stability | No crashes or invalid state under agreed scenarios | Not measured | NOT STARTED |
| Simulation speed | Set target after hardware and scope are agreed | Not measured | TARGET NEEDED |
| Frame rate and memory | Set target for agreed baseline hardware | Not measured | TARGET NEEDED |
| Player comprehension | Director can explain major policy effects after playtest | Not measured | NOT STARTED |

**Definition of done for a feature:** behavior is implemented, documented, tested for meaningful outcomes and failure cases, compatible with save/load where relevant, and reviewed in a playable build when applicable. New defects are tracked; critical defects block milestone acceptance. Automated checks complement, rather than replace, playtesting.

## 8. Risks, shortcomings and blockers

| ID | Item | Effect | Current response | Status |
|---|---|---|---|---|
| R01 | Original Godot project is outside writable roots | Future changes there require appropriate access | Prototype transferred using elevated access; prepare and verify future changes safely | MANAGED |
| R02 | Scope could expand faster than systems are validated | Delays and brittle features | Prioritize a working loop and accept features incrementally | OPEN |
| R03 | GPS inventory is incomplete | Cannot claim feature parity | Inspect menus and test decisions; mark unknowns | OPEN |
| R04 | Data may be missing, outdated or incompatible | Unrealistic starting scenarios | Track provenance, uncertainty and reference dates | OPEN |
| R05 | Simulation can produce misleading or unstable outcomes | Poor realism and broken long games | Document assumptions, run invariants and playtest | OPEN |
| R06 | Country and population models can oversimplify | Stereotypes and inaccurate outcomes | Model variation, institutions, uncertainty and change | OPEN |
| R07 | Low-end performance target not defined | Cannot verify optimization | Agree hardware and benchmark representative workloads | OPEN |
| R08 | Real-person likenesses and third-party assets | Possible legal and distribution issues | Fictional base content, provenance and legal review | OPEN |
| R09 | AI-generated implementation may contain errors | Regressions and incorrect mechanics | Review, automated checks, reproducible tests and playtesting | OPEN |

## 9. Research and insights

| Date | Finding | Evidence / confidence | Implication |
|---|---|---|---|
| 2026-11-10 | GPS 2026 manual describes parliamentary voting, budgets, trade, elections and other systems. | Installed manuals; high confidence that manual describes them, runtime behavior not independently verified. | Use as a partial feature checklist, not as an exact formula reference. |
| 2026-11-10 | A single country's executive, courts, legislature, agencies and regional governments can react differently to the same action. | Project design insight; exact rules require country-specific research. | Implement institutions and authority as explicit systems. |
| 2026-11-10 | Public compliance may differ from private support. | Design principle, not an empirical reading of any specific population. | Track expression, belief and ability to organize separately where feasible. |
| 2026-11-10 | Disabling 3D military assets may reduce rendering costs. | Design hypothesis; no benchmark yet. | Measure both rendering and simulation performance separately. |

## 10. Decision log

| Date | Decision | Status / reason |
|---|---|---|
| 2026-11-10 | Prioritize political simulation, diplomacy and realistic consequences. | Agreed direction from director. |
| 2026-11-10 | Include optional military 3D visuals and lower-detail settings. | Agreed direction; implementation pending. |
| 2026-11-10 | Use fictional likenesses in the base game and support modding. | Current direction; real-person distribution/promotion requires legal review. |
| 2026-11-10 | Godot with separate C# simulation proposed. | Recommendation only; verify actual project before final choice. |
| 2026-11-10 | Prototype a US-style executive-action loop. | Proposed first vertical slice; director can change priority. |

## 11. Change history

| Date | Change | Verification / evidence | Next step |
|---|---|---|---|
| 2026-11-10 | Established initial game vision and discussed architecture. | Conversation; no game implementation verified. | Inspect project and confirm first playable scope. |
| 2026-11-10 | Inspected GPS 2026 installation read-only and created initial decision inventory. | Installed manuals; `GPS_2026_inventory.md`. | Examine game menus and conduct controlled tests. |
| 2026-11-10 | Drafted executive-action first milestone. | `FIRST_MILESTONE.md`; design document, no implementation. | Reconcile with project setup and director priorities. |
| 2026-11-10 | Created this living report and milestone plan. | Documentation only; no builds or tests run. | Keep updated after every substantive change. |
| 2026-11-10 | Located `the-global-mandate`, an otherwise blank Godot 4.7 project, and copied its project files into the writable workspace. | Read-only source inspection; Godot 4.7.2 executable found locally. | Transfer changes to original only with appropriate write access. |
| 2026-11-10 | Added a separate GDScript simulation, startup scene, prototype UI and headless simulation checks to the workspace copy. The test world advances through a temporary 360-day calendar and changes revenue and approval after an income tax decision. | Godot 4.7.2 headless scene startup passed; simulation checks passed for annual accounting, date rollover, policy effect and invalid inputs. The first test logged a sandbox-related user log write warning. | Add persistence, realistic calendar and stronger state validation in future work; visually test the UI. Values and formulas are fictional placeholders. |
| 2026-11-10 | Copied the tested prototype into the original Godot project, preserving the existing icon and settings apart from registering the main scene. | Elevated Godot 4.7.2 headless simulation checks and scene startup both passed against the original project. Standard sandboxed Godot could not open the external project path. | Visually verify interaction and implement persistence. |
| 2026-11-10 | Director played the prototype and requested a stronger public reaction to a 60% income tax. Adjusted the temporary approval sensitivity: raising tax from 20% to 60% reduces initial approval from 50% to 8%. | Automated checks passed in the workspace copy and original project, including the requested scenario and invalid tax inputs. | Replace this immediate, uniform placeholder with group-specific responses, institutions and delayed effects as the simulation develops. |
| 2026-11-10 | Session 1 closed: original Godot project located, baseline simulation and interface created, director tested it, and tax approval sensitivity adjusted. | Godot 4.7.2 automated checks passed; director confirmed the prototype runs. | Continue core framework in session 2. |
| 2026-11-10 | Session 2: replaced the 360-day placeholder with Gregorian month lengths and leap years; annual budget amounts accrue over the correct number of days in each year. Added versioned JSON single-slot saving/loading, a previous-save backup, input validation, error feedback and UI buttons. Load pauses the simulation. | Godot 4.7.2 checks passed in workspace and original project: year rollover, annual accounting, leap-year rules, policy response, save round trip and malformed-save rejection without mutating state. Both projects passed headless scene startup. UI save/load interaction not manually verified. | Manually exercise saving and loading; add more complete state validation, stronger save recovery and broader simulation systems. |
| 2026-11-10 | Session 3: added 1, 5 and 30 days-per-second simulation speeds and displayed projected annual and daily budget balances. | Headless UI and simulation checks passed; manual visual review pending. | Expand time controls and performance testing as the world grows. |
| 2026-11-10 | Session 4: added a government-spending control, validated spending inputs and recorded spending changes as dated events. The present model affects the treasury only; it does not yet model services, jobs or approval. | Automated checks verify the balance, invalid inputs and save/load of spending. | Add sector allocations and realistic consequences in later systems. |
| 2026-11-10 | Session 5: added a load-previous-backup button, tightened save validation, added a warning when the treasury crosses below zero, bounded event history to 200 entries, and explained the current budget calculations in the interface. | Tests cover backup restoration, invalid saves, deficit warning, leap-day rollover, 20 simulated years and core UI actions. Both simulation and headless UI checks passed on the original project. | Manually check layout and save/backup buttons. Debt, group approval and realistic spending impacts remain unimplemented. |

### Sessions 6–15 — focused prototype work, completed as one development batch

These are small, connected work packages completed and tested together on 2026-11-10, not ten full-scale systems or ten separately dated workdays.

| Session | Change | Current limitation |
|---|---|---|
| 6 | Added three fictional income groups with population shares and individual approval values. | Groups do not yet represent demographics, regional differences or private beliefs. |
| 7 | Added different tax sensitivities for those groups. | Coefficients are arbitrary test values; reactions are immediate. |
| 8 | Calculate national approval as the population-weighted average. A direct 20% to 60% tax increase still yields approximately 8% from the initial scenario. | Repeated changes and approval limits are simplified. |
| 9 | Added a fictional three-party, 100-seat legislature and seat counts. | Party positions and seat distributions are fixed at initialization. |
| 10 | Added a parliamentary vote on a fictional procurement policy requiring a majority. | No executive orders, constitutional review, legislative debate or detailed policy effects. |
| 11 | Added implementation progress over 100 days and an event on completion. | Procurement costs and economic benefits are not modeled. |
| 12 | Added a manually triggered illustrative election which converts approval into government seats. | This is a deliberately simple two-bloc approximation, not a realistic voting system; no election schedule or coalition negotiation. |
| 13 | Added version-2 saves containing population groups, parties, policy progress and election count. | One save slot; no generalized migration framework. |
| 14 | Added validation of political state and migration of version-1 saves, initializing each group's approval from the old national value. | Historical differences between groups cannot be recovered from older saves. |
| 15 | Added a scrollable political display and buttons, expanded simulation and UI checks, and integrated the batch into the original project. | Headless interaction tests passed; graphical layout and manual interactions have not been visually verified. |

**Batch verification:** Godot 4.7.2 headless simulation and UI checks passed in the workspace and original project. Checks cover differing group responses, initial tax scenario, majority vote, implementation, election seats, v2 save round-trip and v1 migration, alongside existing budget/calendar/backup tests. The simulation remains an early fictional prototype; diplomacy, country-specific institutions, real-world data and realistic economic models remain future work.

### Session 16 — working-copy reconciliation

Issue #1; PR #54. Established the repository checkout as the preferred source-controlled Godot project and documented that the older project folder is separate. Added a read-only SHA-256 comparison utility and a test covering matching, differing, missing, extra and generated-cache files. The comparison found `.gitignore` differs and the repository alone has `tests/test_compare_projects.py`; no files were overwritten. The utility intentionally excludes generated Godot files, documentation and tools, so it does not certify those files match. The bundled Python test passed; the default `python` launcher was unavailable in the sandbox.

### Session 17 — simulation architecture baseline

Issue #2; PR #55. Documented existing simulation ownership, units, update ordering, decisions, persistence and known limitations in `SIMULATION_ARCHITECTURE.md`. The model remains a fictional prototype; documentation does not imply that future contracts have been implemented. Headless simulation and UI checks passed.

### Session 18 — save recovery safeguard

Related to issue #4; PR #56. Before backup rotation, validate the primary in a separate world instance. Preserve an invalid primary as `.invalid` rather than replacing a good backup with it; if that path is already occupied, stop and inform the player. Godot 4.7.2 simulation and UI checks passed, including a regression test for saving after primary corruption. Issue #4 remains open: interrupted-write testing and fully transactional rotation still need work.

### Session 19 — backup rotation safeguards

Related to issue #4; PR #57. The previous backup is retained as `.bak.previous` during rotation, with best-effort rollback on rename failure and a guard against overwriting an existing recovery artifact. Simulation and UI checks passed, including a simulated leftover backup; filesystem failure injection and actual crash-recovery tests remain outstanding. Rollback remains best effort, not a guarantee.

### Session 20 — bounded simulation pacing

Related to issue #6; PR #58. The UI processes at most 30 simulation days per frame and retains the backlog; pause and speed changes preserve it, while loading clears it. Godot headless simulation and UI tests passed, including a long-frame catch-up test. The cap alone does not guarantee frame rate; full-world benchmarking remains open.

### Session 21 — bounded test runner

Related to issue #8; PR #59. Added a Python runner for the two headless Godot suites with per-test timeouts, completion markers and nonzero failure status. Runner unit tests cover success, failure and timeout, and both Godot suites passed via the runner. CI and cross-platform validation remain open.

### Session 22 — continuous integration

Related to issue #8; PR #60. Added a bounded Linux GitHub Actions workflow with a checksum-verified Godot 4.7.2 download, Python utility tests and headless simulation/UI checks. The hosted PR run is the verification record; Windows-specific and visual testing remain outside this workflow.

### Session 23 — prevent tax approval drift

Related to issue #20; PR #61. Track an unclamped internal group approval and display it within 0–100%, so reversing a tax change does not create drift after a boundary was reached. Version-3 saves retain the value; v1/v2 migrate from visible approval and cannot recover previously clipped history. The 20% to 60% example and headless simulation/UI tests passed locally; this remains a fictional, immediate linear model.

### Session 24 — tax decision preview

Related to issues #11 and #45; PR #62. Added a read-only preview of projected revenue and approval by group before applying the prototype tax decision. Local Godot simulation and UI tests verify no mutation, invalid input handling and agreement between preview and actual result. The effect is based on placeholder assumptions and the broader economic and dashboard work remains open.

### Session 25 — spending decision preview

Related to issues #12 and #45; PR #63. Added a read-only spending preview showing projected annual balance and daily treasury change, with clear disclosure that service and employment impacts are not modeled. Local Godot simulation and UI checks passed, including invalid input, leap-year calculation and preview/application agreement. The larger spending and dashboard issues remain open.

### Session 26 — scheduled prototype elections

Related to issue #26; PR #64. Replaced the unrestricted election button with an automatic fictional four-year schedule starting in 2030, and display the next election year. The schedule derives from the existing saved date; older saves do not retroactively simulate missed elections. Local tests passed for scheduling, no duplicate, UI and save/load around election day. Seat calculation remains a placeholder; country-specific elections are not implemented.

### Session 27 — procurement policy budget effect

Related to issues #10 and #25; PR #65. The fictional procurement policy now discloses a $10 million annual cost, applied to the budget after its 100-day implementation completes. The expense is derived from policy state and is also applied when older saves already containing a completed policy are loaded. Local Godot simulation and UI tests passed for timing, budget, preview and restored state. No procurement benefit or realistic economic effect is modeled.

### Session 28 — repeal of the test policy

Related to issues #22 and #25; PR #66. Added a majority vote to repeal the fictional procurement policy, clearing its implementation and ending its ongoing cost, with UI support and event history. Local tests passed for unsuccessful and successful votes, implementation cancellation, cost removal and save/load. Repeal behavior remains simplified and country-specific legislative procedures are not implemented.

### Session 29 — test election party allocation

Related to issue #26; PR #67. The fictional election splits non-government seats between both other parties in proportion to their previous seats, with an even fallback when both previously held none. Local tests cover normal and extreme results and seat totals. This is not a realistic electoral model, and a party at zero seats cannot recover unless both other parties were at zero.

### Session 30 — integrated policy scenario

Related to issue #48; PR #68. Added an end-to-end scenario covering a tax change, policy adoption and cost, save/load, the scheduled election, repeal and budget consequences. The bounded runner includes the new test, and all three Godot suites passed locally. This tests prototype consistency rather than realism; the broader simulation-invariants and long-run-testing issue remains open.

### Session 31 — government budget foundation

Related to issues #10, #11, #12, #17, #45 and #48; PR #69. Added five individually adjustable spending categories, budget previews, tax/other revenue display, cash, debt, automatic borrowing and repayment, and a fictional 3% debt-interest rate. Version-4 saves preserve budget categories and debt; earlier saves migrate using default shares and convert a negative treasury to debt. Local simulation, UI and integrated tests passed for accounting, invalid inputs, borrowing, repayment, migration and inconsistent save rejection. No services, economic feedback, realistic debt market or visual playtest is claimed. Broader related issues remain open.

### Session 32 — services and group responses

Related to issues #12, #18, #19, #20, #45 and #48; PR #70. Added five fictional public-service conditions, targets based on spending per resident and gradual daily changes. Average service condition contributes differently to each test group's approval, separately from tax response. The interface shows current and target conditions. Version-5 saves persist and validate service state; v1–v4 start at neutral condition because past service history is unavailable. Local simulation, UI and integration checks passed for funding cuts/increases, baseline stability, group differences, old-save migration, corrupt service rejection and deterministic continuation. All coefficients are placeholders; real demographic, staffing, regional and economic effects and visual testing remain open.

### Session 33 — additional taxes

Related to issues #10, #11, #13, #20, #45 and #48; PR #71. Added separately adjustable fictional consumption and corporate taxes, fixed taxable bases, revenue breakdowns, group-specific reactions and non-mutating UI previews. Version-6 saves persist rates; earlier saves receive zero rates without changing prior revenue or opinions. Local simulation, UI and integration suites passed, including invalid inputs, old-save migration, v6 round trip and invalid-save rejection. Fixed bases and reaction coefficients are placeholders; tax compliance, economic feedback, realistic incidence and visual testing remain open.

### Session 34 — executive action and court review

Related to issues #21, #23, #24, #25, #45 and #48; PR #72. Added a fictional directive lifecycle with two authority cases, delayed agency progress, automatic court review, injunction, revocation, event logging and a UI display. Version-7 saves validate and preserve institutional state; v1–v6 start without a directive. Local simulation, UI and integrated checks passed for both court outcomes, injunction, revocation, migration and invalid-state rejection. Cases and outcomes are deterministic placeholders, not actual country law; fiscal, political and economic consequences and visual playtesting remain open.

### Session 35 — fiscal ledger and annual history

Related to #10, #45 and #48; PR #73. Added daily recorded fiscal flows, borrowing and repayment, current and previous year displays, and version-8 save migration. Tests cover rollover, accounting, debt, persistence and malformed history. Older saves show a partial ledger because historical flows cannot be reconstructed. This is an illustrative aggregate, not a calibrated national accounting model. Details: [Session 35](SESSION_35.md).

## 12. Immediate next actions

1. Visually review the expanded UI and manually test saving, loading and the new political controls.
3. Agree the initial scenario and baseline hardware; convert M1/M3 acceptance criteria into concrete tasks.
4. Continue the GPS menu inventory when game access permits; design more realistic political, economic and institutional models before expanding content.

## 13. Maintenance protocol

After each substantive work session: update milestone status and feature rows; append dated changes and test evidence; add issues, decisions and data sources; record the next actionable step. Update progress bars only from completed acceptance criteria. Keep old change and decision entries, marking superseded decisions rather than deleting them. Record estimated timelines separately from measured progress and revisit them when evidence changes. If the report becomes too large, move detailed feature or data catalogs into linked companion files and retain their summaries and history here.

### Source-control workflow

The director requests a GitHub commit and push after each completed development session. Review the exact changes, run relevant checks, update this report and commit with a descriptive message before pushing to the agreed repository. Do not claim a push succeeded until the remote confirms it. Keep Godot caches, build outputs, test logs and saves out of version control.

### GitHub development backlog

On 2026-11-10, created 53 initial roadmap issues in the private repository: https://github.com/bhavishyadash/the-global-mandate/issues. Issues #1–#53 cover the technical foundation, economy, population, politics, diplomacy, AI, military, data, interface, modding, quality and release. These are broad planning issues, not a complete prediction of future defects or an approved release scope; split and refine them as development reveals the detailed work. No issues are marked complete by this planning step. Sessions 6–15 were subsequently completed as the focused prototype batch described above.
