// scrolls the word HELLO across the 7-seg displays. An FSM inserts the
// display values into a pipeline that drives the 8 displays.
// inputs: KEY0 is the manual clock, and SW0 is the reset input
// outputs: 7-seg displays HEX7 ... HEX0
module part5 (SW, KEY, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input [0:0] SW;
	input [0:0] KEY;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	wire Clock, Resetn;
	reg [3:0] y_Q, Y_D;
	reg [0:6] FSM_char;	// input to pipeline registers comes from FSM_char for
								// the first 8 clock cycles, and then comes from the
								// pipeline's last stage (HELLO travels in a loop)
	reg pipe_select;
	wire [0:6] pipe_input, pipe0, pipe1, pipe2, pipe3, pipe4, pipe5, pipe6, pipe7;

	assign Clock = KEY[0];
	assign Resetn = SW[0];

	parameter S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, S4 = 4'b0100,
		S5 = 4'b0101, S6 = 4'b0110, S7 = 4'b0111, S8 = 4'b1000;
	parameter H = 7'b1001000, E = 7'b0110000, L = 7'b1110001, O = 7'b0000001, 
		Blank = 7'b1111111;
		
	always @(y_Q)
	begin: state_table
		case (y_Q)
			S0:	Y_D = S1;
			S1:	Y_D = S2;
			S2:	Y_D = S3;
			S3:	Y_D = S4;
			S4:	Y_D = S5;
			S5:	Y_D = S6;
			S6:	Y_D = S7;
			S7:	Y_D = S8;
			S8: 	Y_D = S8;
			default: Y_D = 4'bxxxx;
		endcase
	end // state_table

	always @(posedge Clock)
		if (Resetn  == 1'b0)	// synchronous clear
			y_Q <= S0;
		else
			y_Q <= Y_D;

	always @(y_Q)
	begin: state_outputs
		pipe_select = 1'b0; FSM_char = 7'bxxxxxxx;
		case (y_Q)
			S0: FSM_char = H;
			S1: FSM_char = E;
			S2: FSM_char = L;
			S3: FSM_char = L;
			S4: FSM_char = O;
			S5: FSM_char = Blank;
			S6: FSM_char = Blank;
			S7: FSM_char = Blank;
			S8: pipe_select = 1'b1;	// establish feedback loop
			default: Y_D = 4'bxxxx;
		endcase
	end // state_table

	assign pipe_input = (pipe_select == 1'b0) ? FSM_char : pipe7;
	// module regne (R, Clock, Resetn, E, Q);
	regne (pipe_input, Clock, Resetn, pipe0);
	regne (pipe0, Clock, Resetn, pipe1);
	regne (pipe1, Clock, Resetn, pipe2);
	regne (pipe2, Clock, Resetn, pipe3);
	regne (pipe3, Clock, Resetn, pipe4);
	regne (pipe4, Clock, Resetn, pipe5);
	regne (pipe5, Clock, Resetn, pipe6);
	regne (pipe6, Clock, Resetn, pipe7);

	assign HEX0 = pipe0;
	assign HEX1 = pipe1;
	assign HEX2 = pipe2;
	assign HEX3 = pipe3;
	assign HEX4 = pipe4;
	assign HEX5 = pipe5;
	assign HEX6 = pipe6;
	assign HEX7 = pipe7;
endmodule

module regne (R, Clock, Resetn, Q);
	parameter n = 7;
	input [n-1:0] R;
	input Clock, Resetn;
	output [n-1:0] Q;
	reg [n-1:0] Q;	
	
	always @(posedge Clock)
		if (Resetn == 0)
			Q <= {n{1'b1}};
		else
			Q <= R;
endmodule
