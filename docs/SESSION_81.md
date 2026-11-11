# Session 81: legislative transparency

## Delivered

- Government controls are enabled only when the current bill stage permits them. The funding choice is locked while a bill is in progress.
- The screen previews fictional House and Senate support for the selected proposal before introduction, instead of reporting zero votes while idle. It also displays the estimated healthcare cost and annual balance at the current appropriation.
- Review dialogs show exact passage or override thresholds, projected vote outcomes and the estimated fiscal effect before introduction and presidential action.
- The current bill records chamber vote totals and results and presidential action. The record persists through save and load; a new bill starts a new record. Version 21 saves retain their bill stage but have no historic vote details, which are not invented.
- Save validation rejects invalid totals, inconsistent vote outcomes, impossible stage transitions and oversized records before replacing the current world.

## Validation and limits

UI and simulation tests cover stage-aware controls, preview thresholds, vote outcomes, a full signing journey, veto override history, JSON save round-trip, invalid data and older-save migration. All figures and party positions remain fixed fictional examples. Costs are projections based on the current appropriation, which can change before enactment. The old single-chamber path is still separately available; the US-inspired journey does not yet model actual US legislative procedure, appropriations, committees, cloture or elected representatives. Low-end hardware validation remains open.

## Next

Connect laws to a country-specific institutional model, make chamber and party positions scenario-configurable, and give appropriations a separate legislative journey. Add well-sourced content only as its effects and decision process become playable.
