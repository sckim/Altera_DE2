// This code implements a pseudo dual-port memory by using a multiplexer
// for the write and read address, and using external SRAM.
// 
// inputs: CLOCK_50 is the clock, KEY0 is the reset, SW7-SW0 provides data to 
// 	write into memory,
// SW15-SW11 provides the memory address, SW17 is the memory Write input.
// outputs: 7-seg displays HEX7, HEX6 display the memory addres, HEX5, HEX4
// displays the data input to the memory, and HEX1, HEX0 show the contents read
// from the memory. LEDG0 shows the status of Write. 
// SRAM_ADDR provides the external SRAM chip address, SRAM_DQ is the data
// input/output for the RAM, and the SRAM control signals are SRAM_WE_N, 
// SRAM_CE_N, SRAM_OE_N, SRAM_UB_N, and SRAM_LB_N.
module part7 (CLOCK_50, KEY, SW, HEX7, HEX6, HEX5, HEX4, 
	HEX3, HEX2, HEX1, HEX0, LEDG,
	SRAM_ADDR, SRAM_DQ, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N, SRAM_UB_N, SRAM_LB_N);
	input CLOCK_50;
	input [0:0] KEY;
	input [17:0] SW;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output [0:0] LEDG;
	output [17:0] SRAM_ADDR;
	inout [15:0] SRAM_DQ;
	output SRAM_WE_N, SRAM_CE_N, SRAM_OE_N, SRAM_UB_N, SRAM_LB_N;

	wire Resetn, Clock, Write_n_sync, CE, CE_1, CE_2;
	wire [4:0] Write_address, Write_address_sync;
	wire [7:0] DataIn, DataIn_sync, DataOut;

	assign Resetn = KEY[0];
	assign Clock = CLOCK_50;

	// synchronize all asynchronous inputs to the clock
	regne #(.n(1)) R1 (!SW[17], Clock, Resetn, 1'b1, Write_n_sync);
	regne #(.n(1)) R2 (Write_n_sync, Clock, Resetn, 1'b1, SRAM_WE_N);
	regne #(.n(5)) R3 (SW[15:11], Clock, Resetn, 1'b1, Write_address_sync);
	regne #(.n(5)) R4 (Write_address_sync, Clock, Resetn, 1'b1, Write_address);
	regne #(.n(8)) R5 (SW[7:0], Clock, Resetn, 1'b1, DataIn_sync);
	regne #(.n(8)) R6 (DataIn_sync, Clock, Resetn, 1'b1, DataIn);

	// one second cycle counter
	parameter m = 25;
	reg [m-1:0] slow_count;
	reg [4:0] Read_address; // cycles from addresses 0 to 31 at one second per address

	// Create a 1Hz 5-bit address counter
	// A large counter to produce a 1 second (approx) enable
	always @(posedge Clock)
		slow_count <= slow_count + 1'b1;
	// the read address counter
	always @ (posedge Clock)
		if (Resetn == 0)
			Read_address <= 5'b0;
		else if (slow_count == 0)
			Read_address <= Read_address + 1'b1;

	assign SRAM_ADDR = (SRAM_WE_N == 0) ? {13'b0,Write_address} : {13'b0,Read_address};

	assign SRAM_DQ = (SRAM_WE_N == 1'b0) ? {8'b0,DataIn} : 16'bz;

	// hold CE_N to 1 for two clock cycles after power-up, to avoid an accidental write
	regne #(.n(1)) R7 (1'b1, Clock, Resetn, 1'b1, CE_1);
	regne #(.n(1)) R8 (CE_1, Clock, Resetn, 1'b1, CE_2);
	regne #(.n(1)) R9 (CE_2, Clock, Resetn, 1'b1, CE);
	assign SRAM_CE_N = ~CE;

	assign SRAM_OE_N = 1'b0;
	assign SRAM_UB_N = 1'b0;
	assign SRAM_LB_N = 1'b0;

	assign DataOut = SRAM_DQ[7:0];

	// display the data input, data output, and address on the 7-segs
	hex7seg digit0 (DataOut[3:0], HEX0);
	hex7seg digit1 (DataOut[7:4], HEX1);
	hex7seg digit2 (Read_address[3:0], HEX2);
	hex7seg digit3 ({3'b0,Read_address[4]}, HEX3);
	hex7seg digit4 (DataIn[3:0], HEX4);
	hex7seg digit5 (DataIn[7:4], HEX5);
	hex7seg digit6 (Write_address[3:0], HEX6);
	hex7seg digit7 (({3'b0,Write_address[4]}), HEX7);

	assign LEDG[0] = SRAM_WE_N;
endmodule

module regne (R, Clock, Resetn, E, Q);
	parameter n = 7;
	input [n-1:0] R;
	input Clock, Resetn, E;
	output [n-1:0] Q;
	reg [n-1:0] Q;	
	
	always @(posedge Clock)
		if (Resetn == 0)
			Q <= {n{1'b0}};
		else if (E)
			Q <= R;
endmodule

module hex7seg (hex, display);
	input [3:0] hex;
	output [0:6] display;

	reg [0:6] display;

	/*
	 *       0  
	 *      ---  
	 *     |   |
	 *    5|   |1
	 *     | 6 |
	 *      ---  
	 *     |   |
	 *    4|   |2
	 *     |   |
	 *      ---  
	 *       3  
	 */
	always @ (hex)
		case (hex)
			4'h0: display = 7'b0000001;
			4'h1: display = 7'b1001111;
			4'h2: display = 7'b0010010;
			4'h3: display = 7'b0000110;
			4'h4: display = 7'b1001100;
			4'h5: display = 7'b0100100;
			4'h6: display = 7'b1100000;
			4'h7: display = 7'b0001111;
			4'h8: display = 7'b0000000;
			4'h9: display = 7'b0001100;
			4'hA: display = 7'b0001000;
			4'hb: display = 7'b1100000;
			4'hC: display = 7'b0110001;
			4'hd: display = 7'b1000010;
			4'hE: display = 7'b0110000;
			4'hF: display = 7'b0111000;
		endcase
endmodule
