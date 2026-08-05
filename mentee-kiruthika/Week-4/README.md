# Week 4 — Kiruthika Sri

## What this code does
This code builds on the Week 3 implementation. It adds the remaining animation stages, button-controlled phase switching, and combines everything into one complete animation sequence.

## How does this work
The design is divided into four animation phases that are selected using a button. Each button press moves to the next phase, while separate counters control the timing of the animations within each phase. During the morph stage, a column-based delay makes the transformation spread across the screen like ripple effect. The diamond shape is generated using the Manhattan distance (abs_dx + abs_dy), while an approximate circular distance (max(abs_dx, abs_dy) + min(abs_dx, abs_dy)/2) is used for the ripple animation. The same distance values used for shape generation are reused for the color animation, allowing the colors to spread outward from the center of the diamond as the animation progresses.

## Exercises implemented
- [x] Finished the triangle-to-diamond morph and added a separate diamond animation phase.
- [x] Used the button input (ui_in) to switch between the different animation phases.
- [x] Added column-based offsets so the morph happens across the screen instead of all at once.
- [x] Used distance calculations to generate the diamond colors instead of fixed colors.
- [x] Added the ripple animation at the end of the sequence.

## Notes / blockers
Faced some difficulty while implementing the ripple phase and combining all the animation stages together. Creating the ripple effect required adjusting the distance calculations and making sure the rings appeared correctly. Making all the phases work together smoothly also required multiple tries and adjustments.