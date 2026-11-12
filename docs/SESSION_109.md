# Session 109: reconciled population groups

## Delivered

- The Population screen now allocates whole people to the three existing fictional income groups using their fixed shares. The counts sum to the national population, including after demographic changes; fractional remainders use a deterministic group-order tie break.
- The UI explains that these are allocations from fixed shares, while approval still uses the original unrounded shares. It does not claim the model tracks individual people or changes in income distribution.
- No save format or simulation behavior changed. If a population exceeds the demographic model's supported bound or group shares are invalid, the count display reports unavailable instead of inventing an allocation.

## Validation and limitations

- Tests cover zero and small populations, deterministic ties, large supported populations, shares within the existing tolerance, invalid inputs and exact reconciliation. Existing population and UI checks remain in the suite.
- Group shares, personalities, age, employment and income mobility are not simulated. Rates and approval sensitivities remain fictional placeholders; real-data calibration and low-end hardware validation remain open.
