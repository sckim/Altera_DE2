// Data written to registers R0 to R7 are sent to the HEX digits
module seg7_scroll (Data, Addr, Sel, Resetn, Clock, HEX7, HEX6, HEX5, HEX4,
	HEX3, HEX2, HEX1, HEX0);
	input [0:6] Data;
	input [2:0] Addr;
	input Sel, Resetn, Clock;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	wire [0:6] R0, R1, R2, R3, R4, R5, R6, R7;

	regne reg_R0 (Data, Clock, Resetn, Sel & (Addr == 3'b000), R0);
	regne reg_R1 (Data, Clock, Resetn, Sel & (Addr == 3'b001), R1);
	regne reg_R2 (Data, Clock, Resetn, Sel & (Addr == 3'b010), R2);
	regne reg_R3 (Data, Clock, Resetn, Sel & (Addr == 3'b011), R3);
	regne reg_R4 (Data, Clock, Resetn, Sel & (Addr == 3'b100), R4);
	regne reg_R5 (Data, Clock, Resetn, Sel & (Addr == 3'b101), R5);
	regne reg_R6 (Data, Clock, Resetn, Sel & (Addr == 3'b110), R6);
	regne reg_R7 (Data, Clock, Resetn, Sel & (Addr == 3'b111), R7);

	assign HEX7 = R0; 
	assign HEX6 = R1; 
	assign HEX5 = R2; 
	assign HEX4 = R3; 
	assign HEX3 = R4; 
	assign HEX2 = R5; 
	assign HEX1 = R6; 
	assign HEX0 = R7;
	
endmodule

module regne (R, Clock, Resetn, E, Q);
	parameter n = 7;
	input [n-1:0] R;
	input Clock, Resetn, E;
	output [n-1:0] Q;
	reg [n-1:0] Q;	
	
	always @(posedge Clock)
		if (Resetn == 0)
			Q <= {n{1'b0}};
		else if (E)
			Q <= R;
endmodule
