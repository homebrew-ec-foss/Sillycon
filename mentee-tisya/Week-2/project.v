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

  // Task 1
  
  wire signed [10:0] x_in = $signed({1'b0, pix_x}); // Making x a signed number so we can do negative math
  wire signed [10:0] y_in = $signed({1'b0, pix_y}); // Making y a signed number so we can do negative math

  wire signed [10:0] x_mid = x_in - 11'sd320; // Shifting x so the middle of the screen (320) becomes our new 0 (left is negative, right is positive)
  wire signed [10:0] y_mid = y_in - 11'sd240; // Shifting y so the middle of the screen (240) becomes our new 0 (top is negative, bottom is positive)
  // 11'sd320 and 11'sd240 signify 11 bit long signed decimals so that the wires have enough capacity to work with the long signed decimal numbers. 
  
  wire left_side = (x_mid < 0);

  // Task 2

  wire [9:0] x_abs = (x_mid < 0) ? -x_mid : x_mid;
  wire [9:0] y_abs = (y_mid < 0) ? -y_mid : y_mid;
  wire draw = (x_abs[5] == 1'b1) || (y_abs[5] == 1'b1);

  // Task 3
  
  reg btn_old; 
  reg state;   

  always @(posedge clk) begin
  if (rst_n == 1'b0) begin
  btn_old <= 1'b0;
  state   <= 1'b0;
  end else begin
      
  if (ui_in[0] == 1'b1 && btn_old == 1'b0) begin
  state <= ~state; 
  end
      
  btn_old <= ui_in[0]; 
  end
  end

  wire b_on = (left_side == 1'b1) || (draw == 1'b1);
  wire r_on = (state == 1'b0) ? ((left_side == 1'b1) || (draw == 1'b0)) : ((left_side == 1'b0) || (draw == 1'b1));
  wire g_on = (state == 1'b0) ? ((left_side == 1'b0) || (draw == 1'b1)) : ((left_side == 1'b1) || (draw == 1'b0));

  assign R = (video_active && r_on) ? 2'b11 : 2'b00;
  assign G = (video_active && g_on) ? 2'b10 : 2'b00;
  assign B = (video_active && b_on) ? 2'b10 : 2'b00;


endmodule
