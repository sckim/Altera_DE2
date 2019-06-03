// SW[0] is the latch's D input, SW[1] is the level-sensitive Clk, LEDR[0] is Q
module top (input [1:0] SW, output [0:0] LEDR);

	// module D_latch (input Clk, D, output Q);
	D_latch U1 (SW[1], SW[0], LEDR[0]);

endmodule

// A gated D latch described the hard way
module D_latch (input Clk, D, output Q);

	wire S, R, S_g, R_g, Qa, Qb /* synthesis keep */ ;

	assign S = D;
	assign R = ~D;
	assign S_g = ~(S & Clk);
	assign R_g = ~(R & Clk);
	assign Qa = ~(S_g & Qb);
	assign Qb = ~(R_g & Qa);

	assign Q = Qa;

endmodule
	
