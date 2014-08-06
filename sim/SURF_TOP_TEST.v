`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:51:43 07/26/2014
// Design Name:   TOP_v38
// Module Name:   C:/cygwin/home/barawn/repositories/github/firmware-surf/sim/SURF_TOP_TEST.v
// Project Name:  SURFv38
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: TOP_v38
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module SURF_TOP_TEST;

	// Inputs
	reg nADS;
	reg WnR;
	reg nRD;
	reg [7:2] LA;
	reg nCS2;
	reg nCS3;
	reg [5:0] BAD;
	reg BCLKO;
	reg CLK125_P;
	wire CLK125_N = ~CLK125_P;
	reg CMD_P;
	wire CMD_N = ~CMD_P;
	reg [3:0] HOLD_P;
	wire [3:0] HOLD_N = ~HOLD_P;
	reg REF_P;
	wire REF_N = ~REF_P;
	reg [7:0] A1TC;
	reg [7:0] A2TC;
	reg [7:0] A3TC;
	reg [7:0] A4TC;
	wire [7:0] VTRG_A1TC = ~A1TC;
	wire [7:0] VTRG_A2TC = ~A2TC;
	wire [7:0] VTRG_A3TC = ~A3TC;
	wire [7:0] VTRG_A4TC = ~A4TC;
	reg A_HITBUS;
	reg A_RCO;
	reg [11:0] A_DAT;
	reg B_HITBUS;
	reg B_RCO;
	reg [11:0] B_DAT;
	reg C_HITBUS;
	reg C_RCO;
	reg [11:0] C_DAT;
	reg D_HITBUS;
	reg D_RCO;
	reg [11:0] D_DAT;

	// Outputs
	wire nREADY;
	wire nBTERM;
	wire LCLK;
	wire [3:0] L1_P;
	wire [3:0] L1_N;
	wire A_GCK;
	wire A_GCCLR;
	wire A_RAMP;
	wire [3:0] A_CS;
	wire [7:0] A_S;
	wire A_SELMAIN;
	wire A_SELTAIL;
	wire A_NRUN;
	wire A_TREF_P;
	wire A_TREF_N;
	wire B_GCK;
	wire B_GCCLR;
	wire B_RAMP;
	wire [3:0] B_CS;
	wire [7:0] B_S;
	wire B_SELMAIN;
	wire B_SELTAIL;
	wire B_NRUN;
	wire B_TREF_P;
	wire B_TREF_N;
	wire C_GCK;
	wire C_GCCLR;
	wire C_RAMP;
	wire [3:0] C_CS;
	wire [7:0] C_S;
	wire C_SELMAIN;
	wire C_SELTAIL;
	wire C_NRUN;
	wire C_TREF_P;
	wire C_TREF_N;
	wire D_GCK;
	wire D_GCCLR;
	wire D_RAMP;
	wire [3:0] D_CS;
	wire [7:0] D_S;
	wire D_SELMAIN;
	wire D_SELTAIL;
	wire D_NRUN;
	wire D_TREF_P;
	wire D_TREF_N;
	wire SCLK;
	wire NSYNC;
	wire [7:0] DIN;
	wire [3:0] CALSNH;
	wire [3:0] TCS;
	wire [3:0] RSS;

	// Bidirs
	wire [31:0] LD;

	always #15 BCLKO = ~BCLKO;
	always #4 CLK125_P = ~CLK125_P;
	
	// Instantiate the Unit Under Test (UUT)
	TOP_v38 uut (
		.nADS(nADS), 
		.WnR(WnR), 
		.nRD(nRD), 
		.LD(LD), 
		.LA(LA), 
		.nCS2(nCS2), 
		.nCS3(nCS3), 
		.nREADY(nREADY), 
		.nBTERM(nBTERM), 
		.BAD(BAD), 
		.BCLKO(BCLKO), 
		.LCLK(LCLK), 
		.CLK125_P(CLK125_P), 
		.CLK125_N(CLK125_N), 
		.CMD_P(CMD_P), 
		.CMD_N(CMD_N), 
		.HOLD_P(HOLD_P), 
		.HOLD_N(HOLD_N), 
		.REF_P(REF_P), 
		.REF_N(REF_N), 
		.A1TC(A1TC), 
		.A2TC(A2TC), 
		.A3TC(A3TC), 
		.A4TC(A4TC), 
		.VTRG_A1TC(VTRG_A1TC), 
		.VTRG_A2TC(VTRG_A2TC), 
		.VTRG_A3TC(VTRG_A3TC), 
		.VTRG_A4TC(VTRG_A4TC), 
		.L1_P(L1_P), 
		.L1_N(L1_N), 
		.A_GCK(A_GCK), 
		.A_GCCLR(A_GCCLR), 
		.A_RAMP(A_RAMP), 
		.A_CS(A_CS), 
		.A_S(A_S), 
		.A_SELMAIN(A_SELMAIN), 
		.A_SELTAIL(A_SELTAIL), 
		.A_NRUN(A_NRUN), 
		.A_HITBUS(A_HITBUS), 
		.A_RCO(A_RCO), 
		.A_DAT(A_DAT), 
		.A_TREF_P(A_TREF_P), 
		.A_TREF_N(A_TREF_N), 
		.B_GCK(B_GCK), 
		.B_GCCLR(B_GCCLR), 
		.B_RAMP(B_RAMP), 
		.B_CS(B_CS), 
		.B_S(B_S), 
		.B_SELMAIN(B_SELMAIN), 
		.B_SELTAIL(B_SELTAIL), 
		.B_NRUN(B_NRUN), 
		.B_HITBUS(B_HITBUS), 
		.B_RCO(B_RCO), 
		.B_DAT(B_DAT), 
		.B_TREF_P(B_TREF_P), 
		.B_TREF_N(B_TREF_N), 
		.C_GCK(C_GCK), 
		.C_GCCLR(C_GCCLR), 
		.C_RAMP(C_RAMP), 
		.C_CS(C_CS), 
		.C_S(C_S), 
		.C_SELMAIN(C_SELMAIN), 
		.C_SELTAIL(C_SELTAIL), 
		.C_NRUN(C_NRUN), 
		.C_HITBUS(C_HITBUS), 
		.C_RCO(C_RCO), 
		.C_DAT(C_DAT), 
		.C_TREF_P(C_TREF_P), 
		.C_TREF_N(C_TREF_N), 
		.D_GCK(D_GCK), 
		.D_GCCLR(D_GCCLR), 
		.D_RAMP(D_RAMP), 
		.D_CS(D_CS), 
		.D_S(D_S), 
		.D_SELMAIN(D_SELMAIN), 
		.D_SELTAIL(D_SELTAIL), 
		.D_NRUN(D_NRUN), 
		.D_HITBUS(D_HITBUS), 
		.D_RCO(D_RCO), 
		.D_DAT(D_DAT), 
		.D_TREF_P(D_TREF_P), 
		.D_TREF_N(D_TREF_N), 
		.SCLK(SCLK), 
		.NSYNC(NSYNC), 
		.DIN(DIN), 
		.CALSNH(CALSNH), 
		.TCS(TCS), 
		.RSS(RSS)
	);

	always begin
		#500
		@(posedge CLK125_P);
		A2TC = 8'hFF;
		@(posedge CLK125_P);
		A2TC = 8'h00;
		#500;
		@(posedge CLK125_P);
		A2TC = 8'hFF;
		@(posedge CLK125_P);
		A2TC = 8'h00;
	end

	reg [31:0] temp = {32{1'b0}};

	initial begin
		// Initialize Inputs
		nADS = 1;
		WnR = 1;
		nRD = 1;
		LA = 0;
		nCS2 = 1;
		nCS3 = 1;
		BAD = 0;
		BCLKO = 0;
		CLK125_P = 0;
		CMD_P = 0;
		HOLD_P = 0;
		REF_P = 0;
		A1TC = 0;
		A2TC = 0;
		A3TC = 0;
		A4TC = 0;
		A_HITBUS = 0;
		A_RCO = 0;
		A_DAT = 0;
		B_HITBUS = 0;
		B_RCO = 0;
		B_DAT = 0;
		C_HITBUS = 0;
		C_RCO = 0;
		C_DAT = 0;
		D_HITBUS = 0;
		D_RCO = 0;
		D_DAT = 0;

		// sigh wait 2 ms
		#2000500;
		hk_read(6'h00, temp);
		hk_read(6'h01, temp);
		hk_read(6'h02, temp);
		hk_read(6'h03, temp);
		hk_read(6'h04, temp);
		hk_read(6'h05, temp);
		hk_read(6'h06, temp);
		hk_read(6'h07, temp);
	end

	task hk_read;
		input [5:0] address;
		output [31:0] data;
		begin
			@(posedge BCLKO);
			nADS = 0;
			nCS2 = 0;
			LA[7:2] = address;
			WnR = 0;
			@(posedge BCLKO);
			nADS = 1;
			while (nREADY) @(posedge BCLKO);
			data = LD;
			@(posedge BCLKO);
			WnR = 1;
			nCS2 = 1;
			@(posedge BCLKO);
		end
	endtask
	
      
endmodule

