// unsigned 8-bit multiplier P = A x B
// Registers are included for all inputs and outputs.
// inputs:	SW15-8 = A, SW7-0 = B
// 			KEY0 = active-low asynchronous reset
// 			KEY1 = manual clock
// outputs:	HEX7-6 shows input A, HEX5-4 shows input B
// 			HEX3-0 shows the output sum
module part6 (SW, KEY, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input [15:0] SW;
	input [1:0] KEY;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	wire Clock, Resetn;
	assign Resetn = KEY[0];
	assign Clock = KEY[1];
	wire [7:0] A, B;
	wire [15:0] P, P_reg;

	// instantiate module regn (R, Clock, Resetn, Q);
	regn U_A (SW[15:8], Clock, Resetn, A);
	regn U_B (SW[7:0], Clock, Resetn, B);

	wire [7:1] C_b1; 	// carries for row that ANDs with B1
	wire [9:2] PP1;	// partial products from row that ANDs with B1
	wire [7:1] C_b2;	// carries for row that ANDs with B2
	wire [10:3] PP2;	// partial products from row that ANDs with B2
	wire [7:1] C_b3;	// carries for row that ANDs with B3
	wire [11:4] PP3;	// partial products from row that ANDs with B3
	wire [7:1] C_b4;	// carries for row that ANDs with B4
	wire [12:5] PP4;	// partial products from row that ANDs with B4
	wire [7:1] C_b5;	// carries for row that ANDs with B5
	wire [13:6] PP5;	// partial products from row that ANDs with B5
	wire [7:1] C_b6;	// carries for row that ANDs with B6
	wire [14:7] PP6;	// partial products from row that ANDs with B6
	wire [7:1] C_b7;	// carries for row that ANDs with B7

	assign P[0] = A[0] & B[0];

	// module fa (a, b, ci, s, co); 
	fa b1_a0 (A[1] & B[0], A[0] & B[1], 1'b0,    P[1],   C_b1[1]);
	fa b1_a1 (A[2] & B[0], A[1] & B[1], C_b1[1], PP1[2], C_b1[2]);
	fa b1_a2 (A[3] & B[0], A[2] & B[1], C_b1[2], PP1[3], C_b1[3]);
	fa b1_a3 (A[4] & B[0], A[3] & B[1], C_b1[3], PP1[4], C_b1[4]);
	fa b1_a4 (A[5] & B[0], A[4] & B[1], C_b1[4], PP1[5], C_b1[5]);
	fa b1_a5 (A[6] & B[0], A[5] & B[1], C_b1[5], PP1[6], C_b1[6]);
	fa b1_a6 (A[7] & B[0], A[6] & B[1], C_b1[6], PP1[7], C_b1[7]);
	fa b1_a7 (1'b0,        A[7] & B[1], C_b1[7], PP1[8], PP1[9]);

	// module fa (a, b, ci, s, co);
	fa b2_a0 (PP1[2], A[0] & B[2], 1'b0,    P[2],   C_b2[1]);
	fa b2_a1 (PP1[3], A[1] & B[2], C_b2[1], PP2[3], C_b2[2]);
	fa b2_a2 (PP1[4], A[2] & B[2], C_b2[2], PP2[4], C_b2[3]);
	fa b2_a3 (PP1[5], A[3] & B[2], C_b2[3], PP2[5], C_b2[4]);
	fa b2_a4 (PP1[6], A[4] & B[2], C_b2[4], PP2[6], C_b2[5]);
	fa b2_a5 (PP1[7], A[5] & B[2], C_b2[5], PP2[7], C_b2[6]);
	fa b2_a6 (PP1[8], A[6] & B[2], C_b2[6], PP2[8], C_b2[7]);
	fa b2_a7 (PP1[9], A[7] & B[2], C_b2[7], PP2[9], PP2[10]);

	// module fa (a, b, ci, s, co);
	fa b3_a0 (PP2[3],  A[0] & B[3], 1'b0,    P[3],    C_b3[1]);
	fa b3_a1 (PP2[4],  A[1] & B[3], C_b3[1], PP3[4],  C_b3[2]);
	fa b3_a2 (PP2[5],  A[2] & B[3], C_b3[2], PP3[5],  C_b3[3]);
	fa b3_a3 (PP2[6],  A[3] & B[3], C_b3[3], PP3[6],  C_b3[4]);
	fa b3_a4 (PP2[7],  A[4] & B[3], C_b3[4], PP3[7],  C_b3[5]);
	fa b3_a5 (PP2[8],  A[5] & B[3], C_b3[5], PP3[8],  C_b3[6]);
	fa b3_a6 (PP2[9],  A[6] & B[3], C_b3[6], PP3[9],  C_b3[7]);
	fa b3_a7 (PP2[10], A[7] & B[3], C_b3[7], PP3[10], PP3[11]);

	// module fa (a, b, ci, s, co);
	fa b4_a0 (PP3[4],  A[0] & B[4], 1'b0,    P[4],    C_b4[1]);
	fa b4_a1 (PP3[5],  A[1] & B[4], C_b4[1], PP4[5],  C_b4[2]);
	fa b4_a2 (PP3[6],  A[2] & B[4], C_b4[2], PP4[6],  C_b4[3]);
	fa b4_a3 (PP3[7],  A[3] & B[4], C_b4[3], PP4[7],  C_b4[4]);
	fa b4_a4 (PP3[8],  A[4] & B[4], C_b4[4], PP4[8],  C_b4[5]);
	fa b4_a5 (PP3[9],  A[5] & B[4], C_b4[5], PP4[9],  C_b4[6]);
	fa b4_a6 (PP3[10], A[6] & B[4], C_b4[6], PP4[10], C_b4[7]);
	fa b4_a7 (PP3[11], A[7] & B[4], C_b4[7], PP4[11], PP4[12]);

	// module fa (a, b, ci, s, co);
	fa b5_a0 (PP4[5],  A[0] & B[5], 1'b0,    P[5],    C_b5[1]);
	fa b5_a1 (PP4[6],  A[1] & B[5], C_b5[1], PP5[6],  C_b5[2]);
	fa b5_a2 (PP4[7],  A[2] & B[5], C_b5[2], PP5[7],  C_b5[3]);
	fa b5_a3 (PP4[8],  A[3] & B[5], C_b5[3], PP5[8],  C_b5[4]);
	fa b5_a4 (PP4[9],  A[4] & B[5], C_b5[4], PP5[9],  C_b5[5]);
	fa b5_a5 (PP4[10], A[5] & B[5], C_b5[5], PP5[10], C_b5[6]);
	fa b5_a6 (PP4[11], A[6] & B[5], C_b5[6], PP5[11], C_b5[7]);
	fa b5_a7 (PP4[12], A[7] & B[5], C_b5[7], PP5[12], PP5[13]);

	// module fa (a, b, ci, s, co);
	fa b6_a0 (PP5[6],  A[0] & B[6], 1'b0,    P[6],    C_b6[1]);
	fa b6_a1 (PP5[7],  A[1] & B[6], C_b6[1], PP6[7],  C_b6[2]);
	fa b6_a2 (PP5[8],  A[2] & B[6], C_b6[2], PP6[8],  C_b6[3]);
	fa b6_a3 (PP5[9],  A[3] & B[6], C_b6[3], PP6[9],  C_b6[4]);
	fa b6_a4 (PP5[10], A[4] & B[6], C_b6[4], PP6[10], C_b6[5]);
	fa b6_a5 (PP5[11], A[5] & B[6], C_b6[5], PP6[11], C_b6[6]);
	fa b6_a6 (PP5[12], A[6] & B[6], C_b6[6], PP6[12], C_b6[7]);
	fa b6_a7 (PP5[13], A[7] & B[6], C_b6[7], PP6[13], PP6[14]);

	// module fa (a, b, ci, s, co);
	fa b7_a0 (PP6[7],  A[0] & B[7], 1'b0,    P[7],  C_b7[1]);
	fa b7_a1 (PP6[8],  A[1] & B[7], C_b7[1], P[8],  C_b7[2]);
	fa b7_a2 (PP6[9],  A[2] & B[7], C_b7[2], P[9],  C_b7[3]);
	fa b7_a3 (PP6[10], A[3] & B[7], C_b7[3], P[10], C_b7[4]);
	fa b7_a4 (PP6[11], A[4] & B[7], C_b7[4], P[11], C_b7[5]);
	fa b7_a5 (PP6[12], A[5] & B[7], C_b7[5], P[12], C_b7[6]);
	fa b7_a6 (PP6[13], A[6] & B[7], C_b7[6], P[13], C_b7[7]);
	fa b7_a7 (PP6[14], A[7] & B[7], C_b7[7], P[14], P[15]);

	// instantiate module regn (R, Clock, Resetn, Q);
	regn #(.n(16)) U_P (P, Clock, Resetn, P_reg);

	// drive the display through a 7-seg decoder
	hex7seg digit_7 (A[7:4], HEX7);
	hex7seg digit_6 (A[3:0], HEX6);

	hex7seg digit_5 (B[7:4], HEX5);
	hex7seg digit_4 (B[3:0], HEX4);

	hex7seg digit_3 (P_reg[15:12], HEX3);
	hex7seg digit_2 (P_reg[11:8], HEX2);
	hex7seg digit_1 (P_reg[7:4], HEX1);
	hex7seg digit_0 (P_reg[3:0], HEX0);
	
endmodule
			
module regn (R, Clock, Resetn, Q);
	parameter n = 8;
	input [n-1:0] R;
	input Clock, Resetn;
	output [n-1:0] Q;
	reg [n-1:0] Q;	
	
	always @(posedge Clock or negedge Resetn)
		if (Resetn == 0)
			Q <= {n{1'b0}};
		else
			Q <= R;
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
