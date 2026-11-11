# Session 40: diplomacy foundation

Two fictional partners have separately tracked bilateral relations and cooldowns. The player can start or cancel one diplomatic negotiation at a time. Talks take 30 days, then increase the chosen relationship by 5 points (capped at 100); completion or cancellation prevents another negotiation with that partner for 90 days. Events and the Diplomacy tab explain progress and outcome. Version-9 saves persist and validate diplomatic state; v1–v8 initialize the fictional defaults. Forecast copies preserve diplomatic state too.

Simulation and UI checks exercise timing, partner selection, simultaneous-talk rejection, cooldown, cancellation, save/load during talks and invalid state. This is an intentionally deterministic placeholder: no negotiation choice, acceptance, treaties, trade, other-country AI, costs or conflict are modeled, and the numbers are not empirical.
