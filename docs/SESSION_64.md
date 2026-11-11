# Session 64: parliamentary appropriation votes

## Delivered

- Healthcare appropriation changes now require more than 50 of the legislature's 100 seats. The Laws tab previews each party's position, likely votes, annual cost and balance, current-rate rollout and the health target contribution before the player submits the vote.
- Fictional test positions: the government supports its own proposal; Reform supports funding at or below 50%; Opposition supports funding at or above 75%. Support uses current seat counts, including after elections. The player can propose 0%, 25%, 50%, 75% or 100% in the UI.
- A rejected vote leaves the appropriation and cost unchanged and records the result in history; unchanged or invalid proposals are rejected without a vote. A passed vote changes the rate, affecting the next day's fiscal and service calculations. Existing law passage still starts a new law at full funding; it does not require a second initial vote.
- Existing save format 16 is unchanged; saved appropriations remain valid. No recurring renewal, delayed legislative process, lobbying, coalition negotiation or procedural rules are simulated. Party positions and effects are placeholders, and shortfalls are still financed automatically by borrowing.

## Verification and open work

Focused tests cover preview without mutation, party positions and seat totals, a minority-government failed vote, preserved funding, a successful alternative vote and UI behavior. Seven Godot suites passed locally. Actual country institutions, a complete budget process, party preferences grounded in research, and low-end hardware verification remain open.
