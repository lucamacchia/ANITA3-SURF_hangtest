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
module LAB_TOPv2(
			 input 		 clk_i,
			 input 		 clk100_i,
			 input		 rst_i,
			 input [3:0] hold_i,
			 input [3:0] digitize_i,
			 
	       output 	    A_SELTAIL,
	       output 	    A_SELMAIN,
			 output A_GCK,
			 output A_RAMP,
			 output A_GCCLR,
			 output A_NRUN,
	       output [3:0] A_CS,
	       output [7:0] A_S,
	       input 	    A_HITBUS,
	       input 	    A_RCO,
	       input [11:0] A_DAT,

			 output B_GCK,
			 output B_RAMP,
			 output B_GCCLR,
			 output B_NRUN,
	       output 	    B_SELTAIL,
	       output 	    B_SELMAIN,
	       output [3:0] B_CS,
	       output [7:0] B_S,
	       input 	    B_HITBUS,
	       input 	    B_RCO,
	       input [11:0] B_DAT,

			 output C_GCK,
			 output C_RAMP,
			 output C_GCCLR,			 
			 output C_NRUN,
	       output 	    C_SELTAIL,
	       output 	    C_SELMAIN,
	       output [3:0] C_CS,
	       output [7:0] C_S,
	       input 	    C_RCO,
	       input 	    C_HITBUS,
	       input [11:0] C_DAT,

			 output D_GCK,
			 output D_RAMP,
			 output D_GCCLR,			 
			 output D_NRUN,
	       output 	    D_SELTAIL,
	       output 	    D_SELMAIN,
	       output [3:0] D_CS,
	       output [7:0] D_S,
	       input 	    D_RCO,
	       input 	    D_HITBUS, 
	       input [11:0] D_DAT,
			 // [12:11] select which LAB is being read out.
			 input [12:0] addr_i,
			 output [31:0] dat_o,
			 output 		  done_o,
			 input	[1:0] debug_sel_i,
			 output [34:0] debug_o
    );

	wire [3:0] 			lab_readout;
   wire [11:0] 		    lab_addr[3:0];
   wire [15:0] 		    lab_dat[3:0];
   wire [3:0] 		    lab_wr;
   reg [3:0] 		    lab_done = {4{1'b0}};
	wire [3:0] 			readout_done;
	
   wire [31:0] 		    ram_dat[3:0];
   
   wire [3:0] 		    SELMAIN;
   wire [3:0] 		    SELTAIL;
   wire [7:0] 		    S[3:0];
   wire [3:0] 		    CS[3:0];
	wire [3:0] 			 RAMP;
	wire [3:0]			 GCK;
	wire [3:0]			 GCCLR;
   wire [3:0] 		    HITBUS;
   wire [3:0] 		    RCO;
   wire [11:0] 		    DAT[3:0];	      

	wire [34:0] lab_debug[3:0];

	integer j;
	always @(posedge clk_i) begin
		for (j=0;j<4;j=j+1) begin
			if (rst_i) lab_done[j] <= 0;
			else if (digitize_i[j]) lab_done[j] <= 0;
			else if (readout_done[j]) lab_done[j] <= 1;
		end
	end

   // The LAB_RAM here uses 3 block RAMs to generate
   // a 3072x16 RAM with a 1536x32 readout port.
   // This means we use 12 block RAMs in total.
   generate
      genvar 		    i;
      for (i=0;i<4;i=i+1) begin : LAB
			 wire digitize_100;
			 wire readout_100;
			 wire read_done_100;
			 flag_sync u_read_done_sync(.clkA(clk_i),.in_clkA(readout_done[i]),
												 .clkB(clk100_i),.out_clkB(read_done_100));
			 flag_sync u_digitize_sync(.clkA(clk_i),.in_clkA(digitize_i[i]),
									.clkB(clk100_i),.out_clkB(digitize_100));
			 flag_sync u_readout_sync(.clkA(clk100_i),.in_clkA(readout_100),
									.clkB(clk_i),.out_clkB(lab_readout[i]));
			 lab_adc_test u_test(.clk_i(clk100_i),
										.read_done_i(read_done_100),
										.start_i(digitize_100),
										.done_o(readout_100),
										.CLR(GCCLR[i]),
										.RAMP(RAMP[i]),
										.GCK(GCK[i]));
			 LAB_CTRL_v2 u_lab(.clk_i(clk_i),
						.rst_i(rst_i),
						.readout_i(lab_readout[i]),
						.hold_i(hold_i[i]),
						.addr_o(lab_addr[i]),
						.dat_o(lab_dat[i]),
						.wr_o(lab_wr[i]),
						.done_o(readout_done[i]),

						.SELMAIN(SELMAIN[i]),
						.SELTAIL(SELTAIL[i]),
						.S(S[i]),
						.CS(CS[i]),
						.HITBUS(HITBUS[i]),
						.RCO(RCO[i]),
						.DAT(DAT[i]),
						.debug_o(lab_debug[i]));
			 LAB_RAM_v2 u_ram(.clk_i(clk_i),
					  .dat_i(lab_dat[i]),
					  .waddr_i(lab_addr[i]),
					  .wr_i(lab_wr[i]),
					  .raddr_i(addr_i[10:0]),
					  .dat_o(ram_dat[i]));			  
      end // block: LAB
   endgenerate
   
   assign A_SELMAIN = SELMAIN[ 0 ]; 
   assign A_SELTAIL = SELTAIL[ 0 ]; 
   assign A_S = S[ 0 ];             
   assign A_CS = CS[ 0 ];           
   assign HITBUS[ 0 ] = A_HITBUS;   
   assign RCO[ 0 ] = A_RCO;        
   assign DAT[ 0 ] = A_DAT;
	assign A_RAMP = RAMP[ 0 ];
	assign A_GCK = GCK[ 0 ];
	assign A_GCCLR = GCCLR[ 0 ];
	
   assign B_SELMAIN = SELMAIN[ 1 ]; 
   assign B_SELTAIL = SELTAIL[ 1 ]; 
   assign B_S = S[ 1 ];             
   assign B_CS = CS[ 1 ];           
   assign HITBUS[ 1 ] = B_HITBUS;   
   assign RCO[ 1 ] = B_RCO;        
   assign DAT[ 1 ] = B_DAT;  
	assign B_RAMP = RAMP[ 1 ];
	assign B_GCK = GCK[ 1 ];
	assign B_GCCLR = GCCLR[ 1 ];

   assign C_SELMAIN = SELMAIN[ 2 ]; 
   assign C_SELTAIL = SELTAIL[ 2 ]; 
   assign C_S = S[ 2 ];             
   assign C_CS = CS[ 2 ];           
   assign HITBUS[ 2 ] = C_HITBUS;   
   assign RCO[ 2 ] = C_RCO;        
   assign DAT[ 2 ] = C_DAT;   
	assign C_RAMP = RAMP[ 2 ];
	assign C_GCK = GCK[ 2 ];
	assign C_GCCLR = GCCLR[ 2 ];

   assign D_SELMAIN = SELMAIN[ 3 ]; 
   assign D_SELTAIL = SELTAIL[ 3 ]; 
   assign D_S = S[ 3 ];             
   assign D_CS = CS[ 3 ];           
   assign HITBUS[ 3 ] = D_HITBUS;   
   assign RCO[ 3 ] = D_RCO;        
   assign DAT[ 3 ] = D_DAT;     			   
	assign D_RAMP = RAMP[ 3 ];
	assign D_GCK = GCK[ 3 ];
	assign D_GCCLR = GCCLR[ 3 ];

	assign done_o = lab_done[addr_i[12:11]];
	assign dat_o = ram_dat[addr_i[12:11]];

	assign A_NRUN = hold_i[0];
	assign B_NRUN = hold_i[1];
	assign C_NRUN = hold_i[2];
	assign D_NRUN = hold_i[3];

	reg [1:0] lab_debug_sel = {2{1'b0}};
	reg [29:0] lab_debug_multiplexed = {30{1'b0}};
	always @(posedge clk_i) begin
		lab_debug_multiplexed <= lab_debug[lab_debug_sel][29:0];
		lab_debug_sel <= debug_sel_i;
	end

	assign debug_o = lab_debug_multiplexed[29:0];

endmodule
