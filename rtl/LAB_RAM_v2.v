module LAB_RAM_v2( input clk_i,
		   input [15:0]  dat_i,
		   input [11:0]  waddr_i,
		   input 	 wr_i,
		   input [10:0]  raddr_i,
		   output [31:0] dat_o);

   // We need 3 block RAMs, because we never write to
   // 3072-4096.
   wire [31:0] 			 dat_out[3:0];
   wire [31:0] 			 dat_muxed;
   
   RAMB16_S18_S36 bram_A(.CLKA(clk_i),
			 .WEA(wr_i),
			 .ENA(waddr_i[11:10] == 2'b00),
			 .SSRA(1'b0),
			 .ADDRA(waddr_i[9:0]),
			 .DIA(dat_i),
			 .DIPA(2'b00),
			 .CLKB(clk_i),
			 .WEB(1'b0),
			 .ENB(raddr_i[10:9] == 2'b00),
			 .SSRB(1'b0),
			 .ADDRB(raddr_i[8:0]),
			 .DOB(dat_out[0]));
   RAMB16_S18_S36 bram_B(.CLKA(clk_i),
			 .WEA(wr_i),
			 .ENA(waddr_i[11:10] == 2'b01),
			 .SSRA(1'b0),
			 .ADDRA(waddr_i[9:0]),
			 .DIA(dat_i),
			 .DIPA(2'b00),
			 .CLKB(clk_i),
			 .WEB(1'b0),
			 .ENB(raddr_i[10:9] == 2'b01),
			 .SSRB(1'b0),
			 .ADDRB(raddr_i[8:0]),
			 .DOB(dat_out[1]));
   RAMB16_S18_S36 bram_C(.CLKA(clk_i),
			 .WEA(wr_i),
			 .ENA(waddr_i[11:10] == 2'b10),
			 .SSRA(1'b0),
			 .ADDRA(waddr_i[9:0]),
			 .DIA(dat_i),
			 .DIPA(2'b00),
			 .CLKB(clk_i),
			 .WEB(1'b0),
			 .ENB(raddr_i[10:9] == 2'b10),
			 .SSRB(1'b0),
			 .ADDRB(raddr_i[8:0]),
			 .DOB(dat_out[2]));
   assign dat_out[3] = dat_out[1];

   assign dat_muxed = dat_out[raddr_i[10:9]];			 
   assign dat_o = dat_muxed;

   
endmodule // LAB_RAM_v2

		   
