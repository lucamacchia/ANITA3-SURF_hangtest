`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// This file is a part of the Antarctic Impulsive Transient Antenna (ANITA)
// project, a collaborative scientific effort between multiple institutions. For
// more information, contact Peter Gorham (gorham@phys.hawaii.edu).
//
// All rights reserved.
//
// Author: Patrick Allison, Ohio State University (allison.122@osu.edu)
// Author:
// Author:
////////////////////////////////////////////////////////////////////////////////
module SCALER_CLOCK_v2(
		input clk33_i,
		output khz_clk_o
    );

	localparam [15:0] MATCH = 33333;
	// Eff it.
	reg [15:0] counter = {16{1'b0}};
	reg khz_clk = 0;
	always @(posedge clk33_i) begin
		if (khz_clk) counter <= {16{1'b0}};
		else counter <= counter + 1;
		khz_clk <= (counter == MATCH);
	end
	
	assign khz_clk_o = khz_clk;
endmodule
