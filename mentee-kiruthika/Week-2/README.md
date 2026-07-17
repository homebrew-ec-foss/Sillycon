# Week 2 — Kiruthika Sri

## What this code does
This code generates shapes using Verilog on the VGA output. 
The code divides the screen into tiles and uses distance calculations from the center of each tile to draw shapes. 
It creates diamonds and circles on the screen. The code draws static diamonds on the left half and diamonds morphing into circles over time on the right half with different colors for each. The blending is done using the frame counter.



## Exercises implemented
<!-- Check off what you got working, and briefly note how -->

- [x] Tiling with modulo  -  Divided the screen into tiles using modulo operations.
- [x] Distance metric comparison (Manhattan vs circular-approx)  -  Used the 2 different distance calculations to generate diamond and circle shapes.
- [x] Blending/animating between metrics over time  -  Used frame counter to blend the shapes over time.

## Notes / blockers
I was a little confused about how to blend the two shapes to create a morphing effect and it took some time for me to get it. I also had to understand how the frame counter controls changes over time. I tried changing different tile sizes to find the one that fits the screen properly, as tile size of 64 didn't fit well which I had chosen initially.