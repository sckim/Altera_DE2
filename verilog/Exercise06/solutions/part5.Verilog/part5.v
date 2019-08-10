// Implements an unsigned multiplier P = A x B.
// inputs:	SW11-8 = A, SW3-0 = B
// outputs:	HEX7-6 shows input A, HEX5-4 shows input B
// 			HEX3-0 shows the product P
module part5 (SW, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input [15:0] SW;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	wire [3:0] A, B;
	wire [7:0] P;
	wire [3:1] C_b1; 	// carries for row that ANDs with B1
	wire [5:2] PP1;	// partial products from row that ANDs with B1
	wire [3:1] C_b2;	// carries for row that ANDs with B2
	wire [6:3] PP2; 	// partial products from row that ANDs with B2
	wire [3:1] C_b3;	// carries for row that ANDs with B3

	assign A = SW[11:8];
	assign B = SW[3:0];
	assign P[0] = A[0] & B[0];

	// module fa (a, b, ci, s, co);
	fa b1_a0 (A[1] & B[0], A[0] & B[1], 1'b0,    P[1],   C_b1[1]);
	fa b1_a1 (A[2] & B[0], A[1] & B[1], C_b1[1], PP1[2], C_b1[2]);
	fa b1_a2 (A[3] & B[0], A[2] & B[1], C_b1[2], PP1[3], C_b1[3]);
	fa b1_a3 (1'b0,        A[3] & B[1], C_b1[3], PP1[4], PP1[5]);

	// module fa (a, b, ci, s, co);
	fa b2_a0 (PP1[2], A[0] & B[2], 1'b0,    P[2],   C_b2[1]);
	fa b2_a1 (PP1[3], A[1] & B[2], C_b2[1], PP2[3], C_b2[2]);
	fa b2_a2 (PP1[4], A[2] & B[2], C_b2[2], PP2[4], C_b2[3]);
	fa b2_a3 (PP1[5], A[3] & B[2], C_b2[3], PP2[5], PP2[6]);

	// module fa (a, b, ci, s, co);
	fa b3_a0 (PP2[3], A[0] & B[3], 1'b0,    P[3], C_b3[1]);
	fa b3_a1 (PP2[4], A[1] & B[3], C_b3[1], P[4], C_b3[2]);
	fa b3_a2 (PP2[5], A[2] & B[3], C_b3[2], P[5], C_b3[3]);
	fa b3_a3 (PP2[6], A[3] & B[3], C_b3[3], P[6], P[7]);

	// drive the display through a 7-seg decoder
	hex7seg digit_7 (4'h0, HEX7);
	hex7seg digit_6 (A, HEX6);

	hex7seg digit_5 (4'h0, HEX5);
	hex7seg digit_4 (B, HEX4);

	hex7seg digit_3 (4'h0, HEX3);
	hex7seg digit_2 (4'h0, HEX2);
	hex7seg digit_1 (P[7:4], HEX1);
	hex7seg digit_0 (P[3:0], HEX0);
	
endmodule
			
module fa (a, b, ci, s, co);
	input a, b, ci;
	output s, co;

	wire a_xor_b;

	assign a_xor_b = a ^ b;
	assign s = a_xor_b ^ ci;
	assign co = (~a_xor_b & b) | (a_xor_b & ci);
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
