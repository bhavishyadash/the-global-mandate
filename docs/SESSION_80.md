# Session 80: US-style governing prototype

## Delivered

- The Government tab now has a US-inspired bicameral healthcare bill. Pick an authorization, introduce it in the House, hold House and Senate votes, and sign or veto as president. A veto may be overridden by a two-thirds vote in each chamber, starting in the House. Reviews precede each action.
- Signing or a successful override changes the existing healthcare policy, annual cost, and subsequent rollout. A failed vote or veto without an override does not enact the proposal.
- The display gives fictional party control and fixed, illustrative support totals. It assumes all 435 representatives and 100 senators vote; normal passage requires a majority and override needs at least two-thirds. Values are not predictions or real legislative data.
- Version 21 saves include the bill stage and funding; older saves start with no active bill. Invalid bill data is rejected before the existing world is replaced. Starting a scenario resets the bill.
- Executive order text distinguishes this prototype's automatic court review from real litigation. Existing single-chamber policy controls remain available as separate fictional prototype paths.

## Sources and design boundaries

The [Congressional Research Service overview](https://www.congress.gov/crs_external_products/R/PDF/R42843/R42843.21.pdf) explains that both chambers must agree to identical text and describes presidential action. Its [veto override procedure](https://www.congress.gov/crs_external_products/RS/PDF/RS22654/RS22654.8.pdf) describes two-thirds of members voting in each chamber and the originating chamber acting first. The prototype always originates this bill in the House and assumes every member votes.

The [National Archives executive-order FAQ](https://www.archives.gov/federal-register/executive-orders/about.html) describes orders as a tool for managing federal operations, and its [Federal Register tutorial](https://www.archives.gov/federal-register/tutorial/text) discusses judicial review of authority. The existing directive simulation is not a US legal model.

This slice omits committees, amendments, House rules, Senate cloture, absences, nominations, the presidential ten-day period, unsigned enactment, pocket vetoes, elections and real party preferences. Authorization directly affects the prototype's annual spending; real appropriations are more complicated. The separate older single-chamber controls can still change healthcare and must not be mistaken for US procedure. No new real-world legal claims or named politicians are simulated. Target-hardware performance validation remains open.

## Next

Unify the separate governing paths under country-specific scenario rules, model appropriations separately, and replace fixed chamber support with researched, scenario-configurable positions before expanding the catalogue.
