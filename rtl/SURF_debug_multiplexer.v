//module SURF_debug_multiplexer( input [34:0] in0,
//										 input [34:0] in1,
//										 input [34:0] in2,
//										 input [34:0] in3,
//										 output [5:0] vio_out,										 
//										 input clk_i,
//										 input MSEL,
//										 input MTCK,
//										 input MTMS,
//										 input MTDI,
//										 output MTDO
//										);
//	// ChipScope debugging cores.
//	wire [35:0] ila_control;
//	wire [35:0] vio_control;
//	wire [7:0] vio_async_in;
//	wire [1:0] sel_i = vio_async_in[1:0];
//	assign vio_out = vio_async_in[7:2];
//	reg [34:0] mux_reg = {35{1'b0}};
//	always @(posedge clk_i) begin
//		case (sel_i)
//			2'b00: mux_reg <= in0;
//			2'b01: mux_reg <= in1;
//			2'b10: mux_reg <= in2;
//			2'b11: mux_reg <= in3;
//		endcase
//	end
//
//	assign out = mux_reg;
//	// This doesn't seem to quite work - let's hold off on this for now.
//	/*
//	wire iUPDATE, iSHIFT, iRESET, iTDI, iSEL1, iDRCK1, iSEL2, iDRCK2, iCAPTURE;
//	wire iTDO2 = iTDI;
//	wire TDO;
//	bscan_equiv u_bscan_equiv(.JTCK(MTCK),.JTMS(MTMS),.JTDO(MTDO),.JTDI(MTDI),
//							  .UPDATE(iUPDATE),.SHIFT(iSHIFT),.RESET(iRESET),
//							  .TDI(iTDI),.SEL1(iSEL1),.SEL2(iSEL2),.DRCK1(iDRCK1),.DRCK2(iDRCK2),
//							  .CAPTURE(iCAPTURE),.TDO1(TDO),.TDO2(iTDO2));
//	wire jUPDATE, jSHIFT, jRESET, jTDI, jSEL1, jDRCK1, jSEL2, jDRCK2, jCAPTURE;
//	wire jTDO2 = jTDI;
//*/
////	BSCAN_SPARTAN3 u_bscan(.UPDATE(jUPDATE),.SHIFT(jSHIFT),.RESET(jRESET),
////								  .TDI(jTDI),.SEL1(jSEL1),.SEL2(jSEL2),.DRCK1(jDRCK1),.DRCK2(jDRCK2),
////								  .CAPTURE(jCAPTURE),.TDO1(TDO),.TDO2(jTDO2));
//	
////	wire UPDATE, SHIFT, RESET, TDI, SEL1, DRCK1, CAPTURE;
////	assign UPDATE = jUPDATE;
////	assign SHIFT = jSHIFT;
////	assign RESET = jRESET;
////	assign TDI = jTDI;
////	assign DRCK1 = jDRCK1;
////	assign CAPTURE = jCAPTURE;
////	assign SEL1 = jSEL1;
//	(* BOX_TYPE = "black_box" *)
//	cs_icon u_icon(.CONTROL0(ila_control),.CONTROL1(vio_control));
////	cs_icon u_icon(.CONTROL0(ila_control),.CONTROL1(vio_control),
////						.TDO_OUT(TDO),
////						.TDI_IN(TDI),
////						.RESET_IN(RESET),
////						.SHIFT_IN(SHIFT),
////						.UPDATE_IN(UPDATE),
////						.CAPTURE_IN(CAPTURE),
////						.SEL_IN(SEL1),
////						.DRCK_IN(DRCK1));
//	(* BOX_TYPE = "black_box" *)
////	cs_ila u_ila(.CONTROL(ila_control),.CLK(clk33),.TRIG0(debug_muxer));
//	cs_ila u_ila(.CONTROL(ila_control),.CLK(clk_i),.TRIG0(mux_reg));
//	(* BOX_TYPE = "black_box" *)
//	cs_vio u_vio(.CONTROL(vio_control),.ASYNC_OUT(vio_async_in));
//										 
//endmodule

module SURF_debug_multiplexer( input [34:0] in0,
										 input [34:0] in1,
										 input [34:0] in2,
										 input [34:0] in3,
										 input clk_i,
										 input [1:0] sel_i,
										 output [34:0] out);
	reg [34:0] mux_reg = {35{1'b0}};
	always @(posedge clk_i) begin
		case (sel_i)
			2'b00: mux_reg <= in0;
			2'b01: mux_reg <= in1;
			2'b10: mux_reg <= in2;
			2'b11: mux_reg <= in3;
		endcase
	end

	assign out = mux_reg;

endmodule											 