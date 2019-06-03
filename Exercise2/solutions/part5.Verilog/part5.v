// implements a two-digit bcd adder S2 S1 S0 = A1 A0 + B1 B0
// inputs: SW15-8 = A1 A0
//         SW7-0 = B1 B0
// outputs: A1 A0 is displayed on HEX7 HEX6
// 			B1 B0 is displayed on HEX5 HEX4
// 			S2 S1 S0 is displayed on HEX2 HEX1 HEX0
module part5 (SW, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input [15:0] SW;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	wire[3:0] A1, A0, B1, B0;
	assign A1 = SW[15:12];
	assign A0 = SW[11:8];
	assign B1 = SW[7:4];
	assign B0 = SW[3:0];
	
	wire [3:0] S0, S1;
	wire C1, C2, S2;

	// module part4 (A, B, Cin, S1, S0);
	part4 BCD_0 (A0, B0, 1'b0, C1, S0);
	part4 BCD_1 (A1, B1, C1, C2, S1);
	assign S2 = C2;
	
	// drive the displays through 7-seg decoders
	bcd7seg digit7 (A1, HEX7);
	bcd7seg digit6 (A0, HEX6);
	bcd7seg digit5 (B1, HEX5);
	bcd7seg digit4 (B0, HEX4);
	bcd7seg digit2 ({3'b000, S2}, HEX2);
	bcd7seg digit1 (S1, HEX1);
	bcd7seg digit0 (S0, HEX0);

	assign HEX3 = 7'b1111111;	// turn off HEX3
	
endmodule
			
// one digit BCD adder S1 S0 = A + B + Cin
module part4 (A, B, Cin, S1, S0);
	input [3:0] A, B;
	input Cin;
	output S1;					// S1 is really just a carry out
	output [3:0] S0;			// S0 is the least signisum output of the adder

	wire [4:1] C;				// internal carries
	wire [3:0] S0_M;			// used because S0 has to be modified for sums 16, 17, 18, 19
	wire S1_M;					// used because S1 has to be modified for sums 16, 17, 18, 19
	wire [3:0] S;				// S is the sum produced by the adder
	
	fa bit0 (A[0], B[0], Cin, S[0], C[1]);
	fa bit1 (A[1], B[1], C[1], S[1], C[2]);
	fa bit2 (A[2], B[2], C[2], S[2], C[3]);
	fa bit3 (A[3], B[3], C[3], S[3], C[4]);
	
	// convert the sum to BCD
	bcd_decimal BCD_S (S, S1_M, S0_M); 
	// S is really a 5-bit # with the carry-out, but bcd_decimal handles only 
	// the lower four bits (sums 00-15).  To account for sums 16, 17, 18, 19 S0 
	// has to be modified in the cases that carry-out = 1. Use multiplexers:
	assign S0[3] = (~C[4] & S0_M[3]) | (C[4] & S0_M[1]); 
	assign S0[2] = (~C[4] & S0_M[2]) | (C[4] & ~S0_M[1]); 
	assign S0[1] = (~C[4] & S0_M[1]) | (C[4] & ~S0_M[1]); 
	assign S0[0] = S0_M[0];
	// S is really a 5-bit #, but bcd_decimal works for only the lower four bits
	// (sums 00-15). To account for sums 16, 17, 18, 19 S1 should be a 1 when 
	// the carry-out is a 1
	assign S1 = S1_M | C[4];
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
	wire z;
	
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
