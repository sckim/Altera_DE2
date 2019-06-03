// Signed 8-bit ripple-carry adder S = A + B, with overflow detection
// Registers are included for all inputs and outputs.
// inputs:	SW15-8 = A, SW7-0 = B
// 			KEY0 = active-low asynchronous reset
// 			KEY1 = manual clock
// outputs:	LEDR7-0 shows S in binary form
// 			HEX7-6 shows input A, HEX5-4 shows input B
// 			HEX3-0 shows the output sum
// 			LEDG8 shows overflow
module part1 (KEY, SW, LEDR, LEDG, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input [1:0] KEY;
	input [15:0] SW;
	output [7:0] LEDR;
	output [8:8] LEDG;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	
	wire [7:0] A, B, S, S_reg;
	wire [8:1] C;		// carries
	wire Clock, Resetn, Overflow, Overflow_reg;
	
	assign Resetn = KEY[0];
	assign Clock = KEY[1];
	// instantiate module regn (R, Clock, Resetn, Q);
	regn U_A (SW[15:8], Clock, Resetn, A);
	regn U_B (SW[7:0], Clock, Resetn, B);

	fa bit0 (A[0], B[0], 1'b0, S[0], C[1]);
	fa bit1 (A[1], B[1], C[1], S[1], C[2]);
	fa bit2 (A[2], B[2], C[2], S[2], C[3]);
	fa bit3 (A[3], B[3], C[3], S[3], C[4]);
	fa bit4 (A[4], B[4], C[4], S[4], C[5]);
	fa bit5 (A[5], B[5], C[5], S[5], C[6]);
	fa bit6 (A[6], B[6], C[6], S[6], C[7]);
	fa bit7 (A[7], B[7], C[7], S[7], C[8]);
	// Display the adder outputs
	assign LEDR = S;

	// instantiate module regn (R, Clock, Resetn, Q);
	regn U_S (S, Clock, Resetn, S_reg);

	// check for Overflow
	assign Overflow = C[8] ^ C[7];
	regn #(.n(1)) U_Overflow (Overflow, Clock, Resetn, Overflow_reg);
	assign LEDG = Overflow_reg;

	// drive the displays through 7-seg decoders
	hex7seg digit_7 (A[7:4], HEX7);
	hex7seg digit_6 (A[3:0], HEX6);

	hex7seg digit_5 (B[7:4], HEX5);
	hex7seg digit_4 (B[3:0], HEX4);

	assign HEX3 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	hex7seg digit_1 (S_reg[7:4], HEX1);
	hex7seg digit_0 (S_reg[3:0], HEX0);
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
