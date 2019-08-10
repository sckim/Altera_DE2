// This code instantiates a 32 x 8 memory n the Cyclone II FPGA on the DE2 board.
//
// inputs: KEY0 is the clock, SW7-SW0 provides data to write into memory.
// SW15-SW11 provides the memory address, SW17 is the memory Write input.
// outputs: 7-seg displays HEX7, HEX6 display the memory addres, HEX5, HEX4
// displays the data input to the memory, and HEX1, HEX0 show the contents read
// from the memory. LEDG0 shows the status of Write.
module part2 (KEY, SW, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDG);
	input [0:0] KEY;
	input [17:0] SW;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output [0:0] LEDG;

	wire Clock, Write;
	wire [4:0] Address;
	wire [7:0] DataIn, DataOut;

	assign Clock = KEY[0];
	assign Write = SW[17];
	assign DataIn = SW[7:0];
	assign Address = SW[15:11];

	// instantiate LPM module
	// module ramlpm (address, clock, data, wren, q);
	ramlpm (Address, Clock, DataIn, Write, DataOut);

	// display the data input, data output, and address on the 7-segs
	// display the data input, data output, and address on the 7-segs
	hex7seg digit0 (DataOut[3:0], HEX0);
	hex7seg digit1 (DataOut[7:4], HEX1);
	assign HEX2 = 7'b1111111;  // blank
	assign HEX3 = 7'b1111111;  // blank
	hex7seg digit4 (DataIn[3:0], HEX4);
	hex7seg digit5 (DataIn[7:4], HEX5);
	hex7seg digit6 (Address[3:0], HEX6);
	hex7seg digit7 (({3'b0,Address[4]}), HEX7);

	assign LEDG[0] = Write;
endmodule

// the B input blanks the display when B = 1
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
