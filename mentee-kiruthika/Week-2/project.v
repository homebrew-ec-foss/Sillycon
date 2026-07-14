/*
 * Week 2 starter — blank VGA wrapper
 * This is just the boilerplate every VGA Playground design needs.
 * Your job: implement the Week 2 exercises inside this file.
 * Do NOT touch hvsync_generator — treat it as a black box that
 * hands you pix_x, pix_y, and tells you when it's safe to draw.
 */

`default_nettype none

module tt_um_vga_example(
  input  wire [7:0] ui_in,    // Dedicated inputs (buttons)
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path
  input  wire       ena,      // always 1 when powered
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD pin mapping — leave as is
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, uio_in};

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  // ---------------------------------------------------------
  // TODO: Week 2 exercises — Evolving tiled shapes building blocks
  //
  // 1. Tile the screen using pix_x % N, pix_y % N (pick some tile
  //    size N, e.g. 32 or 64). Draw one simple shape inside each
  //    tile (a filled square is fine to start) and confirm it
  //    repeats across the whole screen.
  //
  // 2. Implement two distance metrics from the center of a tile:
  //      - Manhattan distance: |dx| + |dy|
  //      - Circular-ish approx (like Rings uses): max(|dx|,|dy|)
  //        + min(|dx|,|dy|)/2
  //    Compare the shapes each one produces — one should look more
  //    diamond-like, the other more circular.
  //
  // 3. Use the frame counter to blend/interpolate between two
  //    thresholds or between the two metrics above, so the shape
  //    visibly changes over time. This is your "morph" mechanic
  //    in miniature.
  //
  // Get each one working and visibly correct before moving to the
  // next — it's fine if the screen looks very simple while testing.
  // ---------------------------------------------------------

  assign R = video_active ? 2'b00 : 2'b00;
  assign G = video_active ? 2'b00 : 2'b00;
  assign B = video_active ? 2'b00 : 2'b00;

endmodule
