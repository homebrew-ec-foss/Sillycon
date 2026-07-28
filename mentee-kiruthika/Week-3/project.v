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
  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;
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

// Tiling the screen by 80x80 pixels
wire signed [7:0] tile_x;
wire signed [7:0] tile_y;
localparam TILE_WIDTH = 80;
localparam TILE_HEIGHT = 80;

//assign tile_x = pix_x % TILE_WIDTH;
assign tile_y = pix_y % TILE_HEIGHT;

//Finding the center of the tile
localparam CENTER_X = TILE_WIDTH/2;
localparam CENTER_Y = TILE_HEIGHT/2;

wire signed [7:0] dx;
wire signed [7:0] dy;

// Find the distance of pixel from the center of the tile
assign dx = tile_x - CENTER_X;
assign dy = tile_y - CENTER_Y;

//Converting the pixel distance to absolute value
wire [6:0] abs_dx;
wire [6:0] abs_dy;
assign abs_dx = dx < 0 ? -dx : dx;
assign abs_dy = dy < 0 ? -dy : dy;

//Diamond
wire [6:0] dist_diamond;
assign dist_diamond = abs_dx + abs_dy;  // Calculate the Manhattan distance

// Animation frame counter
reg [9:0] anim_counter;
always @(posedge vsync or negedge rst_n)
begin
  if (!rst_n)
    anim_counter <= 0;
  else
    anim_counter <= anim_counter + 1;
end

//thresholds for when different animations start and end
localparam EMERGE_END = 40;
localparam DRIFT_START = 220;
localparam COLOR_END = 870;
localparam RAINBOW_START = 512; 
localparam PULSE_END = 735; 
localparam RAINBOW_END = 870;

// Outer tringle
localparam TRI_SIZE = 30;  // maximum size of the triangle
wire signed [6:0] tri_y;
assign tri_y = tile_y - CENTER_Y;
wire signed [6:0] tri_width;
wire top_triangle;

//Triangles emerging (triangle grows)
wire [6:0] current_tri_size;
assign current_tri_size = (anim_counter < TRI_SIZE) ? anim_counter[6:0] : TRI_SIZE;
//assign tri_width = current_tri_size + tri_y;
//assign top_triangle = (tri_y >= -current_tri_size) && (tri_y <= 0) && (abs_dx <= tri_width);

//Inner triangle
localparam INNER_BASE = 8;
wire [3:0] inner_pulse;
// counts up and then counts down, repeats. 8 is the halfway point of the 16 values (0-15)
assign inner_pulse = (anim_counter[5:2] < 8) ? anim_counter[5:2] : (15 - anim_counter[5:2]);

wire signed [7:0] inner_size;
assign inner_size = INNER_BASE + inner_pulse; // Current size of the inner triangle after applying the pulse

wire signed [6:0] inner_width;
assign inner_width = inner_size + tri_y; // Width of the inner triangle at the current row

wire inner_triangle;
assign inner_triangle = (tri_y >= -inner_size) && (tri_y <= 0) && (abs_dx <= inner_width);

//Drift counter - makes the whole grid slide to the left
reg [9:0] drift_offset;
always @(posedge vsync or negedge rst_n)
begin
  if (!rst_n)
     drift_offset <= 0;
  else if (anim_counter == 0) //to reset the position on new loop 
     drift_offset <= 0;
  else if (anim_counter >= DRIFT_START && anim_counter < COLOR_END) begin
     if (drift_offset == 79)
        drift_offset <= 0;   // to loop back when it hits the edge of a tile
     else
        drift_offset <= drift_offset + 1;
  end 
end

wire [10:0] drift_x;
assign drift_x = pix_x + drift_offset; //adding drift offset to pixel position
//assign drift_x = pix_x ;
assign tile_x = drift_x % TILE_WIDTH;

