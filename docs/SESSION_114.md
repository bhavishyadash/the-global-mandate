# Session 114: Sourced US starting population

## Target
Use the Census Vintage 2025 population estimate and its July 1, 2025 reference date in the playable US scenario, clearly label remaining fictional models, preserve old saves, and avoid claiming invented growth rates are real. Related: #163, #39, #159.

## Completed
- New US games start July 1, 2025 with 341,784,857 residents, matching the packaged Census Vintage 2025 reference. Source: https://www.census.gov/quickfacts/fact/table/US/PST045222
- Birth, death and migration rates are zero as a temporary disabled model, not real-world rates. UI identifies the mixed-data scenario and explains the limitation.
- The shared-world lab aligns its fictional partner to the US scenario date. Prior saves retain their own population, date and demographics. Tests check source consistency, forecasts, shared-world compatibility and save/load.

## Remaining and limitation
- Population is the only newly integrated observed simulation input. Federal revenues, outlays, deficit, debt, GDP, health funding, politics and other data remain fictional or reference-only; the user's complete-data request is not satisfied.
- The existing service model was calibrated to 10 million people with fictional $1.1 billion spending. With the sourced population and unchanged fictional budget, its service projections are not credible. Federal-scale accounting and service calibration are open under #159.
- Real demographic growth and projections require sourced rates with dates, uncertainty and consistent definitions. Existing saves are not silently overwritten.
