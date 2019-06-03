// scans the word HELLO across the 7-seg displays. KEY[3] causes a reset,
// and KEY[0] initializes the counters that select the characters in HELLO.
module part3 (Clock, KEY, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input Clock;
	input [3:0] KEY;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	wire [3:0] seg7_7, seg7_6, seg7_5, seg7_4, seg7_3, seg7_2, seg7_1, seg7_0;
	wire Enable;
	parameter m = 24;
	reg [m-1:0] slow_count;

	// Create a 1Hz 4-bit counter

	// A large counter to produce a 1 second (approx) enable
	always @(posedge Clock)
		slow_count <= slow_count + 1'b1;

	assign Enable = (slow_count == 0);
	// module upcount (R, Resetn, Clock, L, E, Q);
	upcount (3'b000, KEY[3], Clock, !KEY[0], Enable, seg7_7);
	upcount (3'b001, KEY[3], Clock, !KEY[0], Enable, seg7_6);
	upcount (3'b010, KEY[3], Clock, !KEY[0], Enable, seg7_5);
	upcount (3'b011, KEY[3], Clock, !KEY[0], Enable, seg7_4);
	upcount (3'b100, KEY[3], Clock, !KEY[0], Enable, seg7_3);
	upcount (3'b101, KEY[3], Clock, !KEY[0], Enable, seg7_2);
	upcount (3'b110, KEY[3], Clock, !KEY[0], Enable, seg7_1);
	upcount (3'b111, KEY[3], Clock, !KEY[0], Enable, seg7_0);
	
	// drive the display through a 7-seg decoder designed specifically for letters
	// 'h' 'e' 'l' 'o' and ' '
	hello7seg digit_7 (seg7_7, HEX7);
	hello7seg digit_6 (seg7_6, HEX6);
	hello7seg digit_5 (seg7_5, HEX5);
	hello7seg digit_4 (seg7_4, HEX4);
	hello7seg digit_3 (seg7_3, HEX3);
	hello7seg digit_2 (seg7_2, HEX2);
	hello7seg digit_1 (seg7_1, HEX1);
	hello7seg digit_0 (seg7_0, HEX0);
	
endmodule

// three-bit counter with parallel load and enable
module upcount (R, Resetn, Clock, L, E, Q);
	input [2:0] R;
	input Resetn, Clock, L, E;
	output [2:0] Q;
	reg [2:0] Q;

	always @ (posedge Clock)
		if (Resetn == 0)
			Q <= 3'b000;
		else if (L)
			Q <= R;
		else if (E)
			Q <= Q + 3'b001;
endmodule
				
module hello7seg (char, display);
	input [2:0] char;
	output [0:6] display;

	reg [0:6] display;

	/*
	 *       0  
	 *      ---  
	 *     |   |
	 *    5|   |1
	 *     | 6 |
	 *      ---  
	 *     |   |
	 *    4|   |2
	 *     |   |
	 *      ---  
	 *       3  
	 */
	always @ (char)
		case (char)
			3'h0: display = 7'b1001000;		// 'H'
			3'h1: display = 7'b0110000;		// 'E'
			3'h2: display = 7'b1110001;		// 'L'
			3'h3: display = 7'b1110001;		// 'L'
			3'h4: display = 7'b1000000;		// 'O'
			3'h5: display = 7'b1111111;		// ' '
			3'h6: display = 7'b1111111;		// ' '
			3'h7: display = 7'b1111111;		// ' '
		endcase
endmodule
