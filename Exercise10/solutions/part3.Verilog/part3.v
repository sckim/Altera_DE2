// Reset with KEY[0]. SW[17] is Run.
// The DOUT, ADDR, W, and Done outputs are just for simulation; they
// aren't connected to any DE2 resources. The HEX0-HEX7 and LEDG are driven
// to constant values because letting them float causes some of the LEDs
// to flash on and off for this circuit.
module part3 (KEY, SW, CLOCK_50, LEDR, DOUT, ADDR, W, Done, HEX7, HEX6, HEX5, HEX4,
	HEX3, HEX2, HEX1, HEX0, LEDG);
	input [0:0] KEY;
	input [17:17] SW;
	input CLOCK_50;
	output [15:0] LEDR;
	output [15:0] DOUT, ADDR;
	output W;
	output Done;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output [8:0] LEDG;
	assign HEX7 = 7'b0000000;
	assign HEX6 = 7'b0000000;
	assign HEX5 = 7'b0000000;
	assign HEX4 = 7'b0000000;
	assign HEX3 = 7'b0000000;
	assign HEX2 = 7'b0000000;
	assign HEX1 = 7'b0000000;
	assign HEX0 = 7'b0000000;
	assign LEDG = 9'b000000000;

	wire [15:0] DIN;
	wire Sync, Run;
	wire inst_mem_cs, LED_reg_cs;
	wire [15:0] LED_reg;

	// synchronize the Run input
	flipflop U1 (SW[17], KEY[0], CLOCK_50, Sync);
	flipflop U2 (Sync, KEY[0], CLOCK_50, Run);
	
	// module proc(DIN, Resetn, Clock, Run, DOUT, ADDR, W, Done);
	proc U3 (DIN, KEY[0], CLOCK_50, Run, DOUT, ADDR, W, Done);

	assign inst_mem_cs = (ADDR[15:12] == 4'h0);
	// module inst_mem ( data, wren, address, clock, q);
	inst_mem U4 (DOUT, inst_mem_cs & W, ADDR[6:0], CLOCK_50, DIN);

	assign LED_reg_cs = (ADDR[15:12] == 4'h1);
	// module regn(R, Rin, Clock, Q);
	regn U6 (DOUT, LED_reg_cs & W, CLOCK_50, LED_reg);
	assign LEDR[15:0] = LED_reg[15:0];

endmodule

