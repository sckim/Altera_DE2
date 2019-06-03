// Implements eight 2-to-1 multiplexers.
// inputs:	SW7-0 represent the 8-bit input X, and SW15-8 represent Y
// 			SW17 selects either X or Y to drive the output LEDs
// outputs: LEDR17-0 show the states of the switches
// 			LEDG7-0 shows the outputs of the multiplexers
module part2 (SW, LEDR, LEDG);
	input [17:0] SW;				// toggle switches
	output [17:0] LEDR;			// red LEDs
	output [7:0] LEDG;			// green LEDs

	wire Sel;
	wire [7:0] X, Y, M;

	assign LEDR = SW;
	assign X = SW[7:0];
	assign Y = SW[15:8];
	assign Sel = SW[17];

	assign M[0] = (~Sel & X[0]) | (Sel & Y[0]);
	assign M[1] = (~Sel & X[1]) | (Sel & Y[1]);
	assign M[2] = (~Sel & X[2]) | (Sel & Y[2]);
	assign M[3] = (~Sel & X[3]) | (Sel & Y[3]);
	assign M[4] = (~Sel & X[4]) | (Sel & Y[4]);
	assign M[5] = (~Sel & X[5]) | (Sel & Y[5]);
	assign M[6] = (~Sel & X[6]) | (Sel & Y[6]);
	assign M[7] = (~Sel & X[7]) | (Sel & Y[7]);
	assign LEDG[7:0] = M;
endmodule
