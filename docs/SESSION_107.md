# Session 107: fictional demographic population flows

## Delivered

- Added deterministic daily birth, death and net-migration flows driven by scenario-defined annual rates per 1,000 people. Integer accumulators preserve fractional people across days and 365/366-day boundaries; population cannot fall below zero or rise above the model's supported bound of 10 billion.
- The fictional US sandbox and Coastal Republic have different illustrative rates. These values are placeholders, not US or real-world statistics. The original federal test scenario remains static because it has no population rules.
- Population affects the existing per-capita service calculations. Group shares and modeled tax bases remain fixed. No age structure, fertility choices, migration policy, labor market, mortality causes, disasters or individual behavior are modeled.
- Save format 24 validates and stores rules and integer remainders. Older saves migrate to zero rates to preserve their prior static-population behavior; new scenario starts use scenario rates. Forecasts copy the demographic state, and the Population tab and fiscal forecast expose the modeled values.

## Validation and limitations

- Dedicated tests cover conservation, positive and negative migration, fractional accumulation in normal and leap years, rate bounds, zero and maximum population, save/reload continuity, old-save migration, invalid-state rejection, deterministic replay and forecast isolation. Existing shared-world, integration and stress tests remain in the suite.
- Rates are not calibrated, and direct real-world claims cannot be drawn from them. Population composition, regional variation, realistic data sources and uncertainty remain future work. Target-hardware performance remains unverified.

- Synthetic headless benchmark on this machine with fictional demographic rates enabled: 200 countries over 365 days had 5.305 ms p95 and 7.782 ms maximum tick time. Run `benchmark_registry.gd -- --dynamic-population` to reproduce the workload. This is not a low-end hardware, rendering, multi-year or full-game performance guarantee.
