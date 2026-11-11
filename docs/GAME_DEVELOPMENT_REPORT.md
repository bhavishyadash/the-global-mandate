# Geopolitical Simulator — Living Development Report

**Working title:** The Global Mandate (final name undecided)
**Report started:** 10 November 2026  
**Development stage:** Early simulation prototype
**Current milestone:** M1 — Core technical baseline implemented; target-hardware validation deferred, M2/M3 prototyping underway
**Report status:** Living record; updated through session 64
**Owner / creative director:** You  
**Implementation and technical reporting:** Codex, working with your direction

> This is a living, editable Markdown document. You can open and change it in any text editor, GitHub, VS Code or the Codex app. Tables and simple status bars make progress visible without requiring Excel or Word. Update this file after meaningful work; add dated history entries instead of rewriting the past. A proposed target is not a completed feature.

## 1. At a glance

| Area | Status | What we know / need |
|---|---|---|
| Vision | Defined at a high level | Modern, highly detailed political simulation; diplomacy before war |
| Godot project | Located and updated | `C:\Users\Shadow\Documents\ChatGPT\Geopolitical Simulator\the-global-mandate`; tracked Godot 4.7 project |
| Simulation | Framework prototype in tracked project | Gregorian calendar, fictional budget, population, institutions, diplomacy and single-slot save/load |
| World data | Fictional scenarios only | Real-country research sources, licensing, dates, gaps and uncertainty remain open |
| Political systems | Early fictional prototype | Three population groups, a three-party legislature, procurement and healthcare test laws, and a simplified election; real country institutions remain future work |
| Economy | Early fictional budget prototype | Sectors, households, employment, prices and trade remain open |
| Diplomacy and military | Early fictional diplomacy prototype | Timed talks and bilateral relations; strategic conflict and optional military models remain future work |
| GPS feature inventory | Initial partial survey | Installed manual reviewed; actual menus and formulas remain incomplete |
| Visual design | Not decided | Map style, UI references and low-end performance target needed |
| Playable build | Early framework prototype in tracked project | Day advance, executive action, history and scenario confirmation visually exercised; save/load and layout still need visual testing |
| Release date and budget | Not set | Establish targets after project inspection and first benchmarks |

**Progress by milestone** — status is based on implemented evidence, not a percentage or schedule forecast. M1's core baseline is implemented; target-hardware and broader quality checks remain open.

**Session 62:** The first healthcare governing loop connects a parliamentary vote, annual spending, administrative rollout, services and group approval. [Detailed session record](SESSION_62.md). All rules are illustrative; real-world calibration, broader political systems and director playtesting remain upcoming.

**Session 63:** Healthcare authorization and actual funding are now separate. Partial or zero funding changes spending, rollout and service targets, with an annual budget preview and save migration. [Detailed session record](SESSION_63.md). The appropriation is a direct player decision; parliamentary budget procedures remain upcoming.

**Session 64:** Healthcare appropriation changes now go to an immediate parliamentary vote with visible party positions and financial and implementation previews. This supersedes session 63's direct-change rule; initial passage still provides full funding. [Detailed session record](SESSION_64.md). A full annual budget process remains upcoming.

