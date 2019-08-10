// KEY[0] is the reset input, and KEY[1] is the clock. SW15-0 are the instructions,
// and SW[17] is the Run input. The processor bus appears on LEDR15-0 and
// Done appears on LEDR17
module part1 (KEY, SW, LEDR);
	input [1:0] KEY;
	input [17:0] SW;
	output [17:0] LEDR;	

	wire Resetn, Manual_Clock, Run, Done;
	wire [15:0] DIN, Bus;

	assign Resetn = KEY[0];
	assign Manual_Clock = KEY[1];	
		// Note: can't use name Clock because this is defined as
		// the 50 MHz Clock coming into the FPGA from the board
	assign DIN = SW[15:0];
	assign Run = SW[17];

	// module proc(DIN, Resetn, Clock, Run, Done, Bus);
	proc U1 (DIN, Resetn, Manual_Clock, Run, Done, Bus);

	assign LEDR[15:0] = Bus;
	assign LEDR[16] = 1'b0;
	assign LEDR[17] = Done;

endmodule

