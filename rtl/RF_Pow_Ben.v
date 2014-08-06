`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:56:22 07/21/2014 
// Design Name: 
// Module Name:    RF_Pow_Ben 
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
//    Ben Rotter (BenJRotter@gmail.com) - University of Hawaii at Manoa - July 2014
//////////////////////////////////////////////////////////////////////////////////
module RF_Pow_Ben(
	 input AD_nBusy,      //tells when the ADC is busy (active low)
    input [11:0] AData, //data from external ADC chip
    input CLK, //33MHz input CPCI clock
	 input [4:0] RAD, //read address
	 input RCLK, //read clock
    output [2:0] MUXSel, //8 possible selections, 3 bits (output to chip)
    output [15:0] RFPWR,    //blockram data register selected by RAD and read out by RCLK
	 output AD_nCONVST, //command to convert (active low)
    output AD_nCS,     //chip select, should be always on (active low)
    output AD_nRD,      //command to read (active low)
	 
	 //chipscope debugging stuff
	 output [11:0] AData_debug,
	 output [5:0] signals_debug, //5:4=sample_state, 3:2=write_state, 1=changeSig_flag, 0=changeSigHold_flag
	 output [25:0] adder_debug,
	 output [15:0] sampleCount_debug,
	 output AD_nCS_debug,
	 output AD_nCONVST_debug,
	 output AD_nRD_debug
    );



	reg AD_nRD_reg = 1;
	reg AD_nCONVST_reg = 1;

	assign AD_nCS = 1'b0; //chip select should always be on
	assign AD_nCONVST = AD_nCONVST_reg;
	assign AD_nRD = AD_nRD_reg;
	
	assign AD_nCS_debug =  AD_nCS;
	assign AD_nCONVST_debug = AD_nCONVST;
	assign AD_nRD_debug = AD_nRD;


	//internal registers and wires
	reg [15:0] block_ram [31:0];
	reg [15:0] block_ram_out;
	reg [4:0] wr_addr_MSB = {5{1'b0}}; //512 is 9 bits
	reg [4:0] wr_addr_LSB = {5{1'b0}};
	reg [4:0] wr_timing_addr_MSB = {5{1'b0}};
	reg [4:0] wr_timing_addr_LSB = {5{1'b0}};
	reg write = 1'b0;
	reg sample = 1'b0; // should I be adding up the power from the ADC? 1=yes, 0=no
	reg [1:0] wrapCount = {4{1'b0}}; //how many times it has wrapped around (block ram is 32 wide (2**5), 3 bits for channels (2**3), so only 2 bits for storage)
	reg [15:0] sampleCount = {16{1'b0}}; //count how many samples I am taking
	reg [23:0] RF_PowAdder = {24{1'b0}}; //for adding up the power read up (top 12 bits are stored, like an average)
	assign adder_debug = RF_PowAdder;
	
	reg [2:0] MUXSel_reg = {3{1'b0}};
	assign MUXSel = MUXSel_reg;

	reg [3:0] sample_timer = 0;
	wire [4:0] sample_timer_wrap = sample_timer + 1;
	
//	reg [17:0] Big_Counter = 0;
//	wire [18:0] Big_Wrap = Big_Counter + 1;
	//flags for overall state machine
	reg sample_flag = 0;         //start sampling machine
	reg sampleHold_flag = 0;     //lets everything else know sample state machine is running (7 clocks, ~212ns)
	
	reg changeSig_flag = 0;      //change input
	assign signals_debug[1] = changeSig_flag;
	reg changeSigHold_flag = 0;  //the hold after changing input for everything to settle
	assign signals_debug[0] = changeSigHold_flag;

	reg [1:0] rSector_pointer = 0;                  //flag to tell which of the four (32/8) banks is being read from
 	reg [1:0] wSector_pointer = 0;                  //this is so the writes are full sectors and the reads are time ordered from ch0 to ch7 at least
	reg [1:0] wTimingSector_pointer = 0;            //for doing the timing readout
	
	
	reg [2:0] sample_state = 0;  //the sampling state machine
	assign signals_debug[5:4] =  sample_state;
	reg [2:0] write_state = 0;   //the block ram writing state machine
	assign signals_debug[3:2] =  write_state;	

	wire [3:0] channelWrap = MUXSel_reg + 1; //will will be 'b1000 when it is about to wrap

	reg [5:0] changeSigHold_counter = 0;  //stores when switch occurrs so hold flag can be dropped 2uS after (64 clock cycles)
	wire [6:0] changeSigHold_counter_wrap = changeSigHold_counter + 1; //when this goes high, the mux is switched and settled

	reg [15:0] RFPWR_reg = {16{1'b0}};
	

	reg rSector_increment = 0;

	always @ (posedge CLK) begin	//update the readout register with the read clock
		if (RAD[2:0] == 3'b000 && rSector_increment == 0) begin
			rSector_increment <= 1;
			rSector_pointer <= rSector_pointer + 1;
		end
		if (RAD[2:0] == 3'b001) begin
			rSector_increment <= 0;
		end
		RFPWR_reg <= block_ram[RAD];
	end

	assign RFPWR = RFPWR_reg;
	

	always @ (posedge CLK) begin //syncronous 33MHz clock! (30ns)

		//increment the giant counter
//		Big_Counter <= Big_Counter + 1; //LM - to see if it satisfies timing
		sample_timer <= sample_timer + 1;
			
		//decide to start sampling, unless you have already sampled up to the averaging limit (2**14 in this case)
		if (sample_timer_wrap[4] == 1) sample_flag <= 1;   // (1uS) 1MHz sampling speed flag, starts sampling
				
		
		
		
		
		
		
		//Switch MUX when the counter fills up
		//if (Big_Counter == 32'd200000) begin // (2mS) 500Hz mux switching speed (if you want it to sample for a time not a count)
		if (sampleCount == 4096 && changeSigHold_flag == 0) begin
			changeSig_flag <= 1;  //stays high until switch is completed (in case flag raises during sampling)
		end

		//count up after MUX switch so it can settle
		if (changeSigHold_flag == 1) begin
			changeSigHold_counter <= changeSigHold_counter + 1;
		end
		
		//turn off 'hold' after mux switch settles (~2uS)
		if (changeSigHold_counter_wrap[6] == 1) begin 
			changeSigHold_flag <= 0;
			changeSigHold_counter <= 0;
		end

		
		
		
	   //change the Analog Signal Select
	   //do it when you've got enough samples to do the average
		//don't change while sampling is happening
		if (changeSig_flag == 1 && sampleHold_flag == 0) begin
			wrapCount <= wrapCount + channelWrap[3]; //incriment debug wrap if needed (channelWrap[3] is a wire that will be 1 when it is about to wrap)
			changeSig_flag <= 0;                     //lower flag cuz you just changed successfully
			sample_timer <= 0;                       //reset sample timer, otherwise you'll get a delay the size of the counter
			changeSigHold_flag <= 1;                 //raise the hold flag so the mux can settle
			write_state <= write_state + 1;          //start the write state machine
		end
		
		
		
		
		
		
		//update the register to write the data to, dependant on where the RAD is and what the mux channel is
		// 32 (2**5) blocks to write into, separate into 4 sectors
		wSector_pointer <= "00"; // always writes rf power in the same bank
		if (write_state == 2'd1) begin
			wr_addr_MSB[2:0] <= MUXSel_reg;
			wr_addr_MSB[4:3] <= "00";
			
			wr_addr_LSB[2:0] <= MUXSel_reg;
			wr_addr_LSB[4:3] <= "01";
			
			wr_timing_addr_LSB[0] <= "0";
			wr_timing_addr_LSB[4] <= "1";
			wr_timing_addr_LSB[3] <= MUXSel_reg[2];
			wr_timing_addr_LSB[2:1] <= MUXSel_reg[1:0];
			
			wr_timing_addr_MSB[0] <= "1";
			wr_timing_addr_MSB[4] <= "1";
			wr_timing_addr_MSB[3] <= MUXSel_reg[2];
			wr_timing_addr_MSB[2:1] <= MUXSel_reg[1:0];
			
			write_state <= write_state + 1;
		end
		
		//need to split this into two clock cycles since calculating the address takes one (because of the if statement)
		if (write_state == 2'd2) begin
			MUXSel_reg <= MUXSel_reg + 1;            // actually change the analog signal select now that you saved it in the wr_addr's
			write_state <= write_state + 1;
		end
		
		
		//write out the highest bits of the adder (an average essentially) to the block ram
		if (write_state == 2'd3) begin
			block_ram[wr_addr_MSB] <= RF_PowAdder[23:8]; //average done here too, lose bottom 14 bits (rounding is wrong but oh well)
			block_ram[wr_addr_LSB] <= RF_PowAdder[7:0]; //also store the least significant bits!
			RF_PowAdder <= {24{1'b0}}; //null out adder
			sampleCount <= {16{1'b0}}; //null out counter
			
//			block_ram[wr_timing_addr_LSB] <= Big_Counter[15:0];
//			block_ram[wr_timing_addr_MSB] <= Big_Counter[17:16];
//			Big_Counter <= {18{1'b0}};
			
			write_state <= 0; //turn off write flag after you've written
		end
		
		
		
		
		
		//sampling state starter, the most important state starter
		//requires: no sampling already, ADC not busy, state change not recent or in queue
		if (sample_flag == 1'b1 && sample_state == 3'b000 && AD_nBusy == 1'b1 && changeSig_flag == 0 && changeSigHold_flag == 0) begin
			sample_flag <= 0;
			sample_state <= 3'b001;
			sampleHold_flag <= 1;
			sampleCount <= sampleCount + 1; //if you get this far everything is locked out so the samplecount should be updated
		end
		
		//sampling state machine
		case (sample_state)  //start by putting convert flag up
			3'b001: begin
				AD_nCONVST_reg <= 1'b0;
				sample_state <= sample_state + 1;
				end
			3'b010: sample_state <= sample_state + 1; //hold convert low for 2 cycles for timing
			3'b011: begin
				sample_state <= sample_state + 1;
				end
			3'b100: begin
				if (AD_nBusy == 1) begin
					AD_nCONVST_reg <= 1'b1;
					AD_nRD_reg <= 0;
					sample_state <= sample_state + 1;
					end
				end
			3'b101: sample_state <= sample_state + 1; //hold read low for 2 cycles for timing
			3'b110: begin
				RF_PowAdder <= RF_PowAdder + AData;
				AD_nRD_reg <= 1;
				sample_state <= 3'b000; //done with sampling
				sampleHold_flag <= 0;
				end

			endcase //end of case
			
			
		end //end of syncronous 33MHz clock
		
	
	

endmodule
