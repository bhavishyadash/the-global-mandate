# Session 34 — executive action and judicial review

Related to issues #21, #23, #24, #25, #45 and #48. Build a fictional executive-directive lifecycle with different authority cases, agency implementation, automatic court review and injunction, revocation, events, UI explanation and versioned save migration. Test each outcome and save/load at intermediate stages. This is a test framework, not a representation of any actual country's laws or a complete court system.

## Result

- The player can issue one of two fictional directives while no other directive is active, and revoke an active directive. The UI describes the selected case, assumed authority, review timing, status and agency progress.
- The reporting directive is assumed within authority: it is upheld on day 30 and reaches full implementation on day 60. The fictional spending-limit override is assumed outside authority: an injunction stops implementation on day 10 and the court strikes it down on day 30. These outcomes and dates are deterministic test rules, not legal findings or real-country data.
- Institutional changes are recorded in the event log. Version-7 saves persist and validate the lifecycle; older saves initialize with no directive. Invalid and inconsistent institutional data is rejected before replacing live state.
- Local simulation, UI and integrated Godot checks passed for issuance restrictions, both court outcomes, injunction progress, revocation, save/load during an injunction, v6 migration and invalid-state rejection.

The directives currently have no budget, economic, public-opinion, legal challenge, appeal or other gameplay effects beyond their lifecycle. Courts are deterministic and do not model actual jurisdictions. Visual playtesting remains outstanding.
