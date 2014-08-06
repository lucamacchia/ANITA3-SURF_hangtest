`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:56:57 07/26/2014
// Design Name:   SCALER_CLOCK_v2
// Module Name:   C:/cygwin/home/barawn/repositories/github/firmware-surf/sim/scaler_clock_test.v
// Project Name:  SURFv38
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SCALER_CLOCK_v2
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module scaler_clock_test;

	// Inputs
	reg clk33_i;

	// Outputs
	wire khz_clk_o;

	// Instantiate the Unit Under Test (UUT)
	SCALER_CLOCK_v2 uut (
		.clk33_i(clk33_i), 
		.khz_clk_o(khz_clk_o)
	);

	always #15 clk33_i <= ~clk33_i;

	initial begin
		// Initialize Inputs
		clk33_i = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

