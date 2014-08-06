module SURF_command_receiver( input         clk33_i,
			      input 	    rst_i,
			      input 	    cmd_i,
			      output [1:0]  event_id_buffer_o,
			      output 	    event_id_wr_o,
			      output [31:0] event_id_o,
			      output [3:0]  digitize_o );

   (* IOB = "TRUE" *)
   reg 					    cmd_in = 0;
   reg [1:0] 				    buf_bit = {2{1'b0}};   
   reg [31:0] 				    shift_in = {32{1'b0}};   
   reg [4:0] 				    shift_counter = {5{1'b0}};
   wire [5:0] 				    shift_counter_plus_one = shift_counter + 1;
   reg [3:0] 				    digitize_flag = {4{1'b0}};   
   
   always @(posedge clk33_i) begin : IOB_LOGIC
      cmd_in <= cmd_i;
   end

   localparam FSM_BITS = 4;
   localparam [FSM_BITS-1:0] IDLE = 0;
   localparam [FSM_BITS-1:0] BUF_BIT_0 = 1;
   localparam [FSM_BITS-1:0] BUF_BIT_1 = 2;
   localparam [FSM_BITS-1:0] SHIFT = 3;
   localparam [FSM_BITS-1:0] DIGITIZE = 4;
   reg [FSM_BITS-1:0] state = IDLE;

   always @(posedge clk33_i) begin : FSM_LOGIC
      if (rst_i) state <= IDLE;
      else begin
	 case (state)
	   IDLE: if (cmd_in) state <= BUF_BIT_0;
	   BUF_BIT_0: state <= BUF_BIT_1;
	   BUF_BIT_1: state <= SHIFT;
	   SHIFT: if (shift_counter_plus_one[5]) state <= DIGITIZE;
	   DIGITIZE: state <= IDLE;
	 endcase // case (state)
      end
   end // always @ (posedge clk33_i)
   
   always @(posedge clk33_i) begin
      if (state == BUF_BIT_0) buf_bit[0] <= cmd_in;
      if (state == BUF_BIT_1) buf_bit[1] <= cmd_in;
      if (state == SHIFT) begin
			shift_in <= {cmd_in,shift_in[31:1]};
      end

		if (state == SHIFT) shift_counter <= shift_counter_plus_one;
		else shift_counter <= {5{1'b0}};

      if (state == DIGITIZE && !cmd_in) digitize_flag[buf_bit] <= 1;
      else digitize_flag <= {4{1'b0}};      
   end

   assign digitize_o = digitize_flag;
   assign event_id_o = shift_in;
   assign event_id_wr_o = (state == DIGITIZE && !cmd_in);
   assign event_id_buffer_o = buf_bit;
      
endmodule // SURF_command_receiver

   
      
	   
      
			  
   
