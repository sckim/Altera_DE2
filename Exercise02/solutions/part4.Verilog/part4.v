// one-digit BCD adder S1 S0 = A + B + Cin
// inputs: SW7-4 = A
//         SW3-0 = B
// outputs: A is displayed on HEX6
// 			B is displayed on HEX4
// 			S1 S0 is displayed on HEX1 HEX0
module part4 (SW, LEDR, LEDG, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input [8:0] SW;
	output [8:0] LEDR;
	output [8:0] LEDG;
	
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	wire [3:0] A, B, S;			// S is the sum output of the adder
	wire Cin;						// carry in
	wire [4:1] C;					// internal carries
	wire [3:0] S0;
	wire [3:0] S0_M;				// modified S0 for sums 16, 17, 18, 19
	wire S1;
	
	assign A = SW[7:4];
	assign B = SW[3:0];
	assign Cin = SW[8];
	assign LEDR = SW;

	fa bit0 (A[0], B[0], Cin, S[0], C[1]);
	fa bit1 (A[1], B[1], C[1], S[1], C[2]);
	fa bit2 (A[2], B[2], C[2], S[2], C[3]);
	fa bit3 (A[3], B[3], C[3], S[3], C[4]);
	assign LEDG[4:0] = {C[4], S};
	
	// Display the inputs
	bcd7seg H_6 (A, HEX6);
	assign HEX7 = {7'b1111111};	// display blank

	bcd7seg H_4 (B, HEX4);
	assign HEX5 = {7'b1111111};	// display blank
	
	// Detect illegal inputs, display on LEDG[8]
	assign LEDG[8] = (A[3] & A[2]) | (A[3] & A[1]) | 
		(B[3] & B[2]) | (B[3] & B[1]);
	assign LEDG[7:5] = 3'b000;

	// Display the sum
	// module bcd_decimal (V, z, M);
	bcd_decimal BCD_S (S, S1, S0); 
	// S is really a 5-bit # with the carry-out, but bcd_decimal handles only 
	// the lower four bit (sums 00-15).  To account for sums 16, 17, 18, 19 S0 
	// has to be modified in the cases that carry-out = 1. Use multiplexers:
	assign S0_M[3] = (~C[4] & S0[3]) | (C[4] & S0[1]); 
	assign S0_M[2] = (~C[4] & S0[2]) | (C[4] & ~S0[1]); 
	assign S0_M[1] = (~C[4] & S0[1]) | (C[4] & ~S0[1]); 
	assign S0_M[0] = S0[0];
	bcd7seg H_0 (S0_M, HEX0);
	// S is really a 5-bit #, but bcd_decimal works for only the lower four bits
	// (sums 00-15). To account for sums 16, 17, 18, 19 S1 should be a 1 when 
	// the carry-out is a 1
	assign HEX1 = {1'b1, ~(S1 | C[4]), ~(S1 | C[4]), 4'b1111};	// display blank or 1
	assign HEX2 = {7'b1111111};	// display blank 
	assign HEX3 = {7'b1111111};	// display blank

endmodule
			
module fa (a, b, ci, s, co);
	input a, b, ci;
	output s, co;

	wire a_xor_b;

	assign a_xor_b = a ^ b;
	assign s = a_xor_b ^ ci;
	assign co = (~a_xor_b & b) | (a_xor_b & ci);
endmodule

// bcd-to-decimal converter
module bcd_decimal (V, z, M);
	input [3:0] V;
	output z;
	output [3:0] M;

	wire[2:0] B;
	
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