```text
M0  Project foundation and scope       IN PROGRESS — hardware, map and scope open
M1  Core technical framework           BASELINE IMPLEMENTED — target checks deferred
M2  World state, map and time          EARLY PROTOTYPE — no coupled world or map
M3  First playable policy loop         EARLY PROTOTYPE — director playtest open
M4  Economy and population foundation  EARLY PROTOTYPE — budget and groups only
M5  Institutions and domestic politics EARLY PROTOTYPE — fictional rules
M6  Diplomacy and international system EARLY PROTOTYPE — fictional talks
M7  Military and conflict              NOT STARTED
M8  Global content and country depth   NOT STARTED
M9  Playtesting and release readiness  NOT STARTED
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
| Engine / language | Godot 4.7.2 and GDScript in the prototype | Revisit only with a concrete technical reason |
| Map | Undecided: flat, globe or hybrid | Director chooses after reviewing prototypes |
| Initial playable geography | Fictional US-style test scenario proposed | Confirm during M0; world expansion follows |
| Real-time scale and pause | Pausable simulation proposed | Prototype and test |
| Military depth | Strategic-first; detailed mechanics undecided | Director defines desired control |
| Target hardware | Provisional low-end Windows laptop: 4 CPU cores, 8 GB RAM, integrated graphics, 720p | Director selected a provisional low-end target; specific CPU/GPU and measurements remain open |
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

- [x] Locate and inspect the Godot project, its engine version, existing code, assets and instructions.
- [x] Verify local Godot, language runtime and headless test tools; document missing export templates.
- [x] Review the existing project structure and preserve the separate earlier copy.
- [x] Establish the prototype engine/language, version control and save-backup approach.
- [ ] Agree on the first scenario, map presentation and target hardware.
- [ ] Expand the GPS feature inventory using the game menus and clearly label observations versus ideas.
- [x] Establish a preliminary feature register with dependencies and acceptance criteria; continue refining priorities.

**Done when:** The project builds or opens, its baseline is recorded, and the next milestone is agreed and measurable.  
**Current limitation:** The source-controlled project is the copy in this workspace; the earlier project is separate. A limited visual smoke test passed; target hardware and broader usability remain unverified.

### M1 — Core technical framework

**Status:** CORE BASELINE IMPLEMENTED; target-hardware and broader validation remain open.

- [x] Set up simulation modules that run independently of rendering and interface.
- [x] Define initial country/scenario IDs, date, validated decisions and categorized events. World dictionaries remain mutable and event payloads are limited.
- [x] Add a predictable tick/update loop, pause and speed controls.
- [x] Add versioned saves, candidate validation, backup handling, seeded state and deterministic replay. Crash/fault injection is not exhaustive.
- [x] Add event history, user-visible errors and a bounded headless test runner.
- [x] Automate headless tests and a resource-pack build; record an initial independent-copy performance measurement. A Windows executable has passed local headless and basic graphical startup checks; coupled-world performance remains unverified.
- [x] Visually exercise core standalone interactions: day advancement, save/load, scenario selection and a directive/history smoke test. Broader window-size and usability testing remains open.
- [ ] Verify the standalone build on target hardware and define simulation speed targets. A Windows executable and PCK were built, started and advanced one day on the current machine in session 56.

**Evidence:** Test worlds advance, accept decisions, save/reload, replay deterministically and pass a ten-year stress scenario; build/test instructions are in the README and synthetic performance measurements are in sessions 48 and 60. The director deferred validation on the provisional low-end hardware. These results do not imply that the broader game is complete.

### M2 — World state, map and time

**Status:** EARLY PROTOTYPE

- [ ] Add a selectable map or placeholder country view and a country information panel.
- [ ] Load sample countries from sourced, versioned scenario data.
- [ ] Show date, pause, speed, event history and selected national indicators.
- [ ] Define initial country, institution, population and policy schemas; validate missing/invalid values.
- [ ] Load a modest test world and a synthetic full-size world for performance testing.

**Done when:** The player can select a country, advance time and inspect data without state corruption or UI stalls under the agreed test load.

### M3 — First playable policy loop

**Status:** EARLY PROTOTYPE

- [ ] Implement the initial fictional federal executive-action scenario described in `FIRST_MILESTONE.md`.
- [ ] Model legal authority, decision lifecycle, agency capacity, implementation delays and budget impact.
- [ ] Add varied stakeholder reactions, potential litigation, judicial review and political response.
- [ ] Display an explanation and timeline for the outcome; allow amendment or revocation.
- [ ] Test, save/reload and play through multiple outcomes.

**Done when:** A player can make a decision, understand its consequences, continue playing and reproduce the outcome. The director reviews the loop for clarity and realism.

### M4 — Economy and population foundation

**Status:** EARLY PROTOTYPE

- [ ] Model government revenue, spending, deficit and debt with documented units and accounting.
- [ ] Add a small initial set of production sectors, employment, wages, households and prices.
- [ ] Add population cohorts and demographic changes; reconcile demographic totals.
- [ ] Connect taxes and spending to budgets, groups and economic behavior over time.
- [ ] Add initial trade and resource flows; document uncertainty and calibration.
- [ ] Provide explanations and historical graphs for major indicators.

**Done when:** A policy change produces traceable, bounded effects across budget, economy and population over multiple simulated years, with meaningful tests and director playtesting.

### M5 — Domestic politics and country institutions

**Status:** EARLY PROTOTYPE

- [ ] Add parties, legislatures, legislative votes, elections and transfers of power.
- [ ] Model public and private attitudes, representation, political influence and organized groups.
- [ ] Add constitutional and legal authority, court challenges and government implementation.
- [ ] Add configurable federal/regional powers and a second substantially different institutional setup.
- [ ] Add protests, negotiation, government responses and institutional safeguards.
- [ ] Compare outcomes for equivalent proposals across the test countries.

**Done when:** At least two institutional systems produce explainably different outcomes, including a functioning election or transfer of power and reproducible save/load.

### M6 — Diplomacy and international systems

**Status:** EARLY PROTOTYPE

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

### Session 36 — dashboard navigation

PR #74, related to #45 and #48. Organized the prototype into five scrollable tabs and kept common time and save controls available; headless UI, simulation and integration checks passed. Visual and resolution testing remains open. See [Session 36](SESSION_36.md).

### Session 37 — fiscal forecast

PR #75, related to #10, #45 and #48. Added an on-demand 365-day forecast on an independent simulation copy, including evolving debt interest and policy state. Headless tests verify no mutation and agreement with an actual run. It assumes no new decisions or unmodeled shocks and uses fictional rules. See [Session 37](SESSION_37.md).

### Session 38 — policy scenario comparison

PR #76, related to #10, #11, #12, #45 and #48. Added a non-mutating comparison of current settings with entered income tax, an additional tax and total spending, including cash, debt and approval. Tests compare forecasts to an actual run and reject invalid changes. Assumptions and limitations: [Session 38](SESSION_38.md).

### Session 39 — population transparency and robustness

PR #77, related to #18, #19, #20, #45 and #48. Added a Population tab explaining the prototype's group shares, approval components and tax sensitivities; rejected income-tax changes that would produce negative revenue; tested four years of deficit accounting, leap-year progression and save/load continuation. These groups are not unique personalities or researched country demographics. Details: [Session 39](SESSION_39.md).

### Session 40 — diplomacy foundation

PR #78. Added two fictional partners, bilateral relations, one active 30-day negotiation, cancellation, cooldown, event history and a Diplomacy tab. Version-9 saves preserve and validate state; older saves get test defaults. Local simulation, interface and integration checks passed. See [Session 40](SESSION_40.md) for simplified rules and gaps.

### Session 41 — negotiation choices

PR #79. Added dialogue and cooperation proposals, partner-specific acceptance thresholds, accepted/declined outcomes and visible previews. Version-10 migration preserves version-9 active talks as dialogue. Tests cover both outcomes and migration. These are deterministic test rules, not treaties or real diplomacy. See [Session 41](SESSION_41.md).

### Session 42 — cooperation agreements

PR #80. Accepted cooperation talks now produce renewable, time-limited agreements with an illustrative budget cost, early termination and expiry. Save v11, forecasts, fiscal accounting and tests include the lifecycle. The costs and effects are fictional; trade and treaty law remain open. See [Session 42](SESSION_42.md).

### Session 43 — agreement fiscal effects

PR #81. Added a separately displayed fictional partner contribution for active cooperation agreements, integrated with budget previews, cash flow, ledger and forecasts. Existing v11 agreements acquire this new rule when loaded; previous ledger entries remain unchanged. Headless checks cover accounting and expiry. The assumed payments are placeholders, not a trade model. See [Session 43](SESSION_43.md).

### Session 44 — executive consequences

PR #82. The fictional reporting directive now affects the Administration service target and budget after implementation; revocation stops future effects but preserves prior service changes. Tests cover timing, public response and save/load. Previously implemented directives acquire the new fictional rules on load. See [Session 44](SESSION_44.md).

### Session 45 — integrated policy reliability

PR #83. Forecasts and comparisons now flag stale results; a combined scenario tests negotiations, agreement accounting, executive implementation, services, approval, save/load and forecast consistency. Normalized diplomatic numeric types after a save/load discrepancy was found. Local headless checks pass. See [Session 45](SESSION_45.md).

### Session 46 — versioned scenario foundation

PR #84. Moved the initial fictional country and date into validated versioned scenario data; added stable scenario/country IDs, version-12 save migration, a startup error for invalid default data and tests. Other institutions and population definitions remain hard-coded. See [Session 46](SESSION_46.md).

### Session 47 — decision contracts

PR #85. Added a validated common command interface and migrated existing UI decisions to it, with explicit result codes and tests. The lower-level world methods and mutable data remain accessible; a complete policy catalog is future work. See [Session 47](SESSION_47.md).

### Session 48 — reproducibility and initial benchmark

PR #86. Added a bounded deterministic decision replay harness and automated repeatability test, plus a synthetic independent-copy benchmark. A local 200-copy/30-day run took 94.908 ms for ticks; it is not a coupled-world or frame-rate benchmark. Details and measurement limits: [Session 48](SESSION_48.md).

### Session 49 — structured event history

PR #87. Added bounded, dated and categorized event records, History filtering and save-v13 migration. Older text is preserved as legacy records with unknown structured metadata. Tests cover filtering, copying, invalid saves, migration and replay. Structured actors and causal payloads remain future work. See [Session 49](SESSION_49.md).

### Session 50 — package validation

PR #88. Added a development export preset that includes scenario data, resource identity metadata, a packaged-scenario smoke test and CI coverage. The local resource pack was exported and loaded successfully from an empty directory. This does not establish a working standalone Windows export or visual rendering. See [Session 50](SESSION_50.md).

### Session 51 — scenario population and institutions

PR #89. Expanded scenario data to include political groups, party seats, service conditions, executive state and diplomacy, with cross-system consistency checks and version-1 scenario compatibility. A second fictional starting state is covered by tests; model structure and partner identities remain fixed. See [Session 51](SESSION_51.md).

### Session 52 — scenario selection

PR #90. Added a second fictional starting scenario and an in-game selection flow with confirmation before replacing the current session. Tests cover invalid input, reset, replay and packaged scenario data. The scenarios share the same rules and are not a coupled world. See [Session 52](SESSION_52.md).

### Session 53 — reproducible random state

PR #91. Added a scenario seed and stable 32-bit random state, saved in v14, with replay, forecast isolation and migration tests. Existing simulation outcomes remain deterministic; stochastic game mechanics remain future work. See [Session 53](SESSION_53.md).

### Session 54 — save safety and long-run checks

PR #92. Validate the candidate save with the loader before replacing the primary or backup; added a 3,650-day deterministic stress test with tax, spending, diplomacy, directives, elections and mid-run save/load. Filesystem crash and failure injection remain open. Details: [Session 54](SESSION_54.md).

### Session 55 — foundation acceptance audit

PR #93. Reconciled the milestone checklist with implemented evidence, documented remaining platform and usability gaps, improved timed-out test diagnostics, and visually exercised the tracked project in Godot: day advancement, an executive directive, its history entry and the scenario-change confirmation. Save/load and layout testing remain open. See [foundation acceptance](FOUNDATION_ACCEPTANCE.md) and [Session 55](SESSION_55.md).

### Session 56 — Windows development build

PR #94. Installed the checksum-verified Windows Godot export templates, added a non-overwriting build/smoke script and built a Windows executable plus PCK. Headless startup and a basic graphical day advance passed on the current machine; the default window was very small and provisional low-end hardware verification remains open. The downloaded archive was removed after verification. See [Session 56](SESSION_56.md).

### Session 57 — startup window usability

PR #95. The standalone build now starts maximized after the previous default appeared very small. A new Windows build was visually checked for maximized startup and restore/maximize controls; 720p and target-laptop validation remain open. See [Session 57](SESSION_57.md).

### Session 58 — validated world snapshots

PR #96. Extracted detached snapshot export and atomic validated import from the save loader, with unchanged save-v14 format and migration coverage. This is infrastructure for multi-country state, not yet a coupled world. See [Session 58](SESSION_58.md).

### Session 59 — multi-country core

PR #97. Added a headless registry of uniquely identified, synchronized countries with bilateral dialogue and validated detached snapshots. Existing gameplay remains single-country and its diplomacy is separate; registry persistence and UI integration are open. See [Session 59](SESSION_59.md).

### Session 60 — multi-country persistence and benchmark

PR #98. Added validated registry save/load with backup safeguards and a synthetic 200-country linked-dialogue benchmark. A local 365-day run took 1,302.541 ms of tick time; the test uses identical fictional copies and is not a target-hardware or full-game result. Existing playable UI still uses single-country saves. See [Session 60](SESSION_60.md).

### Session 61 — foundation validation and handoff

PR #99. Visually verified standalone save/load, scenario selection and restoration on the current machine. The director chose to defer low-end hardware validation. The M1 core baseline is implemented, with remaining quality and multi-country integration gaps recorded in [foundation acceptance](FOUNDATION_ACCEPTANCE.md); a prototype test save was created. Details: [Session 61](SESSION_61.md).

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
