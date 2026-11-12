# Session 88: lab cooperation agreements

## Delivered

- World Lab can now choose basic dialogue or a cooperation proposal, preview the fictional rules and current eligibility, start talks, and cancel them. Talks take 30 lab days; eligibility is rechecked at completion.
- Dialogue adds 5 relationship points without a direct charge. Cooperation requires a relationship of at least 5 and $5 million in each country's treasury at completion. When accepted, each pays a one-time $5 million, the cost is recorded in each fiscal ledger, relations gain 10 points, and the agreement lasts 365 days. No recurring payments, trade benefit, automatic renewal or real-world estimate is modeled. Ineligible cooperation is declined without a charge.
- Agreements expire and are recorded in both countries' event histories. A current agreement prevents another cooperation negotiation for the same pair; dialogue remains possible. Talks can be cancelled without an agreement.
- World registry save version 2 stores negotiation type and agreements. Version 1 saves migrate in-progress talks as dialogue. Invalid agreement or negotiation data is rejected before replacing the running lab world.
- Tests cover acceptance, relation and treasury rejection, cancellation, exact one-time cost and fiscal recording in both countries, expiration, duplicate prevention, JSON save/load and version 1 migration. The lab and main single-country diplomacy systems remain separate.

## Limits and next work

These rules, countries, amounts and outcomes are fictional. Agreement effects are intentionally narrow and do not represent actual trade, security guarantees or diplomatic behavior. The main game, main map and lab still have separate worlds and clocks. Low-end hardware performance remains unverified.

Next: connect the separate country models through a migration-safe unified world and add meaningful country control, broader diplomacy and sourced data without confusing lab values with real-world figures.
