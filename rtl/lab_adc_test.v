`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:59:53 07/24/2014 
// Design Name: 
// Module Name:    lab_adc_test 
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
module lab_adc_test(
		input clk_i,
		input start_i,
		input read_done_i,
		output done_o,
		output CLR,
		output GCK,
		output RAMP		
    );

	reg [11:0] counter = {12{1'b0}};
	wire [12:0] counter_plus_one = counter + 1;
	
	(* IOB = "TRUE" *)
	reg clr_reg = 0;
	(* IOB = "TRUE" *)
	reg ramp_reg = 0;

	reg done_flag = 0;

	reg clock_reset = 1;

	localparam FSM_BITS = 2;
	localparam [FSM_BITS-1:0] IDLE = 0;
	localparam [FSM_BITS-1:0] CLEAR = 1;
	localparam [FSM_BITS-1:0] COUNT = 2;
	localparam [FSM_BITS-1:0] DONE = 3;
	reg [FSM_BITS-1:0] state = IDLE;
	always @(posedge clk_i) begin
		case (state)
			IDLE: if (start_i) state <= CLEAR;
			CLEAR: if (counter_plus_one[4]) state <= COUNT;
			COUNT: if (counter_plus_one[12]) state <= DONE;
			DONE: state <= IDLE;
		endcase
		
		if (state == COUNT) clock_reset <= 0;
		else if (state == DONE) clock_reset <= 1;
		
		if ((state == CLEAR) && counter_plus_one[4]) counter <= {12{1'b0}}; 
		if (state == COUNT || state == CLEAR) counter <= counter_plus_one;
		else counter <= {12{1'b0}};
		
		if (state == COUNT) ramp_reg <= 1;
		else if (read_done_i) ramp_reg <= 0;

		clr_reg <= (state == CLEAR);
		done_flag <= (state == DONE);
	end
	FDDRRSE u_wclk(.C0(clk_i),.C1(~clk_i),.D0(1'b1),.D1(1'b0),.CE(1'b1),.R(clock_reset),.S(1'b0),.Q(GCK));
	assign done_o = done_flag;
	assign RAMP = ramp_reg;
	assign CLR = clr_reg;
	
endmodule
