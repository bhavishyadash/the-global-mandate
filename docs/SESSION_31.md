# Session 31 — government budget foundation

Related to issues #10, #11, #12, #17, #45 and #48. Build a substantial, playable budget layer: separate spending categories, transparent recurring policy and debt-interest costs, cash and debt accounting, decision previews and versioned save migration. Preserve the existing fictional tax and approval behavior until replaced by a researched model. Test budget invariants, category changes, borrowing, repayment, save compatibility and integrated gameplay. These broad issues remain open until their full requirements are met.

## Result

- The initial annual spending budget is split among health, education, security, infrastructure and administration. The player can preview and change individual categories, or reset the total using the initial shares. Category totals must match aggregate spending.
- Revenue is displayed as the fixed-base test income tax and other revenue; the tax model itself is unchanged.
- The budget displays cash, debt, policy cost and a fictional 3% annual debt interest rate. Daily deficits spend cash and then borrow; surpluses repay debt before increasing cash. Interest changes with debt, and the balance is an annualized current-rate estimate, not a prediction of the year-end result.
- Version-4 saves include debt and category budgets. Older saves split their existing spending into fictional default shares; negative treasury balances become debt. Those derived categories are migration assumptions, not historical records.
- Local Godot simulation, UI and integrated scenario checks passed. Coverage includes category validation, non-mutating preview, borrowing, repayment, interest, v3 migration and rejection of inconsistent v4 categories.

This remains an intentionally simplified fictional model. There are no public-service effects, debt maturity, credit limits, taxes beyond the test income tax, or economic feedback from spending. Visual layout and manual playtesting still need review.
