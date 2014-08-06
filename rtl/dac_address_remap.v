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
module dac_address_remap(
		input [4:0] logical_addr_i,
		output [4:0] dac_addr_o
    );
	
	reg [4:0] dac_addr;

	always @(logical_addr_i) begin
			case (logical_addr_i)
				5'h00: dac_addr <= 8;
				5'h01: dac_addr <= 12;
				5'h02: dac_addr <= 14;
				5'h03: dac_addr <= 16;
				5'h04: dac_addr <= 20;
				5'h05: dac_addr <= 22;
				5'h06: dac_addr <= 9;
				5'h07: dac_addr <= 13;
				5'h08: dac_addr <= 15;
				5'h09: dac_addr <= 17;
				5'h0A: dac_addr <= 21;
				5'h0B: dac_addr <= 23;
				5'h0C: dac_addr <= 10;
				5'h0D: dac_addr <= 11;
				5'h0E: dac_addr <= 18;
				5'h0F: dac_addr <= 19;
				5'h10: dac_addr <= 0;
				5'h11: dac_addr <= 1;
				5'h12: dac_addr <= 2;
				5'h13: dac_addr <= 3;
				5'h14: dac_addr <= 4;
				5'h15: dac_addr <= 5;
				5'h16: dac_addr <= 6;
				5'h17: dac_addr <= 7;
				5'h18: dac_addr <= 24;
				5'h19: dac_addr <= 25;
				5'h1A: dac_addr <= 26;
				5'h1B: dac_addr <= 27;
				5'h1C: dac_addr <= 28;
				5'h1D: dac_addr <= 29;
				5'h1E: dac_addr <= 30;
				5'h1F: dac_addr <= 31;
			endcase
	end
		
	assign dac_addr_o = dac_addr;
endmodule
