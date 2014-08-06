`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:50:38 07/25/2014
// Design Name:   DAC_CTRL_v3
// Module Name:   C:/cygwin/home/barawn/repositories/github/firmware-surf/sim/DAC_CTRL_v3_tb.v
// Project Name:  SURFv38
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DAC_CTRL_v3
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module DAC_CTRL_v3_tb;

	// Inputs
	reg clk_i;
	reg dac_we_i;
	reg [4:0] dac_waddr_i;
	reg [15:0] dac_dat_i;
	reg [4:0] dac_raddr_i;
	reg update_i;

	// Outputs
	wire [15:0] dac_dat_o;
	wire SCLK;
	wire NSYNC;
	wire [7:0] DIN;

	// Instantiate the Unit Under Test (UUT)
	DAC_CTRL_v3 uut (
		.clk_i(clk_i), 
		.dac_we_i(dac_we_i), 
		.dac_waddr_i(dac_waddr_i), 
		.dac_dat_i(dac_dat_i), 
		.dac_raddr_i(dac_raddr_i), 
		.dac_dat_o(dac_dat_o), 
		.update_i(update_i), 
		.SCLK(SCLK), 
		.NSYNC(NSYNC), 
		.DIN(DIN)
	);

	always #15 clk_i = ~clk_i;

	integer counter = 0;

	initial begin
		// Initialize Inputs
		clk_i = 0;
		dac_we_i = 0;
		dac_waddr_i = 0;
		dac_dat_i = 0;
		dac_raddr_i = 0;
		update_i = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		while (counter < 32) begin
			@(posedge clk_i);
			dac_dat_i = counter;
			dac_we_i = 1;
			dac_waddr_i = counter;
			counter = counter + 1;
		end
		@(posedge clk_i);
		dac_we_i = 0;
		@(posedge clk_i);
		update_i = 1;
		@(posedge clk_i);
		update_i = 0;
	end
      
	integer sclk_counter = 0;
	reg reset_counter = 0;
	always @(negedge NSYNC) begin
		reset_counter = 1;
		#5 reset_counter = 0;
	end
	
	always @(negedge SCLK or posedge reset_counter) if (reset_counter) sclk_counter = 0; else sclk_counter = sclk_counter + 1;
endmodule

