// 3-digit BCD counter.
module part1 (Clock, KEY, HEX3, HEX2, HEX1, HEX0);
	input Clock;
	input [3:0] KEY;
	output [0:6] HEX3, HEX2, HEX1, HEX0;

	parameter m = 25;
	reg [m-1:0] slow_count;

	reg[3:0] bcd_0, bcd_1, bcd_2;

	// Create a 1Hz 4-bit counter

	// A large counter to produce a 1 second (approx) enable
	always @(posedge Clock)
		slow_count <= slow_count + 1'b1;

	// 3-digit BCD counter that uses a slow enable 
	always @ (posedge Clock)
		if (KEY[3] == 0)
		begin
			bcd_0 <= 4'h0;
			bcd_1 <= 4'h0;
			bcd_2 <= 4'h0;
		end
		else if (slow_count == 0)
		begin
			if (bcd_0 == 4'h9)	
			begin
				bcd_0 <= 4'h0;
	 			if (bcd_1 == 4'h9)
				begin
					bcd_1 <= 4'h0;
					if (bcd_2 == 4'h9)
					begin
						bcd_2 <= 4'h0;
					end
					else
					begin
						bcd_2 <= bcd_2 + 1'b1;
					end
			 	end
				else
				begin	
					bcd_1 <= bcd_1 + 1'b1;
				end
		 	end
			else
			begin
				bcd_0 <= bcd_0 + 1'b1;
			end
	 	end
				
	// drive the displays
	bcd7seg digit2 (bcd_2, HEX2);
	bcd7seg digit1 (bcd_1, HEX1);
	bcd7seg digit0 (bcd_0, HEX0);
	// blank the adjacent display
	bcd7seg digit3 (4'hF, HEX3);
	
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
	
