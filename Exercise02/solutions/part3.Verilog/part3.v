// 4-bit ripple-carry adder
module part3 (SW, LEDR, LEDG);
	input [7:0] SW;
	output [7:0] LEDR;
	output [4:0] LEDG;
	
	wire [3:0] A, B, S;
	wire [4:1] C;		// carries
	
	assign A = SW[7:4];
	assign B = SW[3:0];

	fa bit0 (A[0], B[0], 1'b0, S[0], C[1]);
	fa bit1 (A[1], B[1], C[1], S[1], C[2]);
	fa bit2 (A[2], B[2], C[2], S[2], C[3]);
	fa bit3 (A[3], B[3], C[3], S[3], C[4]);
	
	// Display the inputs
	assign LEDR = SW;
	assign LEDG = {C[4], S};

endmodule
			
module fa (a, b, ci, s, co);
	input a, b, ci;
	output s, co;

	wire a_xor_b;

	assign a_xor_b = a ^ b;
	assign s = a_xor_b ^ ci;
	assign co = (~a_xor_b & b) | (a_xor_b & ci);
endmodule
