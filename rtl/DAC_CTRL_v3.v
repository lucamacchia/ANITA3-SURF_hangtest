module DAC_CTRL_v3( input clk_i,
		    input dac_we_i,
		    input [4:0] dac_waddr_i,
		    input [15:0] dac_dat_i,
			 input [4:0] dac_raddr_i,
		    output [15:0] dac_dat_o,
		    input update_i,
			 output busy_o,
		    output SCLK,
		    output NSYNC,
		    output [7:0] DIN );
   
   reg [11:0] 			 dac_storage[7:0][3:0];
   wire [11:0] 			 dac_out[7:0];
   reg [1:0] 			 dac_sel = {2{1'b0}};
   wire [2:0] 			 dac_sel_plus_one = dac_sel + 1;   
   reg [15:0] 			 dac_shift_regs[7:0];
   
   integer 			 i,j;
   initial begin
      for (i=0;i<8;i=i+1) begin
			 for (j=0;j<4;j=j+1) begin
				 dac_storage[i][j] <= {12{1'b0}};	    
			 end
			 dac_shift_regs[i] <= {16{1'b0}};	 
      end
   end
   
   integer k;  
   always @(posedge clk_i) begin
      for (k=0;k<8;k=k+1) begin
			if (dac_we_i && (dac_waddr_i[4:2] == k))
					dac_storage[k][dac_waddr_i[1:0]] <= dac_dat_i[11:0];
      end
   end
   generate
      genvar l;
      for (l=0;l<8;l=l+1) begin : LP
		 assign dac_out[l] = dac_storage[l][dac_sel];
		 assign DIN[l] = dac_shift_regs[l][15];
      end
   endgenerate

   reg [15:0] dac_dat_out = {16{1'b0}};
   always @(posedge clk_i) begin
      dac_dat_out <= dac_storage[dac_raddr_i[4:2]][dac_raddr_i[1:0]];
   end

   localparam FSM_BITS = 3;
   localparam [FSM_BITS-1:0] IDLE = 0;
   localparam [FSM_BITS-1:0] LOAD = 1;   
   localparam [FSM_BITS-1:0] NSYNC_LOW = 2;
   localparam [FSM_BITS-1:0] SHIFT_LOW = 3;
   localparam [FSM_BITS-1:0] SHIFT_HIGH = 4;
   localparam [FSM_BITS-1:0] SHIFT_DONE = 5;
   localparam [FSM_BITS-1:0] DONE = 6;
   reg [FSM_BITS-1:0] state = IDLE;

   reg 		      updating = 0;
   integer 	      m;
   (* IOB = "TRUE" *)
   reg 		      sclk_reg = 0;
   (* IOB = "TRUE" *)
   reg nsync_reg = 1;

   reg [3:0] shift_count = {4{1'b0}};
   wire [4:0] shift_count_plus_one = shift_count + 1;   
   //LM added
	reg toggle = 1'b0;
	reg update_d = 1'b0;
	reg update_slow = 1'b0;
	//LM added end
   always @(posedge clk_i) begin
	
		toggle = ~toggle; //LM added
//		toggle = 1'b1;
		update_d<= update_i;
		update_slow<= update_d | update_i;
		if(toggle)
		 begin
		if (update_i) begin 
								updating <= 1;
						  end
		else if (state == DONE) updating <= 0;
		
	   if(toggle) //LM added
			begin
				case (state)
					IDLE: if (update_slow) state <= LOAD;
		//			IDLE: if (update_i ) state <= LOAD;
					LOAD: state <= NSYNC_LOW;
					NSYNC_LOW: state <= SHIFT_LOW;
					SHIFT_LOW: if (shift_count_plus_one[4]) state <= SHIFT_DONE;
								  else state <= SHIFT_HIGH;
					SHIFT_HIGH: state <= SHIFT_LOW;
					SHIFT_DONE: if (dac_sel_plus_one[2]) state <= DONE;
								  else state <= LOAD;
					DONE: state <= IDLE;
				endcase
				
				if (state == SHIFT_DONE) shift_count <= {4{1'b0}};      
				else if (state == SHIFT_HIGH) shift_count <= shift_count_plus_one;
				

				if (update_slow) updating <= 1;
				else if (state == DONE) updating <= 0;

				if (state == LOAD) nsync_reg <= 0;
				else if ((state == SHIFT_DONE) && shift_count_plus_one[4]) 
					nsync_reg <= 1;
						
				sclk_reg <= !(state == SHIFT_LOW);
				
				if (state == SHIFT_DONE) dac_sel <= dac_sel_plus_one;
				for (m=0;m<8;m=m+1) begin
					if (state == LOAD) begin
						 dac_shift_regs[m] <= {dac_sel[1],dac_sel[0],1'b1,
															 !(dac_sel[1] && dac_sel[0]),
															 dac_out[m]};
					end else if (state == SHIFT_HIGH) begin
						dac_shift_regs[m] <= {dac_shift_regs[m][14:0],1'b0};
					end
				end      
		   end
     end // toggle
   end //always
	assign NSYNC = nsync_reg;
	assign SCLK = sclk_reg;
	assign dac_dat_o = dac_dat_out;
	assign busy_o = updating;
endmodule // DAC_CTRL_v3

		    