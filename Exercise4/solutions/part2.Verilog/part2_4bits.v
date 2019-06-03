//
// inputs:
// KEY0: manual clock
// SW0: active low reset
// SW1: enable signal for the counter
//
// outputs:
//	HEX0 - HEX3: hex segment displays
module part2 (SW, KEY, HEX0);
	input [1:0] SW ;
	input [0:0] KEY ;
	output [0:6] HEX0;
	
	wire Clock = KEY[0];
	wire Resetn = SW[0];
	wire Enable = SW[1];
	
	// 4-bit counter 
	reg [3:0] Count;
	always @(posedge Clock)
		if (!Resetn)
			Count <= 0;
		else if (Enable)
			Count <= Count + 1'b1;
	
	// drive the displays
	hex7seg digit0 (Count[3:0], HEX0);
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
