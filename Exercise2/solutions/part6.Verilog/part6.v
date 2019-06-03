// implements a two-digit bcd adder S2 S1 S0 = A1 A0 + B1 B0
// inputs: SW15-8 = A1 A0
//         SW7-0 = B1 B0
// outputs: A1 A0 is displayed on HEX7 HEX6
// 			B1 B0 is displayed on HEX5 HEX4
// 			S2 S1 S0 is displayed on HEX2 HEX1 HEX0
module part6 (SW, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input [15:0] SW;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	wire[3:0] A1, A0, B1, B0;
	assign A1 = SW[15:12];
	assign A0 = SW[11:8];
	assign B1 = SW[7:4];
	assign B0 = SW[3:0];
	
	wire [3:0] S0, S1;
	wire S2;
	reg C1, C2;

	wire [4:0] T1, T0;			// used for bcd addition
	reg [3:0] Z1, Z0;			// used for bcd addition

	// add lower two bcd digits. Result is five bits: C1,S0
	assign T0 = {1'b0,A0} + {1'b0,B0};
	always @ (T0)
	begin
		if (T0 > 5'd9)
		begin
			Z0 = 4'd6;	// we will add +6 instead of -10
			C1 = 1'b1;
		end
		else
		begin
			Z0 = 4'd0;
			C1 = 1'b0;
		end
	end
	assign S0 = T0[3:0] + Z0;	// using 4 bits, + 6 is same as - 10

	// add upper two bcd digits plus C1
	assign T1 = {1'b0,A1} + {1'b0,B1} + C1;
	always @ (T1)
	begin
		if (T1 > 5'd9)
		begin
			Z1 = 4'd6;	// we will add +6 instead of -10
			C2 = 1'b1;
		end
		else
		begin
			Z1 = 4'd0;
			C2 = 1'b0;
		end
	end
	assign S1 = T1[3:0] + Z1; // using 4 bits, + 6 is same as - 10
	assign S2 = C2;
	
	// drive the displays through 7-seg decoders
	bcd7seg digit7 (A1, HEX7);
	bcd7seg digit6 (A0, HEX6);
	bcd7seg digit5 (B1, HEX5);
	bcd7seg digit4 (B0, HEX4);
	bcd7seg digit2 ({3'b000, S2}, HEX2);
	bcd7seg digit1 (S1, HEX1);
	bcd7seg digit0 (S0, HEX0);

	assign HEX3 = 7'b1111111;	// turn off HEX3
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
	