//Outer triangles pulsating (shifting pulse based on columns)
wire [3:0] pulse;
// pulse for outer triangle, increase count and then decrease count
assign pulse = (anim_counter[5:2] < 8) ? anim_counter[5:2] : (15 - anim_counter[5:2]);

reg [2:0] column;
always @(*) begin
  if (drift_x < 80)
      column = 3'd0;
  else if (drift_x < 160)
      column = 3'd1;
  else if (drift_x < 240)
      column = 3'd2;
  else if (drift_x < 320)
      column = 3'd3;
  else if (drift_x < 400)
      column = 3'd4;
  else if (drift_x < 480)
      column = 3'd5;
  else if (drift_x < 560)
      column = 3'd6;
  else if (drift_x < 640)
      column = 3'd7;
  else
      column = 3'd0;
end

wire [3:0] pulse_shift;
assign pulse_shift = pulse + (column << 1); // Adding a column-based offset so neighbouring columns pulse at different times

wire [3:0] wave;
assign wave = (pulse_shift < 8) ? pulse_shift : (15 - pulse_shift);

reg signed [7:0] draw_size;
always @(*) begin
  if (anim_counter < EMERGE_END)
    draw_size = current_tri_size;
  else if (anim_counter < PULSE_END)
    draw_size = TRI_SIZE + 8 - (wave << 2);  // 8 is offset added to shift the pulsation range upward
  else
    draw_size = TRI_SIZE;
end

assign tri_width = draw_size + tri_y;
assign top_triangle = (tri_y >= -draw_size) && (tri_y <= 0) && (abs_dx <= tri_width);

//Colored stripes moving
wire [9:0] color_x;
// Offset the x-coordinate to move the color bands horizontally (opposite to the tiles motion)
assign color_x = pix_x - anim_counter[5:0];

reg [2:0] color_band;
always @(*) begin
  if (color_x < 80)
      color_band = 3'd0;
  else if (color_x < 160)
      color_band = 3'd1;
  else if (color_x < 240)
      color_band = 3'd2;
  else if (color_x < 320)
      color_band = 3'd3;
  else if (color_x < 400)
      color_band = 3'd4;
  else if (color_x < 480)
      color_band = 3'd5;
  else
      color_band = 3'd6;
end

wire rainbow_on;
assign rainbow_on = (anim_counter >= RAINBOW_START && anim_counter < RAINBOW_END);

//to pick an RGB value depending on which color band this pixel falls into
reg [1:0] draw_R;
reg [1:0] draw_G;
reg [1:0] draw_B;
always @(*) begin
  case(color_band)
  3'd0: begin
    draw_R = 2'b11; draw_G = 2'b01; draw_B = 2'b00; // Orange
  end
  3'd1: begin
    draw_R = 2'b11; draw_G = 2'b11; draw_B = 2'b00; // yellow
  end
  3'd2: begin
    draw_R = 2'b00; draw_G = 2'b11; draw_B = 2'b00; //green
  end
  3'd3: begin
    draw_R = 2'b00; draw_G = 2'b11; draw_B = 2'b11; //cyan
  end
  3'd4: begin
    draw_R = 2'b00; draw_G = 2'b00; draw_B = 2'b11; //Blue
  end
  3'd5: begin
    draw_R = 2'b11; draw_G = 2'b00; draw_B = 2'b11; //Majenta
  end
  default: begin
    draw_R = 2'b11; draw_G = 2'b00; draw_B = 2'b00; //Red
  end
endcase
end

always @(*) begin
  R = 2'b00;
  G = 2'b00;
  B = 2'b00;
  if (video_active) begin
      if (inner_triangle) begin
        R = 2'b11; G = 2'b11; B = 2'b11;
      end
      else if (top_triangle) begin
        if (rainbow_on) begin
          R = draw_R; G = draw_G; B = draw_B;
        end
        else begin
          R = 2'b01; G = 2'b01; B = 2'b11;
        end
      end
  end
end

endmodule