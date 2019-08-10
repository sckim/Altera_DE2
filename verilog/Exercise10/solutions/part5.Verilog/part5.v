// Reset with KEY[0]. SW[17] is Run
// The processor executes the instructions in the file inst_mem.mif
module part5 (KEY, SW, CLOCK_50, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, 
	LEDR, LEDG, DOUT, ADDR, W, Done);
	input [0:0] KEY;
	input [17:0] SW;
	input CLOCK_50;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output [15:0] LEDR;	
	output [8:0] LEDG;	
	output [15:0] DOUT, ADDR;
	output W;
	output Done;

	reg [15:0] DIN;
	wire Sync, Run;
	wire inst_mem_cs, seg7_cs, LED_reg_cs;
	wire [15:0] LED_reg, SW_reg, inst_mem_q;

	// synchronize the Run input
	flipflop U1 (SW[17], KEY[0], CLOCK_50, Sync);
	flipflop U2 (Sync, KEY[0], CLOCK_50, Run);
	
	// module proc(DIN, Resetn, Clock, Run, DOUT, ADDR, W, Done);
	proc U3 (DIN, KEY[0], CLOCK_50, Run, DOUT, ADDR, W, Done);

	assign inst_mem_cs = (ADDR[15:12] == 4'h0);
	// module inst_mem ( data, wren, address, clock, q);
	inst_mem U4 (DOUT, inst_mem_cs & W, ADDR[6:0], CLOCK_50, inst_mem_q);

	always @ (inst_mem_q or SW_reg or inst_mem_cs)
	if (inst_mem_cs == 1'b1)
		DIN = inst_mem_q;
	else
		DIN = SW_reg;

	assign LED_reg_cs = (ADDR[15:12] == 4'h1);
	// module regn(R, Rin, Clock, Q);
	regn U6 (DOUT, LED_reg_cs & W, CLOCK_50, LED_reg);
	assign LEDR[15:0] = LED_reg[15:0];
	assign LEDG = 9'b0;

	assign seg7_cs = (ADDR[15:12] == 4'h2);
	seg7_scroll U5 (DOUT[6:0], ADDR[2:0], seg7_cs & W, KEY[0], CLOCK_50, HEX7, HEX6, 
		HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

	// module regn(R, Rin, Clock, Q);
	regn U7 (SW[15:0], 1'b1, CLOCK_50, SW_reg);

endmodule

