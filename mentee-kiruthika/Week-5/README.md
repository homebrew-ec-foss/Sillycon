# Week 5 — Kiruthika Sri

## Evolving Tiled Pattern Animation

## What this project does

This project creates a procedural tiled pattern animation using Verilog on a VGA display. The shapes are generated using pixel coordinates, tiling and distance calculations. Frame counters control the animation, and a button is used to switch between the different phases.

## How does this work

The screen is divided into 80×80 pixel tiles. For each pixel, its position is converted into coordinates relative to the center of its tile. These coordinates are then used to calculate whether the pixel belongs to a particular shape. The animation has four phases. The triangle phase has growing, pulsating and drifting triangles with moving color bands. Then the triangle to diamond morph has a column-based delay, which makes the morph happen at different times across the screen. The diamond phase has pulsating diamonds and colours moving outward from the center. The diamond shape is generated using the Manhattan distance from the center of the tile. The same distance is also used to create the colour wave inside the diamonds. Finally, an approximate circular distance is used to create expanding ripple rings. Frame counters control the timing of the different animations. A button press changes the animation phase.

## Exercises implemented

- [x] Tiling the screen using modulo. 
- [x] Triangle growth, pulsation, drifting and moving colour bands.
- [x] Column-based offsets for a wave-like animation effect.
- [x] Morphing triangles into diamonds over time.
- [x] Diamond pulsation with column-based timing.
- [x] Distance-based colour movement across the diamonds.
- [x] Expanding ripple rings using approximate circular distance.
- [x] Button-controlled switching between the different animation phases.

## Demo


https://github.com/user-attachments/assets/4d49e051-a272-4337-aded-cee3e9d203c4


## Notes / blockers

The main challenge was combining all the animation stages and making their timing work properly. I had some difficulty with the distance calculations, frame counters and the triangle to diamond morph. The ripple effect also needed several adjustments to make the rings appear correctly. I tested the different parts separately before combining them into the final animation. In the end, all four phases were working together and the button could be used to switch between them.
