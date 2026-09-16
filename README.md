# Sillycon: Direct Hardware Graphics Generator

Most digital graphics rely on a CPU, GPU, and operating system. Sillycon explores a different approach: can a microchip generate dynamic visual art directly from hardware logic? Built in Verilog HDL for Tiny Tapeout, Sillycon generates the colour of each pixel in real time using pixel coordinates, mathematical geometry, counters and hardware logic, and outputs the result directly to a VGA display.

## How It Works

- **VGA Timing Logic:** Tracks the current pixel coordinates (640 × 480 at 60 Hz) and generates sync signals.
- **Coordinate Math:** Treats shape centers as local (0,0) origins to calculate geometry dynamically per pixel.
- **Animation & Interaction:** Frame counters control movement and colour changes, while button inputs allow the artwork to respond to the user.

## Kaleidoscope

Creates an interactive eight-fold kaleidoscope pattern directly in hardware. The design uses coordinate transformations and symmetry to generate repeating geometric patterns across the screen, while hardware counters and button inputs add movement and interaction. The graphics are generated pixel by pixel as the VGA display is refreshed, with the pattern continuously changing in real time.

**Controls:** Each of the first four buttons selects a different animation mode — Normal, Pulse, Spin, or Shimmer. The ui_in[5:4] inputs control the animation speed, with options for normal, fast, slow, and freeze.

Interested in how the kaleidoscope was built? [Click here to explore the project](https://github.com/homebrew-ec-foss/Sillycon/tree/main/mentee-tisya) 

## Demo
<img width="800" height="800" alt="final" src="https://github.com/user-attachments/assets/79b21142-0483-4b32-adf6-3c403b44beac" />



## Evolving Tiled Pattern Animation

Explores how a pattern can change its form over time. The screen is divided into 80 × 80 pixel tiles, with shapes generated using coordinates relative to the center of each tile. The animation evolves through four phases — **Triangles → Triangle-to-Diamond Morph → Diamonds → Ripples** — using frame counters, coordinate offsets and distance calculations to control the movement, morphing and colour effects. A button is used to switch between the different animation phases.

**Controls:** Press the ui_in[0] button to cycle through the four animation phases.

Interested in how the animation was built? [Click here to explore the project](https://github.com/homebrew-ec-foss/Sillycon/tree/main/mentee-kiruthika)  

## Demo

https://github.com/user-attachments/assets/5d566085-4b79-4995-92a7-235599003a34


## Try It Yourself

Curious to see the hardware-generated graphics for yourself? Copy the Verilog code from the project, paste it into the [Tiny Tapeout VGA Playground](https://vga-playground.com/), and run it to see the design come to life on the VGA display.

## Technical Stack

- **Language:** Verilog HDL (Register Transfer Level)
- **Target Architecture:** Tiny Tapeout / OpenLane ASIC Flow
- **Simulation Tool:** Tiny Tapeout VGA Playground
- **Output Standard:** VGA Video Output (640 × 480 @ 60 Hz)
