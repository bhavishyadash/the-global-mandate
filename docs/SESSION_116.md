# Session 116: Deficit-led fiscal model

## Target
Replace cash-first budgeting with deficit/surplus and debt mechanics; incorporate a sourced FY2026 annual US baseline; update decisions, shared world, forecasts, UI, saves and regression coverage. Related to #167.

## Completed
- Budget deficits are funded by borrowing as they accrue, rather than using a cash balance first. A surplus repays debt up to zero; any surplus after debt reaches zero is not accumulated because the prototype no longer models cash assets. One-time shared cooperation costs are charged to debt and the fiscal ledger.
- The main status, map, deficit history and previews show deficit as a share of GDP where GDP is available. An annual deficit is a run rate under current settings; a forecast period deficit is cumulative for that period divided by annual GDP. Negative values indicate surplus. Other scenarios without sourced GDP show a dollar fallback.
- FY2026 receipts $5,403.3 billion, outlays $7,395.8 billion and deficit $1,992.5 billion come from the [US Economic Indicators table](https://www.govinfo.gov/content/pkg/ECONI-2026-10/pdf/ECONI-2026-10.pdf), which cites the Final Monthly Treasury Statement. Public debt of $32,245.4 billion is from the same table.
- GDP is $33,010 billion, the BEA advance estimate for Q3 2026 at a seasonally adjusted annual rate, as presented in the same publication. Starting annual deficit / this quarterly annualized GDP = 6.04%. This mixes FY2026 fiscal totals and Q3 annualized GDP. [CBO's FY2026 report](https://www.cbo.gov/publication/61986) instead reports a 6.2% ratio using fiscal-year GDP; they are different denominators. The simulation starts November 12, 2026, the snapshot date.
- The deficit percentage updates as game decisions or modeled debt interest change. GDP is held fixed: no live internet feed or GDP growth model is implemented. The initial population is the July 2025 Census estimate, not a November 2026 population observation.
- FY2026 spending groups are provisional: Medicare and Medicaid in Health; Education Department in Education; Defense military and Veterans Affairs in Security; EPA, HUD and Commerce in Infrastructure; remaining noninterest outlays in Administration. CBO program figures are rounded to billions; the residual includes Social Security and other programs and is not administrative overhead. Net interest on public debt of $1,142 billion is separate; it differs from broader net interest outlays.
- Save version 27 loads old saves; their existing cash field is preserved as inert legacy data and no longer used to fund spending. Old saves do not automatically receive new GDP or FY2026 figures. Interest is a simplified effective rate, and tax rates, many laws and behavioral effects remain placeholders. The fiscal ledger still uses calendar-year boundaries, not the US October fiscal year.

## Checks
14 Godot regression suites cover debt borrowing/repayment, changing spending and tax deficits, GDP ratio, existing save compatibility, shared-world charges, forecasts and UI. Packaged resources and Windows build are checked separately.
