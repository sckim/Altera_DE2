// a sequence detector FSM using a shift register
// SW0 is the active low synchronous reset, SW1 is the w input, and KEY0 is the clock.
// The z output appears on LEDG0, and the shift register FFs appear on LEDR3..0
// a sequence detector shift register
// inputs: Resetn is 
module part3 (SW, KEY, LEDG, LEDR);
	input [1:0] SW;
	input [0:0] KEY;
	output [0:0] LEDG;
	output [7:0] LEDR;

	wire Clock, Resetn, w, z;
	reg [1:4] S4_0s;	// shift register for recognizing 4 0s
	reg [1:4] S4_1s;	// shift register for recognizing 4 1s

	assign Clock = KEY[0];
	assign Resetn = SW[0];
	assign w = SW[1];
	always @(posedge Clock)
	begin
		if (Resetn == 1'b0)
		begin
			S4_0s <= 4'b1111;
			S4_1s <= 4'b0000;
		end
		else
		begin
			S4_0s[1] <= w;
			S4_0s[2] <= S4_0s[1];
			S4_0s[3] <= S4_0s[2];
			S4_0s[4] <= S4_0s[3];

			S4_1s[1] <= w;
			S4_1s[2] <= S4_1s[1];
			S4_1s[3] <= S4_1s[2];
			S4_1s[4] <= S4_1s[3];
		end
	end

	assign z = ((S4_0s == 4'b0000) | (S4_1s == 4'b1111)) ? 1'b1 : 1'b0;
	assign LEDR[3:0] = S4_0s;
	assign LEDR[7:4] = S4_1s;
	assign LEDG[0] = z;
endmodule
