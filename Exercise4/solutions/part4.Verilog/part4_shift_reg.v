// uses a shift register enabled at 1Hz and a MUX. To start the circuit's
// operation, the shift register must be parallel loaded by pressing KEY[3]
module part4 (KEY, Clock, HEX0, LEDR);
	input [3:0] KEY;
	input Clock;
	output [0:6] HEX0;
	output [9:0] LEDR;

	wire [3:0] bcd;
	wire shift_enable;
	parameter m = 25;
	reg [m-1:0] slow_count;
	reg [3:0] digit_flipper;

	reg[9:0] rotate;

	// A large counter to produce a 1 second (approx) enable
	always @(posedge Clock)
		slow_count <= slow_count + 1'b1;

	assign shift_enable = (slow_count == 0);
	// shift register with enable
	integer k;
	always @(posedge Clock)
	begin
		if (KEY[3] == 0)
			rotate <= 10'b0000000001;
		else if (shift_enable)
		begin
			for (k = 0; k < 9; k = k+1)
				rotate[k+1] <= rotate[k];
			rotate[0] <= rotate[k];
		end
	end

	assign LEDR = rotate;

	always @ (rotate)
		case (rotate)
			10'b0000000001:		digit_flipper = 4'h0;
			10'b0000000010:		digit_flipper = 4'h1;
			10'b0000000100:		digit_flipper = 4'h2;
			10'b0000001000:		digit_flipper = 4'h3;
			10'b0000010000:		digit_flipper = 4'h4;
			10'b0000100000:		digit_flipper = 4'h5;
			10'b0001000000:		digit_flipper = 4'h6;
			10'b0010000000:		digit_flipper = 4'h7;
			10'b0100000000:		digit_flipper = 4'h8;
			10'b1000000000:		digit_flipper = 4'h9;
			default:			digit_flipper = 4'bx;
		endcase
				
	assign bcd = digit_flipper;
	// drive the display through a 7-seg decoder
	bcd7seg digit_0 (bcd, HEX0);
	
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
			default: display = 7'bx;
		endcase
endmodule
