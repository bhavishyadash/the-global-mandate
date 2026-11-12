# Session 110: scenario-specific tax opinions

## Delivered

- Consumption and corporate tax approval sensitivities now belong to each fictional population group instead of a single global table. Scenario data may specify different values by group; positive or negative values permit an increase in a tax to reduce or increase a group's modeled approval.
- The fictional US sandbox and Coastal Republic use distinct illustrative coefficients. They are invented test inputs, not measured public opinion or claims about real income groups. The Population tab displays each modeled direction and magnitude.
- Save format 26 validates these coefficients. Older saves and scenarios with no coefficients receive the previous defaults, preserving prior behavior. Forecasts and replay use the saved or scenario values.

## Validation and limitations

- Tests cover different reactions to the same tax change, both directions of response, invalid and missing current-save values, legacy defaults, forecast isolation and save round trips.
- This is only a simple tax-response prototype, not a model of unique individual personalities, political ideology, real public opinion, or realistic tax behavior. Real calibration, diverse policy responses and broader institutions remain open.
