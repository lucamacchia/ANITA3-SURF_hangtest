`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:02:36 07/26/2014
// Design Name:   SCALER_TOPv2
// Module Name:   C:/cygwin/home/barawn/repositories/github/firmware-surf/sim/SCALER_TOPv2_tb.v
// Project Name:  SURFv38
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SCALER_TOPv2
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module SCALER_TOPv2_tb;

	// Inputs
	reg clk33_i;
	reg [16:0] scal_i;
	reg [4:0] scal_addr_i;
	reg scal_rd_i;

	// Outputs
	wire [15:0] scal_dat_o;
	wire [15:0] refpulse_cnt_o;

	// Instantiate the Unit Under Test (UUT)
	SCALER_TOPv2 uut (
		.clk33_i(clk33_i), 
		.scal_i(scal_i), 
		.scal_addr_i(scal_addr_i), 
		.scal_rd_i(scal_rd_i), 
		.scal_dat_o(scal_dat_o), 
		.refpulse_cnt_o(refpulse_cnt_o)
	);

	always #15 clk33_i = ~clk33_i;

	parameter ClkFrequency = 33333333; // 33MHz
	parameter Baud = 115200;
	parameter BaudGeneratorAccWidth = 16;
	parameter BaudGeneratorInc = ((Baud<<(BaudGeneratorAccWidth-4))+(ClkFrequency>>5))/(ClkFrequency>>4);	

	reg [BaudGeneratorAccWidth:0] BaudGeneratorAcc = {BaudGeneratorAccWidth+1{1'b0}};
	always @(posedge clk33_i)
	  BaudGeneratorAcc <= BaudGeneratorAcc[BaudGeneratorAccWidth-1:0] + BaudGeneratorInc;

	wire BaudTick = BaudGeneratorAcc[BaudGeneratorAccWidth];

	always @(posedge clk33_i) scal_i[1] <= BaudTick;

	initial begin
		// Initialize Inputs
		clk33_i = 0;
		scal_i = 0;
		scal_addr_i = 0;
		scal_rd_i = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#1000000;
		@(posedge clk33_i);
		scal_rd_i = 1;
		@(posedge clk33_i);
		scal_rd_i = 0;
		
	end
      
endmodule

