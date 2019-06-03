// A gated D latch desribed the hard way
module D_latch (Clk, D, Q);
	input Clk, D;
	output Q;

	wire S, R, S_g, R_g, Qa, Qb /* synthesis keep */ ;

	assign S = D;
	assign R = ~D;
	assign S_g = ~(S & Clk);
	assign R_g = ~(R & Clk);
	assign Qa = ~(S_g & Qb);
	assign Qb = ~(R_g & Qa);

	assign Q = Qa;

endmodule
