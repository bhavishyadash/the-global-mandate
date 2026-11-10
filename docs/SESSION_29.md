# Session 29 — preserve parties in test elections

Related to issue #26. Improve the fictional election placeholder so that seats outside the government are distributed between both other parties rather than automatically eliminating one of them. Preserve the total number of seats, test edge cases and disclose the simplified assumptions. A realistic party, voter and electoral-rule model remains future work.

## Result

Government seats still follow rounded national approval. The remaining seats are split between the other two parties in proportion to their previous seats; if both previously held zero seats, the remaining seats are split evenly. Tests cover a normal election, a 100%-government election followed by a 0%-government election, and the 100-seat total. This is not a model of actual votes, turnout, electoral districts or coalition formation, and parties with zero previous seats cannot regain seats except when both other parties had zero.
