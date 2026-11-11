# Session 78: budget breakdown

## Delivered

The **Budget & services** tab now shows a donut chart and matching text table for annual expenses. It uses the five existing fictional spending categories plus separately listed policy costs and debt interest. The chart total therefore equals category spending plus policy costs and interest; it does not add revenue or duplicate any expense. Rows show current and proposed amounts and the selected view's share of the total.

The category selector and amount sit above the chart. Enter an amount and choose **Proposed category** to preview the changed distribution; the preview does not change the simulation. The existing **Apply category** button is the separate action that changes spending. Invalid proposals show an unavailable state, and zero totals avoid division by zero. The text table gives the same information without relying only on color.

Eleven Godot suites pass locally, covering category totals, policy costs, interest, zero totals, invalid proposals, non-mutating previews and UI updates. The packaged game and Windows startup were smoke-tested, and the chart and a Health budget preview were visually checked on the current machine.

## Limitations

The model currently has Health, Education, Security, Infrastructure and Administration categories. It does not yet have separate family-support or defence categories; Security must not be interpreted as a defence budget. Healthcare policy expenditure is included under policy costs rather than added again to the Health category. All figures are fictional. Agency drilldown, wider budget mechanics, full keyboard/accessibility review, 720p layout checks and low-end hardware validation remain open under #119 and related issues.
