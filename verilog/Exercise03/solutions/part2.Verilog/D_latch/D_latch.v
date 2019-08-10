// A gated D latch described the hard way
module D_latch (Clk, D, Q);
	input Clk, D;
	output Q;

	wire R, S_g, R_g, Qa, Qb /* synthesis keep */ ;

	assign R = ~D;
	assign S_g = ~(D & Clk);
	assign R_g = ~(R & Clk);
	assign Qa = ~(S_g & Qb);
	assign Qb = ~(R_g & Qa);

	assign Q = Qa;

endmodule
