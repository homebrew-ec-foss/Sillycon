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



  // Task-1 : Tiling the screen with squares
  wire [5:0] tile_x;
  wire [5:0] tile_y;

  assign tile_x = pix_x % 80;
  assign tile_y = pix_y % 80;

  // wire square;
  // assign square = (tile_x >= 6 && tile_x < 34 && tile_y >= 6 && tile_y < 34);

  // assign R = video_active && square ? 2'b10 : 2'b00;
  // assign G = video_active && square ? 2'b01 : 2'b00;
  // assign B = video_active && square ? 2'b01 : 2'b00;



  // Task-2 : Implement two distance metrics from the center of a tile and compare

  // Diamond
  wire signed [6:0] dx;
  wire signed [6:0] dy;

  assign dx = tile_x - 40;
  assign dy = tile_y - 40;

  wire [5:0] abs_dx;
  wire [5:0] abs_dy;

  assign abs_dx = dx < 0 ? -dx : dx;
  assign abs_dy = dy < 0 ? -dy : dy;

  wire [6:0] dist_diamond;
  assign dist_diamond = abs_dx + abs_dy;

  wire diamond;
  assign diamond = (dist_diamond < 20);

  // Circular
  wire [5:0] max;
  wire [5:0] min;

  assign max = (abs_dx > abs_dy) ? abs_dx : abs_dy;
  assign min = (abs_dx > abs_dy) ? abs_dy : abs_dx;

  wire [6:0] dist_circle;
  assign dist_circle = max + (min / 2);

  wire circle;
  assign circle = (dist_circle < 20);

  wire diamond_pix;
  wire circle_pix;

  assign diamond_pix = (pix_x < 320) && diamond;
  assign circle_pix  = (pix_x >= 320) && morph;

  assign R = video_active && diamond_pix ? 2'b10 : video_active && circle_pix ? 2'b11 : 2'b0;
  assign G = video_active && diamond_pix ? 2'b10 : video_active && circle_pix ? 2'b01 : 2'b00;
  assign B = video_active && diamond_pix ? 2'b11 : video_active && circle_pix ? 2'b01 : 2'b01;



  // Task-3 : Use the frame counter to blend/interpolate

  reg [9:0] counter;

  always @(posedge vsync or negedge rst_n) 
  begin
    if (~rst_n)
      counter <= 0;
    else
      counter <= counter + 1;
  end

  wire [3:0] blend;
  assign blend = counter[5:2];

  wire [10:0] dist_morph;
  assign dist_morph = ((15 - blend) * dist_diamond + blend * dist_circle) / 15;  

  wire morph;
  assign morph = (dist_morph < 20);                

endmodule

