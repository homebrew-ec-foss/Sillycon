# Week 3 — Tisya Agarwal

## What this code does
This code is an improvement from the week 3's code.
It combines the button logic, which allows the user to increase the frame rate, and stop the design at a particular frame.

## Exercises implemented
<!-- Check off what you got working, and briefly note how -->

- [x] Completed week 3's implementations.
- [x] Use the button to change the frame rate on each press, not just toggle a single state.
- [x] Keep testing incrementally. Get one symmetric segment working first before expanding it into the complete pattern.

## How this works:
The button control logic directly inspects the input state of the ui_in pins during every vertical frame refresh to modify animation behavior on the fly. Reading ui_in[0] determines whether the frame counter increments or decrements, reversing the rotation vector between outward expansion and inward collapse—while ui_in[2:1] acts as a speed selector by altering both the step size added to the frame counter and the specific register bits assigned to calculate the pattern's twist offset.

## Notes / blockers
None