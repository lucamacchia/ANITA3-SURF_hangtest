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
module TOP_v38(
		input nADS,
		input WnR,
		input nRD,
		inout [31:0] LD,
		input [7:2] LA,
		input nCS2,
		input nCS3,
		output nREADY,
		output nBTERM,
		
		
		input [11:0] AD_D,
		input AD_NBUSY,
		output [2:0] ASS,
		output AD_NCONVST, 
		output AD_NCS, 
		output AD_NRD, 

		
		input [5:0] BAD,
		
		input BCLKO,
		output LCLK,
		input CLK125_P,
		input CLK125_N,
		input CMD_P,
		input CMD_N,
		input [3:0] HOLD_P,
		input [3:0] HOLD_N,
		input REF_P,
		input REF_N,
	
		input [7:0] A1TC,
		input [7:0] A2TC,
		input [7:0] A3TC,
		input [7:0] A4TC,
		input [7:0] VTRG_A1TC,
		input [7:0] VTRG_A2TC,
		input [7:0] VTRG_A3TC,
		input [7:0] VTRG_A4TC,
		
		output [3:0] L1_P,
		output [3:0] L1_N,
		
		// LAB innputs.
		output 		 A_GCK,
		output		 A_GCCLR,
		output		 A_RAMP,
		output [3:0] A_CS,
		output [7:0] A_S,
		output 		 A_SELMAIN,
		output 		 A_SELTAIL,
		output 		 A_NRUN,
		input 		 A_HITBUS,
		input 		 A_RCO,
		input [11:0] A_DAT,
		output		 A_TREF_P,
		output		 A_TREF_N,
		
		output 		 B_GCK,
		output		 B_GCCLR,
		output		 B_RAMP,
		output [3:0] B_CS,
		output [7:0] B_S,
		output 		 B_SELMAIN,
		output 		 B_SELTAIL,
		output 		 B_NRUN,
		input 		 B_HITBUS,
		input 		 B_RCO,
		input [11:0] B_DAT,
		output		 B_TREF_P,
		output		 B_TREF_N,

		output 		 C_GCK,
		output		 C_GCCLR,
		output		 C_RAMP,
		output [3:0] C_CS,
		output [7:0] C_S,
		output 		 C_SELMAIN,
		output 		 C_SELTAIL,
		output 		 C_NRUN,
		input 		 C_HITBUS,
		input 		 C_RCO,
		input [11:0] C_DAT,
		output		 C_TREF_P,
		output		 C_TREF_N,

		output 		 D_GCK,
		output		 D_GCCLR,
		output		 D_RAMP,
		output [3:0] D_CS,
		output [7:0] D_S,
		output 		 D_SELMAIN,
		output 		 D_SELTAIL,
		output 		 D_NRUN,
		input 		 D_HITBUS,
		input 		 D_RCO,
		input [11:0] D_DAT,
		output		 D_TREF_P,
		output		 D_TREF_N,
		
		output SCLK,
		output NSYNC,
		output [7:0] DIN,
		
		// PLX-based debug chain.
//		input MSEL,
//		input MTCK,
//		input MTMS,
//		input MTDI,
//		output MTDO,
		
		// Unuseds.
		output [3:0] CALSNH,
		output [3:0] TCS,
		output [3:0] RSS,
		
		output BUSY_A
    );

	// Global clocks.
	
	wire clk33;
	wire clk100;
	wire clk125;
	wire clk250;
	wire clk250b;
	
	// Clock output.
	wire [3:0] TREF_P;
	wire [3:0] TREF_N;
	assign A_TREF_P = TREF_P[0]; assign A_TREF_N = TREF_N[0];
	assign B_TREF_P = TREF_P[1]; assign B_TREF_N = TREF_N[1];
	assign C_TREF_P = TREF_P[2]; assign C_TREF_N = TREF_N[2];
	assign D_TREF_P = TREF_P[3]; assign D_TREF_N = TREF_N[3];
	
	// Reference pulse from TURF.
	wire REF;
	
	// TURF HOLD inputs
	wire [3:0] HOLD;

	// Global reset.
	
	wire clr_all;

	// MESSv2 <-> LAB_TOPv2 interface.
	wire [3:0] 		lab_digitize;
	wire [12:0] 	lab_addr;
	wire [31:0] 	lab_dat;
	wire 				lab_ready;

	// Trigger inputs.
	// These are NOT individual antennas. They're individual SHORT inputs.
	// At some point in the long, distant past, they were individual antennas.
	wire [7:0] ANT_A;
	wire [7:0] ANT_B;
	wire [7:0] ANT_C;
	wire [7:0] ANT_D;
	wire [31:0] trig_scaler_path;

	// Trigger outputs.
	wire [3:0] L1;
	// Scalers, with creative mapping.
	wire [31:0] CR;
	// Mask register, I guess?
	wire [31:0] short_mask;
	// Some monitoring stuff that I have no idea what it does.
	wire [7:0] mon_scaler;
	wire L1MON2;
	wire L1MON3;
	wire L1MON4;
	
	SURF_infrastructure #(.REF_CLOCK("33MHZ")) u_infrastructure( .clk33_o(clk33),
																					 .clk100_o(clk100),
																					 .clk125_o(clk125),
																					 .clk250_o(clk250),
																					 .clk250b_o(clk250b),
																					 .clr_all_i(clr_all),
																					 .CLK125_P(CLK125_P),.CLK125_N(CLK125_N),
																					 .LCLK(LCLK),
																					 .BCLKO(BCLKO),
																					 .CMD_P(CMD_P),.CMD_N(CMD_N),.CMD(command),
																					 .HOLD_P(HOLD_P),.HOLD_N(HOLD_N),.HOLD(HOLD),
																					 .TREF_P(TREF_P),.TREF_N(TREF_N),
																					 .REF_P(REF_P),.REF_N(REF_N),.REF(REF),
																					 .L1_P(L1_P),.L1_N(L1_N),.L1(L1));
	// Trigger infrastructure.
	Trig_RX u_trigger_rx(.A1TC(A1TC),.A2TC(A2TC),.A3TC(A3TC),.A4TC(A4TC),
								.VTRG_A1TC(VTRG_A1TC),.VTRG_A2TC(VTRG_A2TC),.VTRG_A3TC(VTRG_A3TC),.VTRG_A4TC(VTRG_A4TC),
								.out_for_scaler(trig_scaler_path),
								.ANT_A(ANT_A),.ANT_B(ANT_B),.ANT_C(ANT_C),.ANT_D(ANT_D));
	// Trigger.
	Level1_Trigger level1trigger(.ANT_A(ANT_A),.ANT_B(ANT_B),.ANT_C(ANT_C),.ANT_D(ANT_D),
									 .ANT_A_for_scalers(trig_scaler_path[0 +: 8]),
									 .ANT_B_for_scalers(trig_scaler_path[8 +: 8]),
									 .ANT_C_for_scalers(trig_scaler_path[16 +: 8]),
									 .ANT_D_for_scalers(trig_scaler_path[24 +: 8]),
									 .CLK(clk33),.CLR_ALL(clr_all),.REFPULSE(REF),								 
									 .L1(L1),
									 .mask_pass(short_mask),
									 .CR(CR),
									 .MONSCALER(mon_scaler),
									 .MON2(L1MON2),
									 .MON3(L1MON3),
									 .MON4(L1MON4),
									 .CLK125(clk125),
									 .CLK250(clk250),
									 .CLK250_180(clk250b));									 
	
	wire [34:0] lab_debug;
	wire [1:0] lab_debug_sel;
	// LAB readout and memory.
	LAB_TOPv2 u_labtop( .clk_i(clk33),
							  .clk100_i(clk100),
							  .rst_i(clr_all),
							  .hold_i(HOLD),
							  .digitize_i(lab_digitize),
							  .addr_i(lab_addr),
							  .dat_o(lab_dat),
							  .done_o(lab_ready),
							  .A_SELTAIL(A_SELTAIL),
							  .A_SELMAIN(A_SELMAIN),
							  .A_GCK(A_GCK),
							  .A_RAMP(A_RAMP),
							  .A_GCCLR(A_GCCLR),
							  .A_NRUN(A_NRUN),
							  .A_CS(A_CS),
							  .A_S(A_S),
							  .A_HITBUS(A_HITBUS),
							  .A_RCO(A_RCO),
							  .A_DAT(A_DAT),
							  
							  .B_SELTAIL(B_SELTAIL),
							  .B_SELMAIN(B_SELMAIN),
							  .B_GCK(B_GCK),
							  .B_RAMP(B_RAMP),
							  .B_GCCLR(B_GCCLR),
							  .B_NRUN(B_NRUN),
							  .B_CS(B_CS),
							  .B_S(B_S),
							  .B_HITBUS(B_HITBUS),
							  .B_RCO(B_RCO),
							  .B_DAT(B_DAT),

							  .C_SELTAIL(C_SELTAIL),
							  .C_SELMAIN(C_SELMAIN),
							  .C_GCK(C_GCK),
							  .C_RAMP(C_RAMP),
							  .C_GCCLR(C_GCCLR),
							  .C_NRUN(C_NRUN),
							  .C_CS(C_CS),
							  .C_S(C_S),
							  .C_HITBUS(C_HITBUS),
							  .C_RCO(C_RCO),
							  .C_DAT(C_DAT),

							  .D_SELTAIL(D_SELTAIL),
							  .D_SELMAIN(D_SELMAIN),
							  .D_GCK(D_GCK),
							  .D_RAMP(D_RAMP),
							  .D_GCCLR(D_GCCLR),
							  .D_NRUN(D_NRUN),
							  .D_CS(D_CS),
							  .D_S(D_S),
							  .D_HITBUS(D_HITBUS),
							  .D_RCO(D_RCO),
							  .D_DAT(D_DAT),
							  .debug_sel_i(lab_debug_sel),
							  .debug_o(lab_debug)
		);


	wire dac_wr;
	wire dac_busy;
	wire dac_update;
	wire [4:0] dac_waddr;
	wire [4:0] dac_raddr;
	wire [15:0] dac_dat_in;
	wire [15:0] dac_dat_out;


	wire [34:0] td_debug;
	
	assign td_debug[16:0] = CR[16:0];
	assign td_debug[34:17] = {18{1'b0}};

	DAC_CTRL_v3 u_dacs( 	.clk_i(clk33),
								.dac_we_i(dac_wr),
								.busy_o(dac_busy),
								.dac_waddr_i(dac_waddr),
								.dac_dat_i(dac_dat_in),
								.dac_raddr_i(dac_raddr),
								.dac_dat_o(dac_dat_out),
								.update_i(dac_update),
								.SCLK(SCLK),
								.NSYNC(NSYNC),
								.DIN(DIN));
						
	wire [4:0] 	scal_addr;
	wire 			scal_rd;
	wire [15:0] scal_dat_out;
	wire [15:0] refpulse_cnt;
	
	SCALER_TOPv2 u_scalers( .clk33_i(clk33),
									.scal_i(CR[16:0]),
									.scal_addr_i(scal_addr),
									.scal_rd_i(scal_rd),
									.scal_dat_o(scal_dat_out),
									.refpulse_cnt_o(refpulse_cnt));
									
									
	//Ben's Power monitor
	wire [4:0] rfp_addr;
	wire [15:0] RFPWR;
	
	wire [11:0] AData_debug;
	wire [5:0] signals_debug;
	wire [25:0] adder_debug;
	wire [15:0] sampleCount_debug;
	wire AD_nCS_debug;
	wire AD_nCONVST_debug;
	wire AD_nRD_debug;
	wire [34:0] RFpower_debug;
	
   RF_Pow_Ben  u_RF_power(
	 .AD_nBusy(AD_NBUSY),      //tells when the ADC is busy (active low)
    .AData(AD_D), //data from external ADC chip
    .CLK(clk33), //33MHz input CPCI clock
	 .RAD(rfp_addr), //read address
	 .RCLK(1'b0),
    .MUXSel(ASS), //8 possible selections, 3 bits (output to chip) ASS
    .RFPWR(RFPWR),    //blockram data register selected by RAD and read out by RCLK
	 .AD_nCONVST(AD_NCONVST), //command to convert (active low)
    .AD_nCS(AD_NCS),     //chip select, should be always on (active low)
    .AD_nRD(AD_NRD),     //command to read (active low)
	 //debug signal
	  .AData_debug(AData_debug),
	  .signals_debug(signals_debug), //5:4=sample_state, 3:2=write_state, 1=changeSig_flag, 0=changeSigHold_flag
	  .adder_debug(adder_debug),
	  .sampleCount_debug(sampleCount_debug),
	  .AD_nCS_debug(AD_nCS_debug),
	  .AD_nCONVST_debug(AD_nCONVST_debug),
	  .AD_nRD_debug(AD_nRD_debug)
    );
    assign RFpower_debug[20:0] = { AD_nRD_debug, AD_nCONVST_debug, AD_nCS_debug, signals_debug, AData_debug };
    
	 
	// MESS debugging.
	wire [34:0] debug;
	wire busy_flag;
	// PLX/register interface
	MESSv2 u_mess(		  .clk_i(clk33),
							  .cmd_i(command),
							  .lab_dat_i(lab_dat),
							  .lab_ready_i(lab_ready),
							  .lab_addr_o(lab_addr),
							  .lab_digitize_o(lab_digitize),
//							  .rfp_dat_i(rfp_addr),
							  .rfp_dat_i(RFPWR),
							  .rfp_addr_o(rfp_addr),
							  .clr_all_o(clr_all),

							  .dac_waddr_o(dac_waddr),
							  .dac_raddr_o(dac_raddr),
							  .dac_wr_o(dac_wr),
							  .dac_update_o(dac_update),
							  .dac_busy_i(dac_busy),
							  .dac_dat_i(dac_dat_out),
							  .dac_dat_o(dac_dat_in),
	
							  .scal_addr_o(scal_addr),
							  .scal_rd_o(scal_rd),
							  .scal_dat_i(scal_dat_out),
							  .refpulse_cnt_i(refpulse_cnt),
	
							  .short_mask_o(short_mask),
							  .board_id_i(BAD),
							  .busy_flag_o(busy_flag),
							  
							  .nADS(nADS),
							  .WnR(WnR),
							  .LA(LA),
							  .LD(LD),
							  .nCS2(nCS2),
							  .nCS3(nCS3),
							  .nRD(nRD),
							  .nREADY(nREADY),
							  .nBTERM(nBTERM),
							  .debug_o(debug)
	);

//	wire [5:0] vio_out;
//	assign lab_debug_sel = vio_out[1:0];
//	SURF_debug_multiplexer u_mux(.in0(debug),
//										  .in1(lab_debug),
//										  .in2(td_debug),
////										  .in3(lab_debug),
//										  .in3(RFpower_debug),
//										  .clk_i(clk33),
//										  .vio_out(vio_out),
//										  .MTCK(MTCK),.MTMS(MTMS),.MTDO(MTDO),.MTDI(MTDI));
//	
		// ChipScope debugging cores.
	wire [35:0] ila_control;
	wire [35:0] vio_control;
	wire [7:0] vio_async_in;
	wire [34:0] debug_muxer;
	SURF_debug_multiplexer u_mux(.in0(debug),
										  .in1(lab_debug),
										  .in2(td_debug),
										  .in3(RFpower_debug),
										  .clk_i(clk33),
										  .sel_i(vio_async_in[1:0]),
										  .out(debug_muxer));


	(* BOX_TYPE = "black_box" *)
	cs_icon u_icon(.CONTROL0(ila_control),.CONTROL1(vio_control));
//	cs_icon u_icon(.CONTROL0(ila_control));
	(* BOX_TYPE = "black_box" *)
	cs_ila u_ila(.CONTROL(ila_control),.CLK(clk33),.TRIG0(debug_muxer));
	(* BOX_TYPE = "black_box" *)
	cs_vio u_vio(.CONTROL(vio_control),.ASYNC_OUT(vio_async_in));
	
	
	// Unused LAB test crap.
	// CALSNH = VCC
	// RSS = VCC
	// TCS = GND
	assign CALSNH = {4{1'b1}};
	assign RSS = {4{1'b1}};
	assign TCS = {4{1'b0}};
	
	assign BUSY_A = busy_flag;
endmodule
