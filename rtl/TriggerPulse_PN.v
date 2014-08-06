`timescale 1ns / 1ps
module TriggerPulse_PN(TRIG, CLK, CLR_P, CLR_N, TRIG_P, TRIG_N);
	input TRIG;
	input CLK;
	input CLR_P;
	input CLR_N;
	output TRIG_P;
	output TRIG_N;
	
//	(* IOB = "TRUE" *)
//	reg triggerP; 
//	(* IOB = "TRUE" *)
//	reg triggerN;
//	
//	initial begin
//		triggerP <= 0;
//		triggerN <= 0;
//	end

 FDCE_1 #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDCE_P (
      .Q(triggerP),      // Data output
      .C(TRIG),      // Clock input
      .CE(1'b1),    // Clock enable input
      .CLR(CLR_P),  // Asynchronous clear input
      .D(1'b1)       // Data input
   );

 FDCE_1 #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDCE_N (
      .Q(triggerN),      // Data output
      .C(TRIG),      // Clock input
      .CE(1'b1),    // Clock enable input
      .CLR(CLR_N),  // Asynchronous clear input
      .D(1'b1)       // Data input
   );

//	always @(posedge TRIG or posedge CLR_P) begin
//		if (CLR_P)
//			triggerP <= 0;
//		else
//			triggerP <= 1;
//	end
//	always @(posedge TRIG or posedge CLR_N) begin
//		if (CLR_N)
//			triggerN <= 0;
//		else
//			triggerN <= 1;
//	end
	assign TRIG_P = triggerP;
	assign TRIG_N = triggerN;
endmodule

