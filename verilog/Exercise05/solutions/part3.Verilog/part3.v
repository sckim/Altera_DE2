// Press KEY[0] to reset. After a delay (#seconds set by the SW[7:0]
// switches), LEDR[0] turns on and the timer starts. Stop the timer by
// pressing KEY[3]
module part3 (Clock, SW, KEY, LEDR, HEX7, HEX6, HEX5, HEX4, 
	HEX3, HEX2, HEX1, HEX0);
	input Clock;
	input [7:0] SW;
	input [3:0] KEY;
	output [0:0] LEDR;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	parameter m = 16;
	reg [m-1:0] slow_count;

	parameter k = 25;
	reg [k-1:0] second;

	wire start;
	reg[7:0] pseudo;
	reg[3:0] sec_0, sec_1, min_0, min_1;

	regne #(.n(1)) reg_start (1'b1, Clock, KEY[3] & KEY[0], (pseudo == 0), start);
	assign LEDR[0] = start;

	// A large counter to produce a 1 sec second (approx) enable
	always @(posedge Clock)
		second <= second + 1'b1;

	// A large counter to produce a 1 msec second (approx) enable
	always @(posedge Clock)
		slow_count <= slow_count + 1'b1;

	// Pseudo random delay counter--loads SW switches and counts down
	always @(posedge Clock)
		if ( (KEY[3] && KEY[0]) == 0)
			pseudo <= SW;
 		else if (second == 0)
			pseudo <= pseudo - 1'b1;

	// 4-digit time counter that uses a slow enable
	always @ (posedge Clock or negedge KEY[0])
		if (KEY[0] == 0)
		begin
			sec_0 <= 4'b0;
			sec_1 <= 4'b0;
			min_0 <= 4'b0;
			min_1 <= 4'b0;
		end
		else if ( (slow_count == 0) && start)
			begin
				if (sec_0 == 4'h9)	
				begin
					sec_0 <= 4'h0;
	 				if (sec_1 == 4'h9)
					begin
						sec_1 <= 4'h0;
						if (min_0 == 4'h9)
						begin
							min_0 <= 4'h0;
							if (min_1 == 4'h9)
							begin
								min_1 <= 4'h0;
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
	// blank the unused displays
	bcd7seg digit7 (4'hF, HEX7);
	bcd7seg digit6 (4'hF, HEX6);
	bcd7seg digit5 (4'hF, HEX5);
	bcd7seg digit4 (4'hF, HEX4);

	bcd7seg digit3 (min_1, HEX3);
	bcd7seg digit2 (min_0, HEX2);
	bcd7seg digit1 (sec_1, HEX1);
	bcd7seg digit0 (sec_0, HEX0);
	
endmodule
			
module regne (R, Clock, Resetn, E, Q);
	parameter n = 4;
	input [n-1:0] R;
	input Clock, Resetn, E;
	output [n-1:0] Q;
	reg [n-1:0] Q;	
	
	always @(posedge Clock or negedge Resetn)
		if (Resetn == 0)
			Q <= {n{1'b0}};
		else if (E == 1)
			Q <= R;
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
