// Real time settable clock. Set SW[15:8] switches to 2-digit BCD number
// representing hours. Set SW[7:0] to 2-digit number representing minutes.
// Load initial time by pressing KEY[3].
module part2 (Clock, SW, KEY, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input Clock;
	input [15:0] SW;
	input [3:0] KEY;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	parameter m = 25;
	reg [m-1:0] slow_count;

	reg[3:0] hr_1, hr_0, min_1, min_0, sec_1, sec_0;

	// A large counter to produce a 1 second (approx) enable
	always @(posedge Clock)
		slow_count <= slow_count + 1'b1;

	// 6-digit clock display
	always @ (posedge Clock)
		if (KEY[3] == 0)
		begin
			hr_1 <= SW[15:12];
			hr_0 <= SW[11:8];
			min_1 <= SW[7:4];
			min_0 <= SW[3:0];
		end
		else
			if (slow_count == 0)
			begin
				if (sec_0 == 4'h9)	
				begin
					sec_0 <= 4'h0;
	 				if (sec_1 == 4'h5)
					begin
						sec_1 <= 4'h0;
						if (min_0 == 4'h9)
						begin
							min_0 <= 4'h0;
							if (min_1 == 4'h5)
							begin
								min_1 <= 4'h0;
								if (hr_0 == 4'h3)
								begin
									if (hr_1 == 4'h2)
									begin
										hr_0 <= 4'h0;
										hr_1 <= 4'h0;
									end
									else
									begin
										hr_0 <= hr_0 + 1'b1;
									end
								end
								else if (hr_0 == 4'h9)
								begin
									hr_0 <= 4'h0;
									hr_1 <= hr_1 + 1'b1;
								end
								else
								begin
									hr_0 <= hr_0 + 1'b1;
								end
							end
							else
							begin
								min_1 <= min_1 + 1'b1;
							end
						end
						else
						begin
							min_0 <= min_0 + 1'b1;
						end
			 		end
					else
					begin	
						sec_1 <= sec_1 + 1'b1;
					end
		 		end
				else
				begin
					sec_0 <= sec_0 + 1'b1;
				end
	 		end
				
	// drive the displays
	bcd7seg digit7 (hr_1, HEX7);
	bcd7seg digit6 (hr_0, HEX6);
	bcd7seg digit5 (min_1, HEX5);
	bcd7seg digit4 (min_0, HEX4);
	bcd7seg digit3 (sec_1, HEX3);
	bcd7seg digit2 (sec_0, HEX2);
	// blank the adjacent display
	bcd7seg digit1 (4'hF, HEX1);
	bcd7seg digit0 (4'hF, HEX0);
	
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
	
			
