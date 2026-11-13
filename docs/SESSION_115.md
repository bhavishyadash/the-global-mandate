# Session 115: Playable US federal fiscal baseline

## Target
Initialize the US sandbox from sourced federal receipts, outlays, Treasury cash and debt. Scale accounting, forecasts, UI and save validation for federal amounts while preserving fictional scenarios and old saves. Avoid double counting interest and document category crosswalks, dates and provisional assumptions. Related to #165 and #159.

## Implemented baseline and provenance
New US games begin 1 October 2025. Population is the Census Vintage 2025 estimate as of 1 July (341,784,857); it is not a measurement on the exact start date. The most recent completed fiscal year is used as the initial annual run rate, not represented as a prediction:

- FY2025 federal receipts: $5,234,617 million; outlays: $7,009,992 million; deficit: $1,775,375 million. Source: Treasury [Combined Statement FY2025](https://fiscal.treasury.gov/system/files/files/reports-statements/combined-statement/cs2025/2025-cs-final.pdf), receipts and outlays summaries. Values are rounded to millions.
- Treasury operating cash at the Federal Reserve: $890,825,093,623, rounded to whole dollars from the September 30, 2025 general ledger in the same statement. This is not the government's total net worth or every financial asset.
- Debt held by the public, excluding accrued interest: approximately $30.2 trillion at September 30, 2025. This excludes intragovernmental holdings and differs from gross debt. Source: [Treasury financial position](https://fiscal.treasury.gov/accounting/us-financial-report/government-financial-position).
- FY2025 net interest: $970,359 million, included in Treasury total outlays. The game subtracts it from total category spending and models it separately, using an implied effective annual rate of FY2025 net interest divided by the approximate debt amount. This is a simplified future interest rule, not an observed marginal rate.

## Provisional category crosswalk
The existing model has five non-interest categories, not Treasury's 19 functions. Amounts below are annual millions. The crosswalk is an engineering aggregation, not a statement of agency budgets, and cannot represent individual programs yet.

| Game category | Millions | Treasury functions grouped |
|---|---:|---|
| Health | 1,975,597 | Health; Medicare |
| Education | 71,014 | Education, Training, Employment, and Social Services |
| Security | 1,378,993 | National Defense; Veterans Benefits and Services; Administration of Justice |
| Infrastructure | 430,980 | General Science, Space, and Technology; Energy; Natural Resources and Environment; Agriculture; Transportation; Community and Regional Development |
| Administration | 2,183,049 | International Affairs; Commerce and Housing Credit; Income Security; Social Security; General Government; Undistributed Offsetting Receipts; $1 million rounding reconciliation |
| Separate interest | 970,359 | Net Interest |

Negative function values and offsets are included in the aggregations. The $1 million adjustment reconciles individually rounded functions to Treasury's reported total. Administration is a temporary residual grouping, not an estimate of administrative overhead; Health is federal budget-function outlays, not nationwide healthcare expenditure. Resetting the total currently replaces these shares with fictional defaults and is explicitly warned in the interface.

## Validation and remaining limitations
- Fiscal amounts scale to federal size in scenario validation, previews, save/load and shared-world forecast. Existing saves and fictional scenarios retain their former fiscal assumptions.
- The service baseline is initialized so the existing toy service score is neutral at starting spending and population; this 50/100 score is invented, not a measured service level. Future service, approval, interest and economic behavior remains simplified.
- The 20% flat income-tax setting, taxable bases, tax response, political parties, approval, population groups and many other values are placeholders, not sourced US facts. GDP, unemployment and all real laws are not yet playable simulation inputs. Population growth is temporarily disabled. State and local government budgets and many real-world indicators remain absent. Therefore the request to import all real-world data is not complete.
- Verified all 14 Godot suites, accounting reconciliation and packaged-resource startup; the existing world-lab test was corrected to handle crossing a calendar year.
