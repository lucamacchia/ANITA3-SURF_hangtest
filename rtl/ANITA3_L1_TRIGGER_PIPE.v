`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Hawaii-Manoa
// Engineer: Patrick Allison
// Modified by Luca Macchiarulo for ANITA3 - 7/22/2014
// 
// Create Date:    23:08:37 06/04/2008 
// Design Name: SURF
// Module Name:    ANITA2_L1_TRIGGER_PIPE 
// Project Name: ANITA-II
// Target Devices: XC3S2000
// Tool versions: 
// Description: 
//				Holy crap, this is large. It also needs to be documented. Badly.
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

 
module ANITA3_L1_TRIGGER_PIPE(
	 input REF_PULSE,
    input CLK,
    input BOTTOM,
    input MIDDLE,
    input TOP,
	 input [2:0] mask_pass,
    output [2:0] TRIGGER_PULSE,
	 output MON_SCALER,
    output L1
    );

	wire LCLK = CLK;
//////////////////////////////////////////////////////////////////////////////////
//
// Trigger and clear pulses.
//
//////////////////////////////////////////////////////////////////////////////////
	wire [3:0] antTriggerP;
	wire [3:0] antTriggerN;
	
	wire [3:0] ClrTrigP;
	wire [3:0] ClrTrigN;


   wire top_stage_sc_p;
	
	reg [1:1] top_stage_p; // TOP requires a single delay (4 ns) // the extra delay is used to avoid overloading the reference pulse
						 // by using it as a scaler -- also all the other stages will use the stage [1]
	wire top_stage_sc_n; // TOP requires a single delay (4 ns)
	reg [1:1] top_stage_n;
 
	wire middle_stage_sc_p; // MIDDLE requires 3 delays (12 ns)
	reg [2:1] middle_stage_p; // MIDDLE requires 3 delays (12 ns)
	
	
	wire middle_stage_sc_n; // MIDDLE requires 3 delays (12 ns)
	reg [2:1] middle_stage_n; // MIDDLE requires 3 delays (12 ns)


	wire bottom_stage_sc_p; // BOTTOM requires 4 delays (16 ns)
	reg [3:1] bottom_stage_p; // BOTTOM requires 4 delays (16 ns)
	
	wire bottom_stage_sc_n; // BOTTOM requires 4 delays (16 ns)
	reg [3:1] bottom_stage_n; // BOTTOM requires 4 delays (16 ns)

	wire topTriggerP;
	wire topTriggerN; 

	wire middleTriggerP;
	wire middleTriggerN; 
	
	wire bottomTriggerP;
	wire bottomTriggerN; 
	
	
	 FDCE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) TOP_FDCE_P (
      .Q(top_stage_sc_p),      // Data output
      .C(LCLK),      // Clock input
      .CE(1'b1),    // Clock enable input
      .CLR(mask_pass[0]),  // Asynchronous clear input
      .D(topTriggerP)       // Data input
   );

	 FDCE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) MIDDLE_FDCE_P (
      .Q(middle_stage_sc_p),      // Data output
      .C(LCLK),      // Clock input
      .CE(1'b1),    // Clock enable input
      .CLR(mask_pass[1]),  // Asynchronous clear input
      .D(middleTriggerP)       // Data input
   );	
	
	 FDCE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) BOTTOM_FDCE_P (
      .Q(bottom_stage_sc_p),      // Data output
      .C(LCLK),      // Clock input
      .CE(1'b1),    // Clock enable input
      .CLR(mask_pass[2]),  // Asynchronous clear input
      .D(bottomTriggerP)       // Data input
   );		
	
	always @(posedge LCLK) begin
	
//		top_stage_p[0]<=topTriggerP;
		top_stage_p[1]<=top_stage_sc_p;
		
//		middle_stage_p[0]<=middleTriggerP;
		middle_stage_p[1]<=middle_stage_sc_p;
		middle_stage_p[2]<=middle_stage_p[1];

//		bottom_stage_p[0]<=bottomTriggerP;
		bottom_stage_p[1]<=bottom_stage_sc_p;
		bottom_stage_p[2]<=bottom_stage_p[1];	
		bottom_stage_p[3]<=bottom_stage_p[2];	
	end


	 FDCE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) TOP_FDCE_N (
      .Q(top_stage_sc_n),      // Data output
      .C(~LCLK),      // Clock input
      .CE(1'b1),    // Clock enable input
      .CLR(1'b0),  // Asynchronous clear input
      .D(topTriggerN)       // Data input
   );
	
	 FDCE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) MIDDLE_FDCE_N (
      .Q(middle_stage_sc_n),      // Data output
      .C(~LCLK),      // Clock input
      .CE(1),    // Clock enable input
      .CLR(1'b0),  // Asynchronous clear input
      .D(middleTriggerN)       // Data input
   );	
	
	 FDCE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) BOTTOM_FDCE_N (
      .Q(bottom_stage_sc_n),      // Data output
      .C(~LCLK),      // Clock input
      .CE(1'b1),    // Clock enable input
      .CLR(1'b0),  // Asynchronous clear input
      .D(bottomTriggerN)       // Data input
   );		

	always @(negedge LCLK) begin
	
//		top_stage_n<=topTriggerN;
		top_stage_n[1]<=top_stage_sc_n;
	
//		middle_stage_n[0]<=middleTriggerN;
		middle_stage_n[1]<=middle_stage_sc_n;
		middle_stage_n[2]<=middle_stage_n[1];

//		bottom_stage_n[0]<=bottomTriggerN;
		bottom_stage_n[1]<=bottom_stage_sc_n;
		bottom_stage_n[2]<=bottom_stage_n[1];	
		bottom_stage_n[3]<=bottom_stage_n[2];	
	end
	
	
//////////////////////////////////////////////////////////////////////////////////
//		
// Trigger Pulses:
//
// These are a pair of edge-triggered flipflops which are reset by ClrTrigP/N.
// The outputs are antTriggerP/N. 
// 
// Now there are pulses of 3 different length: 4 ns for TOP antenna, 12 ns for MIDDLE and 16 ns for BOTTOM
//
//////////////////////////////////////////////////////////////////////////////////


	TriggerPulse_PN top_trig(TOP, LCLK, top_stage_sc_p, top_stage_sc_n, topTriggerP, topTriggerN);
	TriggerPulse_PN middle_trig(MIDDLE, LCLK, middle_stage_p[2], middle_stage_n[2], middleTriggerP, middleTriggerN);
	TriggerPulse_PN bottom_trig(BOTTOM, LCLK, bottom_stage_p[3], bottom_stage_n[3], bottomTriggerP, bottomTriggerN);
	
	
	assign TRIGGER_PULSE[2] = top_stage_p[1];
	assign TRIGGER_PULSE[1] = middle_stage_p[1];
	assign TRIGGER_PULSE[0] = bottom_stage_p[1]; //to keep consistency with the antenna order, the earliest pulse is the bottom
	

//////////////////////////////////////////////////////////////////////////////////
//	
// TRIGGER PIPELINE
//
//   The trigger is (2 of 3 ), of bottom, middle and top
//   This is just (B.M)+(B.T)+(M.T), which fit a single LUT, so it should not require any pipelining
//   There are 2 versions (P and N) of the trigger though, and it might be necessary to pipeline the combination
//   Try without to reduce latency
//
//////////////////////////////////////////////////////////////////////////////////

   wire L1_p;
   wire L1_n;
//	assign L1_p = ( top_stage_sc[0] && middle_stage_p[0]) || ( top_stage_p && bottom_stage_p[0]) || ( middle_stage_p[0] && bottom_stage_p[0]);
//	assign L1_n = ( top_stage_n && middle_stage_n[0]) || ( top_stage_n && bottom_stage_n[0]) || ( middle_stage_n[0] && bottom_stage_n[0]);

//To be used with inputs masked at the source  
// assign L1_p = ( top_stage_sc_p && middle_stage_sc_p) || ( top_stage_sc_p && bottom_stage_sc_p) || ( middle_stage_sc_p && bottom_stage_sc_p);
//	assign L1_n = ( top_stage_sc_n && middle_stage_sc_n) || ( top_stage_sc_n && bottom_stage_sc_n) || ( middle_stage_sc_n && bottom_stage_sc_n);

//To be used with inputs masked here 
//assign L1_p = ( ~top_stage_sc_p && ~middle_stage_sc_p) || ( ~top_stage_sc_p && ~bottom_stage_sc_p) || ( ~middle_stage_sc_p && ~bottom_stage_sc_p);
//assign L1_n = ( ~top_stage_sc_n && ~middle_stage_sc_n) || ( ~top_stage_sc_n && ~bottom_stage_sc_n) || ( ~middle_stage_sc_n && ~bottom_stage_sc_n);


//   reg L1_intermediate_1_2;
//	always @(posedge LCLK) begin
//		L1_intermediate_1_2 <= ( ~top_stage_sc_p && ~middle_stage_sc_p);
//	end 
//	
//   reg L1_intermediate_1_3;
//	always @(posedge LCLK) begin
//		L1_intermediate_1_3 <= ( ~top_stage_sc_p && ~bottom_stage_sc_p);
//	end 	
//	
//	reg L1_intermediate_2_3;
//	always @(posedge LCLK) begin
//		L1_intermediate_2_3 <= ( ~middle_stage_sc_p && ~bottom_stage_sc_p);
//	end 	
//	
  
//add pipeline before logic	
	assign L1_p = (( top_stage_p[1] && middle_stage_p[1]) || ( top_stage_p[1] && bottom_stage_p[1]) || ( middle_stage_p[1] && bottom_stage_p[1]));
	assign L1_n = (( top_stage_n[1] && middle_stage_n[1]) || ( top_stage_n[1] && bottom_stage_n[1]) || ( middle_stage_n[1] && bottom_stage_n[1]));
	
	
	wire L1_unregistered;
//	assign L1 = L1_p || L1_n;
	assign L1_unregistered = L1_p; //only one chain on

//assign  L1_unregistered = L1_intermediate_1_2 || L1_intermediate_1_3 || L1_intermediate_2_3;

//	reg L1_p_delayed;
//	reg L1_n_delayed;
//	always @(posedge LCLK) begin
//		L1_p_delayed <= L1_p;
//	end 
//	always @(negedge LCLK) begin
//		L1_n_delayed <= L1_n;
//	end	
	
	
	// OutPulseTwoClockPN takes a dual-pipeline pulse and generates an 8 ns oneshot from
	// the earliest-arriving pulse.
	//
	// The oneshot is delayed by 1 full clock cycle.
	
//
//	OutPulseTwoClockPN L1Scaler(L1_p_delayed && REF_PULSE,
//										L1_n_delayed && REF_PULSE,
//										CLK,
//										MON_SCALER);
//  OutPulseTwoClockPN L1Scaler(L1_p && REF_PULSE,
//										L1_n && REF_PULSE,
//										CLK,
//										MON_SCALER);
// Neither of those respects timing due to the N-side: drop the N-side and use the L1 directly.
	
//	(* KEEP="YES" *)
//	reg L1_reg_for_scaler;
//	always @(posedge LCLK) begin
//		L1_reg_for_scaler <= L1_unregistered;
//	end	

	(* KEEP="YES" *)
	reg L1_reg_for_output_1;
	always @(posedge LCLK) begin
		L1_reg_for_output_1 <= L1_unregistered;
	end	

	(* KEEP="YES" *)	
	reg L1_reg_for_output;
	always @(posedge LCLK) begin
		L1_reg_for_output <= L1_reg_for_output_1;
//		L1_reg_for_output <= L1_unregistered;
	end	
	
	(* IOB="TRUE" *)
	reg L1_reg;

	always @(posedge LCLK) begin
		L1_reg <= L1_reg_for_output;
	end	
   

		
	assign L1 = L1_reg;
//	
//	Now there are  L1 scalers
//  OutPulseTwoClockPN L1Scaler(L1_reg_for_scaler && REF_PULSE,
//										0,
//										CLK,
//										MON_SCALER);
assign MON_SCALER= 0;

endmodule	

module SCALERSHOT(
                        input CLK,
                        input T1,
                        input T2,
                        output O
                        );

        reg stage1, stage2, stage3;
        reg stuck_on;

        initial begin
                stage1 <= 0;
                stage2 <= 0;
                stage3 <= 0;
                stuck_on <= 0;
        end

        always @(posedge CLK) begin
                stage1 <= T1;
                stage2 <= stage1;
                stage3 <= stage2;
        end

        always @(posedge CLK) begin
                if (stage1 && stage2 && stage3) begin
                        stuck_on <= ~stuck_on;
                end
        end

        assign O = (T2 ^ stuck_on);
endmodule



