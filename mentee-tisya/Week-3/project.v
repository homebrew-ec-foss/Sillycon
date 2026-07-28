

`default_nettype none

module tt_um_kaleidoscope (
    input  wire [7:0] ui_in,    // not using this i think
    output wire [7:0] uo_out,   // this is the vga output pins
    input  wire [7:0] uio_in,   // not using
    output wire [7:0] uio_out,  // not using
    output wire [7:0] uio_oe,   // not using
    input  wire       ena,      // not using
    input  wire       clk,      // the clock, needed for everything
    input  wire       rst_n     // reset button i guess, active low (means 0 = reset??)
);

  assign uio_out = 8'b00000000;
  assign uio_oe = 8'b00000000;

  
  wire reset;
  assign reset = ~rst_n;

  

  
  wire hsync;
  wire vsync;
  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;

  hvsync_generator hvsync_gen (
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  
  
  reg vsync_last;
  reg [15:0] frame_count;

  always @(posedge clk) begin
    if (reset) begin
      vsync_last <= 0;
      frame_count <= 0;
    end else begin
      vsync_last <= vsync;
      // check if vsync just went from 0 to 1 (new frame started)
      if (vsync == 1 && vsync_last == 0) begin
        frame_count <= frame_count + 1;
      end
    end
  end

  
 
  
  reg signed [10:0] dx;
  reg signed [10:0] dy;

  always @(*) begin
    dx = hpos - 320;
    dy = vpos - 240;
  end

  
  // mirroring part
  // basically flip everything into positive numbers first (absolute value)
  // then also flip so the bigger one is always first
  // this makes it repeat 8 times around like mirrors in a real kaleidoscope
  // i found this trick online and kind of just copied it, still dont 100% get why it works
  
  reg [9:0] abs_dx;
  reg [9:0] abs_dy;

  always @(*) begin
    if (dx < 0)
      abs_dx = -dx;
    else
      abs_dx = dx;

    if (dy < 0)
      abs_dy = -dy;
    else
      abs_dy = dy;
  end

  reg [9:0] u;
  reg [9:0] v;

  always @(*) begin
    if (abs_dy > abs_dx) begin
      u = abs_dy;
      v = abs_dx;
    end else begin
      u = abs_dx;
      v = abs_dy;
    end
  end

  
  // higher bits = too slow, lower bits = too fast/flickery
  
  wire [3:0] twist_amount;
  assign twist_amount = frame_count[11:3];

  
  // to make the pattern
  // radius = rough distance from center (not the real math distance, too
  // complicated, this is just an approximation that looks close enough)
  // rings = bands based on radius, plus the twist so it moves
  // facet = some xor stuff to make it look like cut glass, honestly just
  // messed with numbers until it looked cool
  
  reg [9:0] radius;
  reg [3:0] ring_num;
  reg [3:0] facet_num;
  reg [3:0] pattern_num;

  always @(*) begin
    radius = u + v;
    ring_num = radius[8:5] + twist_amount;
    facet_num = u[6:3] ^ v[6:3];
    pattern_num = ring_num ^ facet_num;
  end

  
  // turn the pattern number into a color
  // just picked colors that looked like a rainbow / jewel kind of vibe
  // only have 2 bits per color (4 levels) because thats all the vga pmod
  // pins can do, wish i had more but it still looks decent

  reg [1:0] red_out;
  reg [1:0] green_out;
  reg [1:0] blue_out;

  always @(*) begin
    if (pattern_num == 0) begin
      red_out = 2'b11; green_out = 2'b00; blue_out = 2'b00; // red
    end else if (pattern_num == 1) begin
      red_out = 2'b11; green_out = 2'b10; blue_out = 2'b00; // orange
    end else if (pattern_num == 2) begin
      red_out = 2'b11; green_out = 2'b11; blue_out = 2'b00; // yellow
    end else if (pattern_num == 3) begin
      red_out = 2'b01; green_out = 2'b11; blue_out = 2'b00; // yellow green
    end else if (pattern_num == 4) begin
      red_out = 2'b00; green_out = 2'b11; blue_out = 2'b00; // green
    end else if (pattern_num == 5) begin
      red_out = 2'b00; green_out = 2'b11; blue_out = 2'b10; // teal
    end else if (pattern_num == 6) begin
      red_out = 2'b00; green_out = 2'b11; blue_out = 2'b11; // cyan
    end else if (pattern_num == 7) begin
      red_out = 2'b00; green_out = 2'b01; blue_out = 2'b11; // sky blue
    end else if (pattern_num == 8) begin
      red_out = 2'b00; green_out = 2'b00; blue_out = 2'b11; // blue
    end else if (pattern_num == 9) begin
      red_out = 2'b10; green_out = 2'b00; blue_out = 2'b11; // purp
    end else if (pattern_num == 10) begin
      red_out = 2'b11; green_out = 2'b00; blue_out = 2'b11; // magenta
    end else if (pattern_num == 11) begin
      red_out = 2'b11; green_out = 2'b00; blue_out = 2'b10; // pink
    end else if (pattern_num == 12) begin
      red_out = 2'b11; green_out = 2'b01; blue_out = 2'b01; // rose 
    end else if (pattern_num == 13) begin
      red_out = 2'b10; green_out = 2'b10; blue_out = 2'b00; // gold
    end else if (pattern_num == 14) begin
      red_out = 2'b01; green_out = 2'b00; blue_out = 2'b10; // violet
    end else begin
      red_out = 2'b11; green_out = 2'b11; blue_out = 2'b11; // white
    end
  end

  // if we're not actually in the visible part of the screen, output black
  // otherwise it draws garbage in the blanking area
  reg [1:0] final_red;
  reg [1:0] final_green;
  reg [1:0] final_blue;

  always @(*) begin
    if (display_on == 1) begin
      final_red = red_out;
      final_green = green_out;
      final_blue = blue_out;
    end else begin
      final_red = 2'b00;
      final_green = 2'b00;
      final_blue = 2'b00;
    end
  end

  
  
  
  assign uo_out[7] = hsync;
  assign uo_out[6] = final_blue[0];
  assign uo_out[5] = final_green[0];
  assign uo_out[4] = final_red[0];
  assign uo_out[3] = vsync;
  assign uo_out[2] = final_blue[1];
  assign uo_out[1] = final_green[1];
  assign uo_out[0] = final_red[1];

  // not sure if i actually need this but i saw it in another example
  // and it got rid of a warning about unused wires so im keeping it
  wire _unused_ok = &{ena, ui_in, uio_in, 1'b0};

endmodule



// this part i just copy pasted from the vga playground examples folder,
// its the standard sync generator thing, didnt write this myself
// found it here:
// https://github.com/TinyTapeout/vga-playground/blob/main/src/examples/common/hvsync_generator.v

`ifndef HVSYNC_GENERATOR_H
`define HVSYNC_GENERATOR_H

module hvsync_generator(clk, reset, hsync, vsync, display_on, hpos, vpos);
  input clk;
  input reset;
  output reg hsync, vsync;
  output display_on;
  output reg [9:0] hpos;
  output reg [9:0] vpos;

  // horizontal timing numbers (these are just standard 640x480 numbers)
  parameter H_DISPLAY = 640;
  parameter H_BACK    = 48;
  parameter H_FRONT   = 16;
  parameter H_SYNC    = 96;
  // vertical timing numbers
  parameter V_DISPLAY = 480;
  parameter V_TOP     = 33;
  parameter V_BOTTOM  = 10;
  parameter V_SYNC    = 2;

  // math to figure out when to reset back to 0 etc
  parameter H_SYNC_START = H_DISPLAY + H_FRONT;
  parameter H_SYNC_END   = H_DISPLAY + H_FRONT + H_SYNC - 1;
  parameter H_MAX        = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
  parameter V_SYNC_START = V_DISPLAY + V_BOTTOM;
  parameter V_SYNC_END   = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
  parameter V_MAX        = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;

  wire hmaxxed = (hpos == H_MAX) || reset;
  wire vmaxxed = (vpos == V_MAX) || reset;

  always @(posedge clk) begin
    hsync <= ~(hpos >= H_SYNC_START && hpos <= H_SYNC_END);
    if (hmaxxed)
      hpos <= 0;
    else
      hpos <= hpos + 1;
  end

  always @(posedge clk) begin
    vsync <= ~(vpos >= V_SYNC_START && vpos <= V_SYNC_END);
    if (hmaxxed) begin
      if (vmaxxed)
        vpos <= 0;
      else
        vpos <= vpos + 1;
    end
  end

  assign display_on = (hpos < H_DISPLAY) && (vpos < V_DISPLAY);

endmodule
`endif