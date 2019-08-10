// input six bits using SW toggle switches, and convert to decimal (2-digit bcd)
module part7 (SW, HEX3, HEX2, HEX1, HEX0);
	input [5:0] SW;
	output [0:6] HEX3, HEX2, HEX1, HEX0;

	reg [3:0] bcd_h, bcd_l;
	wire [5:0] bin6;

	assign bin6 = SW;

	// Check various ranges and set bcd digits. Note that we work with
	// bin6[3:0] just to prevent compiler warnings about bit size
	// truncation. This is not really necessary
	always @ (bin6)
	begin
		if (bin6 < 10)
		begin
			bcd_h = 4'h0;
			bcd_l = bin6[3:0];
		end
		else if (bin6 < 20)
		begin
			bcd_h = 4'h1;
			bcd_l = /* bin6 - 10 */ bin6[3:0] + 4'h6;	// -10 = 11110110. So, add 6
		end
		else if (bin6 < 30)
		begin
			bcd_h = 4'h2;
			bcd_l = /* bin6 - 20 */ bin6[3:0] + 4'hC;	// -20 = 11101100. So, add 12
		end
		else if (bin6 < 40)
		begin
			bcd_h = 4'h3;
			bcd_l = /* bin6 - 30 */ bin6[3:0] + 4'h2;	// -30 = 11100010. So, add 2
		end
		else if (bin6 < 50)
		begin
			bcd_h = 4'h4;
			bcd_l = /* bin6 - 40 */ bin6[3:0] + 4'h8;	// -40 = 11011000. So, add 8 
		end
		else if (bin6 < 60)
		begin
			bcd_h = 4'h5;
			bcd_l = /* bin6 - 50 */ bin6[3:0] + 4'hE;	// -50 = 11001110. So, add 14 
		end
		else
		begin
			bcd_h = 4'h6;
			bcd_l = /* bin6 - 60 */ bin6[3:0] + 4'h4;	// -60 = 11000100. So, add 4 
		end
	end

	// drive the displays
	bcd7seg digit1 (bcd_h, HEX1);
	bcd7seg digit0 (bcd_l, HEX0);

	// blank the adjacent displays
	bcd7seg digit3 (4'hF, HEX3);
	bcd7seg digit2 (4'hF, HEX2);
	
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
