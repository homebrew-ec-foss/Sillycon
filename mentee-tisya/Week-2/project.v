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
  // TODO: Week 2 exercises — Kaleidoscope building blocks
  //
  // 1. Center pix_x/pix_y around the screen middle (signed subtraction).
  //    Verify by coloring the left half one color and the right half
  //    another, based on the sign of your centered x coordinate.
  //
  // 2. Mirror the centered coordinates across one axis (sign-check +
  //    conditional negate), then try mirroring across a second axis.
  //    You should see a pattern become symmetric.
  //
  // 3. Detect a single clean press on ui_in[0] — edge detection,
  //    not level. (Careful: naively checking "if ui_in[0] is high"
  //    will keep triggering the whole time the button is held down,
  //    not just once per press.) Use the press to toggle something
  //    visible, e.g. swap which color channel is active.
  //
  // Get each one working and visibly correct before moving to the
  // next — it's fine if the screen looks very simple while testing.
  // ---------------------------------------------------------

  assign R = video_active ? 2'b00 : 2'b00;
  assign G = video_active ? 2'b00 : 2'b00;
  assign B = video_active ? 2'b00 : 2'b00;

endmodule
