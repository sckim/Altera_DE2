// unsigned 8-bit multiplier-adder S = (A x B) + (C x D)
// Uses lpm_multadd. Registers are included for all inputs and outputs.
// inputs:	SW15-8 = A or C, SW7-0 = B or D
// 			SW16 = 0 loads A and B, SW16 = 1 loads C and D
// 			SW17 = write enable. Setting this to 1 allows registers A, B or
// 			C, D to be written
// 			KEY0 = active-low asynchronous reset
// 			KEY1 = manual clock
// outputs:	HEX7-6 shows input A when SW16 = 0, shows input C when SW16 = 1
// 			HEX5-4 shows input B when SW16 = 0, shows input D when SW16 = 1
// 			HEX3-0 shows the output sum
module part9 (SW, KEY, LEDG, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input [17:0] SW;
	input [1:0] KEY;
	output [8:8] LEDG;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	wire Clock, Resetn, sel_AB_CD, WE;	// sel_AB_CD selects regs, WE is write enable
	wire Cout;	// carry out for final sum
	assign Resetn = KEY[0];
	assign Clock = KEY[1];
	wire [7:0] A, B, C, D, A_C, B_D;
	wire [16:0] S;
	wire [15:0] S_reg;

	assign sel_AB_CD = SW[16];
	assign WE = SW[17];

	// instantiate module regne (R, Clock, Resetn, Q);
	regne U_A (SW[15:8], Clock, Resetn, ~sel_AB_CD & WE, A);
	regne U_B (SW[7:0], Clock, Resetn, ~sel_AB_CD & WE, B);
	regne U_C (SW[15:8], Clock, Resetn, sel_AB_CD & WE, C);
	regne U_D (SW[7:0], Clock, Resetn, sel_AB_CD & WE, D);

	// instantiate module alt_multadd16 (dataa_0, dataa_1, datab_0, datab_1, result);
	alt_multadd16 U_Sum (A, C, B, D, S);

	// Use the configuration of alt_multadd below for the pipelined version
	// instantiate module alt_multadd16_pipe (aclr0, clock0, dataa_0, dataa_1, 
	// 	datab_0, datab_1, result);
	// alt_multadd16_pipe U_Sum (~Resetn, Clock, A, C, B, D, S);

	// instantiate module regne (R, Clock, Resetn, Q);
	regne #(.n(16)) U_S (S[15:0], Clock, Resetn, 1'b1, S_reg);
	assign LEDG = S[16];

	assign A_C = (sel_AB_CD == 1'b0) ? A : C;
	assign B_D = (sel_AB_CD == 1'b0) ? B : D;
	// drive the display through a 7-seg decoder
	hex7seg digit_7 (A_C[7:4], HEX7);
	hex7seg digit_6 (A_C[3:0], HEX6);

	hex7seg digit_5 (B_D[7:4], HEX5);
	hex7seg digit_4 (B_D[3:0], HEX4);

	hex7seg digit_3 (S_reg[15:12], HEX3);
	hex7seg digit_2 (S_reg[11:8], HEX2);
	hex7seg digit_1 (S_reg[7:4], HEX1);
	hex7seg digit_0 (S_reg[3:0], HEX0);
endmodule
			
module regne (R, Clock, Resetn, E, Q);
	parameter n = 8;
	input [n-1:0] R;
	input Clock, Resetn, E;
	output reg [n-1:0] Q;
	
	always @(posedge Clock or negedge Resetn)
		if (Resetn == 0)
			Q <= {n{1'b0}};
		else if (E)
			Q <= R;
endmodule

module hex7seg (bcd, display);
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
			4'hA: display = 7'b0001000;
			4'hb: display = 7'b1100000;
			4'hC: display = 7'b0110001;
			4'hd: display = 7'b1000010;
			4'hE: display = 7'b0110000;
			4'hF: display = 7'b0111000;
		endcase
endmodule
