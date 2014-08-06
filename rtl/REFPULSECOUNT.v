`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:46:51 06/21/2008 
// Design Name: 
// Module Name:    REFPULSECOUNT 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module REFPULSECOUNT(
    input REF,
	 input MCLK,
    input PCLK,
    output CNT
    );

	reg enable;
	reg pulseok;
	reg waitstage;
	reg pulse;
	initial begin
		enable <= 0;
		pulseok <= 0;
		waitstage <= 0;
		pulse <= 0;
	end


	always @(posedge PCLK) begin
		if (pulse) begin
			pulseok <= 0;
			enable <= 1;
		end else if (REF) begin
			pulseok <= 1;
			enable <= 0;
		end
	end
	always @(posedge MCLK) begin
		if (waitstage) begin
			waitstage <= 0;
		end else if (pulseok) begin
			waitstage <= 1;
		end 
	end
	always @(posedge MCLK) begin
		if (waitstage) begin
			pulse <= 1;
		end else if (pulse) begin
			pulse <= 0;
		end
	end
	assign CNT = pulse;
endmodule
