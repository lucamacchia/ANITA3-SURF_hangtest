`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:50:40 07/26/2014 
// Design Name: 
// Module Name:    SignalStretcher 
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
module SignalStretcher(
input clk250,
input clk33,
input L1_250MHz,
output L1_pulsed_33MHz
    );



	reg [15:0] L1_delay = 0;
	always @(posedge clk250) begin
	if(L1_250MHz)
		L1_delay[0] <= 1'b1;
	else if (L1_delay[15])
		L1_delay[0] <= 1'b0;
	L1_delay[15:1] <= L1_delay[14:0];
	end
	
	reg [1:0] L1_pulsed_train;
	reg L1_pulsed;
	always @(posedge clk33) begin
		L1_pulsed_train[0]<= L1_delay[0];
		L1_pulsed_train[1]<= L1_pulsed_train[0];
		L1_pulsed <= L1_pulsed_train[0] && ~L1_pulsed_train[1];
	end

	assign L1_pulsed_33MHz = L1_pulsed;

endmodule
