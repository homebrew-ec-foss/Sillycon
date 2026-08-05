# Week 4 — Tisya Agarwal

## What this code does
This code is an improvement from the week 3's code.
It combines the button logic, which allows the user to increase the frame rate, and stop the design at a particular frame. This code also allows the user to switch between patterns on a button press.

## Exercises implemented
<!-- Check off what you got working, and briefly note how -->

- [x] Completed week 3's implementations, added different patterns for each button press.
- [x] Use the button to change the frame rate on each press, not just toggle a single state.
- [x] Keep testing incrementally. Get one symmetric segment working first before expanding it into the complete pattern.

## How this works:
By swapping out the old edge-detection setup for direct button inputs, the code gets a lot simpler and way more responsive. Instead of waiting for a button click to trigger a edge on the clock cycle and rotate through modes, it now uses simple, direct logic (always @(*)) that reads the buttons instantly. Giving each of the four kaleidoscope motion modes its own dedicated pin (ui_in[3:0]) makes the controls much more intuitive—you just press the button for the mode you want, and the pattern changes right away without any delay.

## Notes / blockers
None