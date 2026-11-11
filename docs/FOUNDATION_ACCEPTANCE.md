# Foundation acceptance record

This distinguishes the implemented M1 technical baseline from full foundation signoff. Evidence is current through session 55. No percentages imply completeness or a release date.

| Criterion | Evidence | Remaining qualification |
|---|---|---|
| Headless simulation and clock | Five bounded Godot suites run in CI; date, pause, speeds, decisions and calendar are tested. | One active simulated country; not a coupled world. |
| Scenario data and IDs | Two fictional v2 scenario files validate country, political, service, institution and diplomacy state; v1 defaults remain supported. | Three groups/parties, fixed services and partner IDs; laws and behavior are still code. |
| Decisions and events | Validated command IDs return explicit results; bounded categorized dated records support filtering. | Public dictionaries and direct methods remain mutable; events lack structured actors/causal payloads. |
| Persistence and reproducibility | Save v14 validates candidate state before rotation; older saves migrate; seeded state, replay and ten-year save/reload stress tests pass. | Filesystem failure injection, power-loss recovery and stochastic gameplay are unverified. |
| Build and test automation | GitHub Actions runs Python and Godot suites and tests both scenarios in an exported resource pack. Session 56 built a Windows executable and PCK, checked headless and graphical startup, and advanced a day. Session 57 verified a new build starts maximized and can be restored on the current machine. | Installation, upgrades and operation on target hardware are unverified; CI does not export the standalone binary. The restored window appeared small. |
| Initial performance | Session 60 measures up to 200 synchronized fictional countries with simplified neighbor dialogues on the current machine. The director chose a provisional low-end laptop target. | The workload lacks trade, geography, AI and realistic country diversity; no target-laptop, frame-rate, p95 or memory measurement exists. |
| Visual smoke | In Godot 4.7.2, opened the tracked project, advanced one day, issued an executive directive, inspected its history and opened/cancelled the scenario-change confirmation. | Embedded preview was small; visual save/load, scenario replacement, accessibility, multiple window sizes and director playtesting remain open. |

The provisional minimum is a Windows laptop with four CPU cores, 8 GB RAM, integrated graphics and a 720p display. Initial design goals are a usable 720p interface and at least 30 frames per second during ordinary interaction, with graphics options available as visual features grow. Simulation speed targets need a representative coupled-world workload before they can be defined responsibly. These are goals, not measured results or a guarantee that the current prototype meets them.

M1's core mechanics are implemented and automatically tested. **Do not mark the entire foundation phase complete** until target-platform verification, broader visual interaction and a representative coupled-world benchmark on the provisional target are addressed. M2/M3 and the economy, institutions and diplomacy milestones contain prototypes, not their full acceptance scope.
