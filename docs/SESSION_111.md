# Session 111: US official-data baseline

## Target
Build a dated, sourced US historical reference with Treasury's full FY2025 federal budget-function breakdown, Census population, and economic indicators. Present it offline in the game, clearly separated from fictional simulated values. Validate the accounting and export packaging.

## Boundaries
The current simulation is not calibrated to federal-scale finances, progressive taxation, or federal spending functions. Historical observations must not silently replace game inputs until those systems support them. Record sources, scope, periods, and limitations. Related: #157, #38, #39, #10, #119.

## Completed
- Added an offline US Reference tab and a machine-readable dataset with source links, scope and dates.
- Census Vintage 2025 population is an estimate as of July 1, 2025. BEA GDP and BLS unemployment cover calendar 2025; Treasury figures cover federal fiscal 2025. These periods are not interchangeable.
- Treasury reports receipts, outlays and budget functions rounded to millions; their function sum differs from reported total by $1 million. Interest is already included in outlays and two functions are negative net offsets.
- Validation rejects malformed datasets, duplicate functions and accounting inconsistencies. The Windows export includes and smoke-checks the reference.
- All 14 Godot regression suites passed.

## Remaining
- This is historical reference data, not an authoritative inventory of everything or a current live feed. The existing US sandbox and its demographic rates, tax bases, spending, parties and opinions remain fictional.
- The budget engine requires federal-scale values, a real tax structure, an appropriate functional expenditure model and non-duplicated interest accounting before these figures can drive gameplay. GDP, unemployment, debt, state/local budgets, population composition and many other series need integration and/or sourcing.
- Treasury and BEA figures can be revised; preserve publication vintage and review source terms before broad data redistribution. Target hardware testing remains open.
