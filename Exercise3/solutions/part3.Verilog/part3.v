// SW[0] is the flip-flop's D input, SW[1] is the edge-sensitive Clock, LEDR[0] is Q
module part3 (input [1:0] SW, output [0:0] LEDR);

	wire Qm, Qs;
	// module D_latch (input Clk, D, output Q);
	D_latch U1 (~SW[1], SW[0], Qm);
	D_latch U2 (SW[1], Qm, Qs);

	assign LEDR[0] = Qs;

endmodule

// A D latch described the hard way
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
	
