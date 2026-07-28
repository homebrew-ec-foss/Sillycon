# Week 3 — Kiruthika Sri

## What this code does
This code creates a tiled pattern of triangles on the VGA display and animates them over time. First the triangles grow onto the screen, then they start pulsating, after a while they slowly drift across the screen, finally display moving rainbow stripes across the triangles. A smaller inner triangle keeps pulsating throughout the animation.

## How does this work
The screen is divided into 80×80 pixel tiles using modulo, and each tile draws a triangle using coordinates relative to the tile centre. A frame counter controls when each animation starts and ends. Different counters and offsets are then used to make the triangles grow, pulse, drift across the screen and change colours before returning to their normal state.

## Exercises implemented
- [x] Build on your Week 2 work (tiling, distance metrics, morph blending) towards your original project pitch. 
- [ ] Make the project interactive. Use the button to control the animation phases instead of relying only on the frame counter.
- [x] Added a column-based pulse offset to create a wave-like effect across the tiled pattern. (Similar to the additional exercise, but applied to the pulse animation instead of the morph this week)

## Notes / blockers
I implemented the triangle animation with different animation stages. I had some difficulty implementing a few parts of the code, but eventually I understood them. I tested each feature separately before combining them. For now, the project runs as one continuous animation and the interactivity is yet to be added.