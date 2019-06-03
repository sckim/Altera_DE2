// scrolls the word HELLO across the 7-seg displays. An FSM inserts the
// display values into a pipeline that drives the 8 displays; each display
// is driven for about 1 second before changing to the next character
// inputs: 50 MHz clock, KEY0 is reset input, KEY1 doubles the speed of the
//   display, KEY2 halves the speed
// outputs: 7-seg displays HEX7 ... HEX0
module part7 (KEY, CLOCK_50, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDG);
	input [2:0] KEY;
	input CLOCK_50;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output [3:0] LEDG;

	wire Clock, Resetn, Tick;
	reg [3:0] y_Q, Y_D;		// This is the state machine that controls the pipeline
	wire Fast, Slow;			// Variable tick interval controls
	reg [3:0] yV_Q, YV_D;	// This is the state machine that it used to implement 
									// a variable tick interval
	reg [0:6] FSM_char;	// input to pipeline registers comes from FSM_char for
								// the first 8 clock cycles, and then comes from the
								// pipeline's last stage (HELLO travels in a loop)
	reg pipe_select;
	wire [0:6] pipe_input, pipe0, pipe1, pipe2, pipe3, pipe4, pipe5, pipe6, pipe7;

	reg var_count_sync;
	reg [3:0] var_count, Modulus;	// used to implement a variable delay

	parameter m = 23;
	reg [m-1:0] slow_count;

	assign Clock = CLOCK_50;
	assign Resetn = KEY[0];

	// Synchronize the KEY inputs
	wire KEY_sync[2:1];
	regne #(.n(1)) (~KEY[1], Clock, Resetn, 1'b1, KEY_sync[1]);
	regne #(.n(1)) (KEY_sync[1], Clock, Resetn, 1'b1, Fast);
	regne #(.n(1)) (~KEY[2], Clock, Resetn, 1'b1, KEY_sync[2]);
	regne #(.n(1)) (KEY_sync[2], Clock, Resetn, 1'b1, Slow);

	// names of states for changing a counter value for implementing
	// a variable tick delay
	parameter Sync3 = 4'b0000, Speed3 = 4'b0001, Sync4 = 4'b0010, Speed4 = 4'b0011, 
			  	Sync5 = 4'b0100, Speed5 = 4'b0101, Sync1 = 4'b0110, Speed1 = 4'b0111, 
					Sync2 = 4'b1000, Speed2 = 4'b1001;
	parameter S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, S4 = 4'b0100,
		S5 = 4'b0101, S6 = 4'b0110, S7 = 4'b0111, S8 = 4'b1000;
	parameter H = 7'b1001000, E = 7'b0110000, L = 7'b1110001, O = 7'b0000001, 
		Blank = 7'b1111111;
		
	// state machine that produces a variable delay
	// Each state will produce an output value that is used to modulo
	// a counter value. Speed 5 gives the lowest modulo value, and hence the
	// smallest delay, while Speed 1 gives the largest modulo value, and
	// hence the largest delay. There is a synchronization state before each
	// Speed state so that we can wait for the slow switch pressing to end
	always @(yV_Q, Fast, Slow)
	begin: state_table_speed
		case (yV_Q)
			Sync5:	if (Slow | Fast) YV_D = Sync5;	// wait for key to be released
						else YV_D = Speed5;
			Speed5:	if (!Slow) YV_D = Speed5;	// fastest speed
						else YV_D = Sync4;			// change to slower speed

			Sync4:	if (Slow | Fast) YV_D = Sync4;	// wait for key to be released
						else YV_D = Speed4;
			Speed4:	if (!Slow & !Fast) YV_D = Speed4;	// keep this speed
						else if (Slow) YV_D = Sync3;			// change to slower speed
						else YV_D = Sync5;			// change to faster speed

			Sync3:	if (Slow | Fast) YV_D = Sync3;	// wait for key to be released
						else YV_D = Speed3;
			Speed3:	if (!Slow & !Fast) YV_D = Speed3;	// keep this speed
						else if (Slow) YV_D = Sync2;			// change to slower speed
						else YV_D = Sync4;			// change to faster speed

			Sync2:	if (Slow | Fast) YV_D = Sync2;	// wait for key to be released
						else YV_D = Speed2;
			Speed2:	if (!Slow & !Fast) YV_D = Speed2;	// keep this speed
						else if (Slow) YV_D = Sync1;			// change to slower speed
						else YV_D = Sync3;			// change to faster speed

			Sync1:	if (Slow | Fast) YV_D = Sync1;	// wait for key to be released
						else YV_D = Speed1;
			Speed1:	if (!Fast) YV_D = Speed1;		// keep this speed
						else YV_D = Sync2;					// change to faster speed
			default: YV_D = 4'bxxxx;
		endcase
	end // state_table

	always @(posedge Clock)
		if (Resetn  == 1'b0)	// synchronous clear
			yV_Q <= Sync3;		// middle speed
		else
			yV_Q <= YV_D;

	always @(yV_Q)
	begin: state_outputs_speed
		Modulus = 4'bxxxx; var_count_sync = 1'b1;
		case (yV_Q)
			Sync5: var_count_sync = 1'b0;
			Speed5: Modulus = 4'b0000;
			Sync4: var_count_sync = 1'b0;
			Speed4: Modulus = 4'b0001;
			Sync3: var_count_sync = 1'b0;
			Speed3: Modulus = 4'b0011;
			Sync2: var_count_sync = 1'b0;
			Speed2: Modulus = 4'b0110;
			Sync1: var_count_sync = 1'b0;
			Speed1: Modulus = 4'b1100;
		endcase
	end // state_table

	assign LEDG[3:0] = Modulus;

	// A large counter to produce an approx .25 second delay
	always @(posedge Clock)
		slow_count <= slow_count + 1'b1;

	// Counter that provides a variable delay
	always @(posedge Clock)
		if (var_count_sync == 1'b0)
			var_count <= 0;
		else if (slow_count == 0)
			if (var_count == Modulus)
				var_count <= 0;
			else
				var_count <= var_count + 1'b1;

	// Tick advances the scrolling letters when var_count = slow_count = 0.
	// The var_count_sync is used to prevent scrolling when a Fast or Slow
	// key is being held down.
	assign Tick = ~| var_count & ~| slow_count & var_count_sync;

	// state machine that controls the pipeline
	always @(y_Q, Tick)
	begin: state_table
		case (y_Q)
			S0:	if (Tick) Y_D = S1;
					else Y_D = S0;
			S1:	if (Tick) Y_D = S2;
					else Y_D = S1;
			S2:	if (Tick) Y_D = S3;
					else Y_D = S2;
			S3:	if (Tick) Y_D = S4;
					else Y_D = S3;
			S4:	if (Tick) Y_D = S5;
					else Y_D = S4;
			S5:	if (Tick) Y_D = S6;
					else Y_D = S5;
			S6:	if (Tick) Y_D = S7;
					else Y_D = S6;
			S7:	if (Tick) Y_D = S8;
					else Y_D = S7;
			S8: Y_D = S8;
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
	regne (pipe_input, Clock, Resetn, Tick, pipe0);
	regne (pipe0, Clock, Resetn, Tick, pipe1);
	regne (pipe1, Clock, Resetn, Tick, pipe2);
	regne (pipe2, Clock, Resetn, Tick, pipe3);
	regne (pipe3, Clock, Resetn, Tick, pipe4);
	regne (pipe4, Clock, Resetn, Tick, pipe5);
	regne (pipe5, Clock, Resetn, Tick, pipe6);
	regne (pipe6, Clock, Resetn, Tick, pipe7);

	assign HEX0 = pipe0;
	assign HEX1 = pipe1;
	assign HEX2 = pipe2;
	assign HEX3 = pipe3;
	assign HEX4 = pipe4;
	assign HEX5 = pipe5;
	assign HEX6 = pipe6;
	assign HEX7 = pipe7;
endmodule

module regne (R, Clock, Resetn, E, Q);
	parameter n = 7;
	input [n-1:0] R;
	input Clock, Resetn, E;
	output [n-1:0] Q;
	reg [n-1:0] Q;	
	
	always @(posedge Clock)
		if (Resetn == 0)
			Q <= {n{1'b1}};
		else if (E)
			Q <= R;
endmodule
