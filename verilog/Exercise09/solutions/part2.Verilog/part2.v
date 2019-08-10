// Reset with KEY[0]. Clock counter and memory with KEY[2]. Clock
// each instuction into the processor with KEY[1]. SW[17] is the Run input.
// Use KEY[2] to advance the memory as needed before each processor KEY[1]
// clock cycle.
module part2 (KEY, SW, LEDR);
	input [2:0] KEY;
	input [17:17] SW;
	output [17:0] LEDR;	

	wire Done, Resetn, PClock, MClock, Run;
	wire [15:0] DIN, Bus;
	wire [4:0] pc;

	assign Resetn = KEY[0];
	assign PClock = KEY[1];
	assign MClock = KEY[2];
	assign Run = SW[17];

	// module proc(DIN, Resetn, Clock, Run, Done, BusWires);
	proc U1 (DIN, Resetn, PClock, Run, Done, Bus);
	assign LEDR[15:0] = Bus;
	assign LEDR[17] = Done;

	inst_mem U2 (pc, MClock, DIN);
	count5 U3 (Resetn, MClock, pc);

endmodule

module count5 (Resetn, Clock, Q);
	input Resetn, Clock;
	output reg [4:0] Q;

	always @ (posedge Clock)
		if (Resetn == 0)
			Q <= 5'b00000;
		else
			Q <= Q + 1'b1;
 endmodule
