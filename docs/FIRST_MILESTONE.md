# First milestone: executive action and institutional response

## Goal

Build a playable, testable simulation of a fictional US-style federal republic. A player proposes an executive action and sees its legal, political, administrative and public consequences develop over time. This is an initial model, not a complete or definitive account of US law.

## Player loop

1. Select a proposed executive action, read its claimed authority and expected effects.
2. Review the policy, affected agencies, expected costs and potential opposition.
3. Issue the order or abandon it; advance the calendar.
4. Observe agency implementation, legislative response, possible litigation, court decisions and changing group opinions.
5. Amend or revoke the order, respond politically, and save or reload the scenario.

## First scenario

An executive directs federal procurement agencies to prefer qualifying domestic suppliers where existing procurement authority permits. The scenario is fictional and designed for testing. Its practical effect is bounded by statutory authority, procurement rules, existing contracts, appropriations, agency capacity and review. Whether a specific real-world order is legal depends on its text and circumstances.

Possible outcomes include agency compliance, administrative delays, procurement cost changes, industry support or opposition, court challenge and legislative response. None is automatic: record the assumptions behind each modeled effect.

## Simulation components

- World clock: deterministic day steps, pausing and speed controls.
- Country state: treasury, executive, legislature, judiciary, agencies, subnational governments and population groups.
- Policy catalog: versioned definitions with action type, authority, preconditions, implementation path, cost assumptions and effects.
- Decision lifecycle: proposed, issued, challenged, suspended, implemented, amended or revoked; distinguish status from implementation progress and litigation.
- Institutions: executive authority; legislative oversight and funding; courts and remedies; agency capacity and compliance.
- Population groups: distinct interests, private views, expressed support and confidence in institutions. Avoid treating any group as politically uniform.
- Event log: show what happened, when, and the modeled factors behind it.
- Persistence: versioned saves, deterministic random seed and reproducible actions.

## Test requirements

- A decision cannot exceed the scenario's modeled authority without an explicit challenge or other modeled consequence.
- Implementation occurs over time and respects agency capacity and funding; issuance is not instant compliance.
- Suspension stops the affected implementation while the order remains in effect pending a decision; revocation stops future implementation without erasing prior effects.
- Expenditures reconcile with the treasury and budget assumptions.
- Population groups can respond differently to the same action; public expression may differ from private opinion.
- Given the same starting state, seed and decisions, results reproduce; save and reload preserve the outcome.
- Long runs do not produce impossible population, invalid finances or unbounded values.

## Expansion after the first loop

Add a legislative proposal and budget process, then model more country systems with configurable institutions and carefully researched country-specific rules. Build actual-country scenarios with dated, sourced starting data and explicit uncertainty. A fuller GPS feature inventory remains a separate workstream.

## Decisions for direction

- Map presentation: flat map, globe or another view.
- First-country scope: real country data or fictional test scenario first.
- Target PC specifications and desired simulation speed.
- Engine choice after inspecting the actual Godot project and available toolchain.
