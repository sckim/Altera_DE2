// a mod-10 counter
// inputs: SW0 is the active low synchronous reset, and KEY0 is the clock. SW2 SW1 
// are the w1 w0 inputs.
// output: if w1 w0 == 00, keep count the same
// 	if w1 w0 == 01, increment count by 1
// 	if w1 w0 == 10, increment count by 2
// 	if w1 w0 == 11, decrement count by 1
// drive count to digit HEX0
module part4 (SW, KEY, HEX0);
	input [2:0] SW;
	input [0:0] KEY;
	output [0:6] HEX0;

	wire Clock, Resetn;
	wire [1:0] w;
	reg [3:0] y_Q, Y_D;

	assign Clock = KEY[0];
	assign Resetn = SW[0];
	assign w[1:0]= SW[2:1];

	parameter A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011, E = 4'b0100,
		F = 4'b0101, G = 4'b0110, H = 4'b0111, I = 4'b1000, J = 4'b1001;
		
	always @(w, y_Q)
	begin: state_table
		case (y_Q)
			A: case (w)
					2'b00: Y_D = A;
					2'b01: Y_D = B;
					2'b10: Y_D = C;
					2'b11: Y_D = J;
				endcase
			B: case (w)
					2'b00: Y_D = B;
					2'b01: Y_D = C;
					2'b10: Y_D = D;
					2'b11: Y_D = A;
				endcase
			C: case (w)
					2'b00: Y_D = C;
					2'b01: Y_D = D;
					2'b10: Y_D = E;
					2'b11: Y_D = B;
				endcase
			D: case (w)
					2'b00: Y_D = D;
					2'b01: Y_D = E;
					2'b10: Y_D = F;
					2'b11: Y_D = C;
				endcase
			E: case (w)
					2'b00: Y_D = E;
					2'b01: Y_D = F;
					2'b10: Y_D = G;
					2'b11: Y_D = D;
				endcase
			F: case (w)
					2'b00: Y_D = F;
					2'b01: Y_D = G;
					2'b10: Y_D = H;
					2'b11: Y_D = E;
				endcase
			G: case (w)
					2'b00: Y_D = G;
					2'b01: Y_D = H;
					2'b10: Y_D = I;
					2'b11: Y_D = F;
				endcase
			H: case (w)
					2'b00: Y_D = H;
					2'b01: Y_D = I;
					2'b10: Y_D = J;
					2'b11: Y_D = G;
				endcase
			I: case (w)
					2'b00: Y_D = I;
					2'b01: Y_D = J;
					2'b10: Y_D = A;
					2'b11: Y_D = H;
				endcase
			J: case (w)
					2'b00: Y_D = J;
					2'b01: Y_D = A;
					2'b10: Y_D = B;
					2'b11: Y_D = I;
				endcase
			default: Y_D = 4'bxxxx;
		endcase
	end // state_table

	always @(posedge Clock)
		if (Resetn  == 1'b0)	// synchronous clear
			y_Q <= A;
		else
			y_Q <= Y_D;

	bcd7seg (y_Q, HEX0);

endmodule

module bcd7seg (bcd, display);
	input [3:0] bcd;
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
	always @ (bcd)
		case (bcd)
			4'h0: display = 7'b0000001;
			4'h1: display = 7'b1001111;
			4'h2: display = 7'b0010010;
			4'h3: display = 7'b0000110;
			4'h4: display = 7'b1001100;
			4'h5: display = 7'b0100100;
			4'h6: display = 7'b1100000;
			4'h7: display = 7'b0001111;
			4'h8: display = 7'b0000000;
			4'h9: display = 7'b0001100;
			default: display = 7'b1111111;
		endcase
endmodule

