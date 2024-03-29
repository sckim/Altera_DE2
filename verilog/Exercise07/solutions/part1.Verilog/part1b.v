// a sequence detector FSM using one-hot encoding that is modifies so that
// the reset state uses code 000...0.
// SW0 is the active low synchronous reset, SW1 is the w input, and KEY0 is the clock.
// The z output appears on LEDG0, and the state FFs appear on LEDR8..0
module part1 (SW, KEY, LEDG, LEDR);
	input [1:0] SW;
	input [0:0] KEY;
	output [0:0] LEDG;
	output [8:0] LEDR;

	wire Clock, Resetn, w, z;
	wire [8:0] y_Q, Y_D;

	assign Clock = KEY[0];
	assign Resetn = SW[0];
	assign w = SW[1];

	assign Y_D[0] = 1'b1;
	flipflop (Y_D[0], Clock, Resetn, y_Q[0]);
	assign Y_D[1] = (~y_Q[0] | y_Q[5] | y_Q[6] | y_Q[7] | y_Q[8]) & ~w;
	flipflop (Y_D[1], Clock, Resetn, y_Q[1]);
	assign Y_D[2] = y_Q[1] & ~w;
	flipflop (Y_D[2], Clock, Resetn, y_Q[2]);
	assign Y_D[3] = y_Q[2] & ~w;
	flipflop (Y_D[3], Clock, Resetn, y_Q[3]);
	assign Y_D[4] = (y_Q[3] | y_Q[4]) & ~w;
	flipflop (Y_D[4], Clock, Resetn, y_Q[4]);

	assign Y_D[5] = (~y_Q[0] | y_Q[1] | y_Q[2] | y_Q[3] | y_Q[4]) & w;
	flipflop (Y_D[5], Clock, Resetn, y_Q[5]);
	assign Y_D[6] = y_Q[5] & w;
	flipflop (Y_D[6], Clock, Resetn, y_Q[6]);
	assign Y_D[7] = y_Q[6] & w;
	flipflop (Y_D[7], Clock, Resetn, y_Q[7]);
	assign Y_D[8] = (y_Q[7] | y_Q[8]) & w;
	flipflop (Y_D[8], Clock, Resetn, y_Q[8]);

	assign z = y_Q[4] | y_Q[8];
	assign LEDR[8:0] = y_Q[8:0];
	assign LEDG[0] = z;
endmodule

module flipflop (D, Clock, Resetn, Q);
	input D, Clock, Resetn;
	output reg Q;
	
	always @(posedge Clock)
		if (Resetn  == 1'b0)	// synchronous clear
			Q <= 1'b0;
		else
			Q <= D;
endmodule
