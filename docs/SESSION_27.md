# Session 27 — procurement policy budget effect

Related to issues #10 and #25. Give the fictional procurement policy a documented recurring implementation cost after completion, include it in budget projections and show it to the player before and after adoption. Test implementation timing, accounting and save/load. The broader accounting and agency models remain open.

## Result

The prototype displays a fictional $10 million annual cost for procurement before the vote. Once implementation reaches 100%, the cost appears separately from base spending and reduces the annual budget balance and spending preview; daily accrual starts on the next simulated day. It is derived from saved policy state, so older saves with completed implementation acquire the new cost when loaded. Local tests verify day 99/100, budget and preview calculations, and restored completed policy state. The cost is a placeholder: benefits, procurement contracts and economic effects remain unmodeled.
