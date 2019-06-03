// bcd-to-decimal converter
module part2 (SW, HEX1, HEX0);
	input [3:0] SW;
	output [0:6] HEX1, HEX0;

	wire[3:0] V, M;
	wire[2:0] B;
	wire z;
	
	assign V = SW;

	// circuit A
	assign z = (V[3] & V[2]) | (V[3] & V[1]);

	// Circuit B
	assign B[2] = V[2] & V[1];
	assign B[1] = V[2] & ~V[1];
	assign B[0] = (V[1] & V[0]) | (V[2] & V[0]);

	// multiplexers
	assign M[3] = ~z & V[3];
	assign M[2] = (~z & V[2]) | (z & B[2]);
	assign M[1] = (~z & V[1]) | (z & B[1]);
	assign M[0] = (~z & V[0]) | (z & B[0]);
	
	// Circuit D
	bcd7seg Circuit_D (M, HEX0);

	// Circuit C
	assign HEX1 = {1'b1, ~z, ~z, 4'b1111};	// display a blank or the digit 1
	
endmodule
			
module bcd7seg (B, H);
	input [3:0] B;
	output [0:6] H;

	wire [0:6] H;

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
	// B  H
	// ----------
	// 0  0000001;
	// 1  1001111;
	// 2  0010010;
	// 3  0000110;
	// 4  1001100;
	// 5  0100100;
	// 6  1100000;
	// 7  0001111;
	// 8  0000000;
	// 9  0001100;
	assign H[0] = (B[2] & ~B[0]) | (~B[3] & ~B[2] & ~B[1] & B[0]);
	assign H[1] = (B[2] & ~B[1] & B[0]) | (B[2] & B[1] & ~B[0]);
	assign H[2] = (~B[2] & B[1] & ~B[0]);
	assign H[3] = (~B[2] & ~B[1] & B[0]) | (B[2] & ~B[1] & ~B[0]) | 
		(B[2] & B[1] & B[0]);
	assign H[4] = (~B[1] & B[0]) | (~B[3] & B[0]) | (~B[3] & B[2] & ~B[1]);
	assign H[5] = (B[1] & B[0]) | (~B[2] & B[1]) | (~B[3] & ~B[2] & B[0]);
	assign H[6] = (B[2] & B[1] & B[0]) | (~B[3] & ~B[2] & ~B[1]);
endmodule
