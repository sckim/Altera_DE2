//
// inputs:
// KEY0: manual clock
// SW0: active low reset
// SW1: enable signal for the counter
//
// outputs:
//	HEX0: hex segment display
module part1 (SW, KEY, HEX0);
	input [1:0] SW ;
	input [0:0] KEY ;
	output [0:6] HEX0;
	
	wire Clock = KEY[0];
	wire Resetn = SW[0];
	
	// 4-bit counter based on T-flip flops
	wire [3:0] Count;
	wire [3:0] Enable;

	assign Enable[0] = SW[1];
	ToggleFF (Enable[0], Clock, Resetn, Count[0]);
	assign Enable[1] = Count[0] & Enable[0];
	ToggleFF (Enable[1], Clock, Resetn, Count[1]);
	assign Enable[2] = Count[1] & Enable[1];
	ToggleFF (Enable[2], Clock, Resetn, Count[2]);
	assign Enable[3] = Count[2] & Enable[2];
	ToggleFF (Enable[3], Clock, Resetn, Count[3]);
	
	// drive the displays
	hex7seg digit0 (Count[3:0], HEX0);
endmodule

module ToggleFF(T, Clock, Resetn, Q);
	input T, Clock, Resetn;
	output reg Q;
	
	always @(posedge Clock)
		if (Resetn  == 1'b0)	// synchronous clear
			Q <= 1'b0;
		else if(T)
			Q <= ~Q;
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
