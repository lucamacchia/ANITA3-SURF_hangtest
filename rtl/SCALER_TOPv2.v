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
module SCALER_TOPv2(
		// 33 MHz clock
		input clk33_i,
		// 'CR' output from trigger module
		input [16:0] scal_i,
		// Address from MESSv2
		input [4:0] scal_addr_i,
		input scal_rd_i,
		// Data to MESSv2
		output [15:0] scal_dat_o,
		// Reference pulse counter.
		output [15:0] refpulse_cnt_o
    );

	wire update_scalers;
	SCALER_CLOCK_v2 u_clk(.clk33_i(clk33_i),
								 .khz_clk_o(update_scalers));
	wire [15:0] scaler_data_out[31:0];
	reg [1:0] ref_pulse_reg = {2{1'b0}};
	reg [15:0] ref_pulse_counter = {16{1'b0}};
	reg [15:0] ref_pulse_count = {16{1'b0}};
	reg [15:0] gated_scaler = {16{1'b0}};
	wire [15:0] ref_pulse_in = {16{scal_i[0]}};
	always @(posedge clk33_i) begin
		gated_scaler <= ref_pulse_in & scal_i[16:1];
		ref_pulse_reg <= {ref_pulse_reg[0],scal_i[0]};

		if (update_scalers) ref_pulse_counter <= {16{1'b0}};
		else if (ref_pulse_reg[0] && !ref_pulse_reg[1]) ref_pulse_counter <= ref_pulse_counter + 1;

		if (update_scalers) ref_pulse_count <= ref_pulse_counter;
	end
	generate
		genvar trig, ant;
		for (trig=0;trig<4;trig=trig+1) begin : L1
			ANITA3_scaler #(.WIDTH(16),.PRESCALE(0)) u_l1_scaler(.clk_i(clk33_i),
																				  .pps_i(update_scalers),
																				  .count_i(scal_i[1+trig]),
																				  .scaler_o(scaler_data_out[12+trig]));
			ANITA3_scaler #(.WIDTH(16),.PRESCALE(0)) u_l1_mon_scaler(.clk_i(clk33_i),
																				  .pps_i(update_scalers),
																				  .count_i(gated_scaler[trig]),
																				  .scaler_o(scaler_data_out[28+trig]));
		end
		for (ant=0;ant<12;ant=ant+1) begin : ANT
			ANITA3_scaler #(.WIDTH(16),.PRESCALE(0)) u_ant_scaler(.clk_i(clk33_i),
																					.pps_i(update_scalers),
																					.count_i(scal_i[5+ant]),
																					.scaler_o(scaler_data_out[ant]));
			ANITA3_scaler #(.WIDTH(16),.PRESCALE(0)) u_ant_mon_scaler(.clk_i(clk33_i),
																					.pps_i(update_scalers),
																					.count_i(gated_scaler[4+ant]),
																					.scaler_o(scaler_data_out[16+ant]));
		end
	endgenerate
	reg scaler_bank = 0;
	reg [31:0] scaler_ram[63:0];
	reg [31:0] scaler_out;
	
	integer i;
	initial begin
		for (i=0;i<64;i=i+1) begin
			scaler_ram[i] <= {32{1'b0}};
		end
	end
	
	reg reading = 0;
	reg updating = 0;
	reg was_updating = 0;
	reg maybe_reading_too_slow = 0;
	
	reg [4:0] scaler_addr_count = {5{1'b0}};
	wire [5:0] scaler_addr_count_plus_one = scaler_addr_count + 1;
	always @(posedge clk33_i) begin	
		if (update_scalers) updating <= 1;
		else if (scaler_addr_count_plus_one[5]) updating <= 0;
		
		if (updating) scaler_addr_count <= scaler_addr_count_plus_one;
		
		if (updating) 
			scaler_ram[{scaler_bank,scaler_addr_count}] <= {ref_pulse_count,scaler_data_out[scaler_addr_count]};
		scaler_out <= scaler_ram[{!scaler_bank,scal_addr_i}];


		// Once we start reading, we won't switch banks to present
		// until we stop. If we take more than 1 ms to read out,
		// we just go ahead and do it anyway.

		// So if we have:
		// (1 ms) bank 1 -> bank 0
		// start reading from bank 1   (reading = 1)
		// (1 ms tick) ... (maybe_reading_too_slow = 1)
		// stays in bank 1 (overwrite bank 0)
		// reading finishes (maybe_reading_too_slow = 0, reading = 0)
		// (1 ms tick) bank 0 -> bank 1
		//
		// But if we get:
		// (1 ms) bank 1 -> bank 0
		// start reading from bank 1 (reading = 1)
		// (1 ms tick) ... (maybe_reading_too_slow = 1)
		// stays in bank 1 (overwrite bank 0)
		// (1 ms tick)  (reading = 0, overwrite bank 0)
		// (1 ms tick)  bank 1 -> bank 0
		//  finish reading (maybe_reading_too_slow = 0)

		if ((scal_addr_i == {5{1'b0}}) && scal_rd_i)
			reading <= 1;
		else if ((scal_addr_i == {5{1'b1}}) && scal_rd_i) 
			reading <= 0;
		else if (update_scalers && maybe_reading_too_slow)
			reading <= 0;

		if (!reading) maybe_reading_too_slow <= 0;
		else if (update_scalers && reading) maybe_reading_too_slow <= 1;
		
		was_updating <= updating;
		
		if (!updating && was_updating && !reading) scaler_bank <= ~scaler_bank;		
	end
	
	assign scal_dat_o = scaler_out[15:0];
	assign refpulse_cnt_o = scaler_out[31:16];
endmodule
