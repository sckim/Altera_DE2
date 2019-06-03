// Implements a 3-bit wide 5-to-1 multiplexer.
// inputs:	SW14-0 represent data in 5 groups, U-Y
// 			SW17-15 selects one group from U to Y
// outputs: LEDR17-0 show the states of the switches
// 			LEDG2-0 displays the selected group
module part3 (SW, LEDR, LEDG);
	input [17:0] SW;				// toggle switches
	output [17:0] LEDR;			// red LEDs
	output [2:0] LEDG;			// green LEDs

	wire [1:3] m_0, m_1, m_2;	// m_0 is used for 3 intermediate multiplexers 
										// to produce the 5-to-1 multiplexer M[0], m_1 is for
										// M[1], and m_2 is for M[2]
	wire [2:0] S, U, V, W, X, Y, M;	// M is the 3-bit 5-to-1 multiplexer

	assign S[2:0] = SW[17:15];
	assign U = SW[2:0];
	assign V = SW[5:3];
	assign W = SW[8:6];
	assign X = SW[11:9];
	assign Y = SW[14:12];

	assign LEDR = SW;

	// 5-to-1 multiplexer for bit 0
	assign m_0[1] = (~S[0] & U[0]) | (S[0] & V[0]);
	assign m_0[2] = (~S[0] & W[0]) | (S[0] & X[0]);
	assign m_0[3] = (~S[1] & m_0[1]) | (S[1] & m_0[2]);
	assign M[0] = (~S[2] & m_0[3]) | (S[2] & Y[0]); // 5-to-1 multiplexer output

	// 5-to-1 multiplexer for bit 1
	assign m_1[1] = (~S[0] & U[1]) | (S[0] & V[1]);
	assign m_1[2] = (~S[0] & W[1]) | (S[0] & X[1]);
	assign m_1[3] = (~S[1] & m_1[1]) | (S[1] & m_1[2]);
	assign M[1] = (~S[2] & m_1[3]) | (S[2] & Y[1]); // 5-to-1 multiplexer output
	
	// 5-to-1 multiplexer for bit 2
	assign m_2[1] = (~S[0] & U[2]) | (S[0] & V[2]);
	assign m_2[2] = (~S[0] & W[2]) | (S[0] & X[2]);
	assign m_2[3] = (~S[1] & m_2[1]) | (S[1] & m_2[2]);
	assign M[2] = (~S[2] & m_2[3]) | (S[2] & Y[2]); // 5-to-1 multiplexer output
	
	assign LEDG[2:0] = M;
endmodule
