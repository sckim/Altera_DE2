// Implements a circuit that can display five characters on a 7-segment
// display. 
// inputs:	SW2-0 selects the letter to display. The characters are:
// 	SW 2 1 0		Char
// 	----------------
// 	   0 0 0  	'H'
// 		0 0 1		'E'
// 		0 1 0 	'L'
// 		0 1 1		'O'
// 		1 0 0		' ' Blank
// 		1 0 1		' ' Blank
// 		1 1 0		' ' Blank
// 		1 1 1		' ' Blank
//
// outputs: LEDR2-0 show the states of the switches
// 			HEX0 displays the selected character
module part4 (SW, LEDR, HEX0);
	input [2:0] SW;				// toggle switches
	output [2:0] LEDR;			// red LEDs
	output [0:6] HEX0;			// 7-seg display

	wire [2:0] C;

	assign LEDR = SW;
	assign C[2:0] = SW[2:0];

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
	// the following equations describe HEX0[0-6] in cannonical SOP form
	assign HEX0[0] = ~((~C[2] & ~C[1] & C[0]) | (~C[2] & C[1] & C[0])); 
	assign HEX0[1] = ~((~C[2] & ~C[1] & ~C[0]) | (~C[2] & C[1] & C[0])); 
	assign HEX0[2] = ~((~C[2] & ~C[1] & ~C[0]) | (~C[2] & C[1] & C[0])); 
	assign HEX0[3] = ~((~C[2] & ~C[1] & C[0]) | (~C[2] & C[1] & ~C[0]) |
		(~C[2] & C[1] & C[0])); 
	assign HEX0[4] = ~((~C[2] & ~C[1] & ~C[0]) | (~C[2] & ~C[1] & C[0]) | 
		(~C[2] & C[1] & ~C[0]) | (~C[2] & C[1] & C[0]));
	assign HEX0[5] = ~((~C[2] & ~C[1] & ~C[0]) | (~C[2] & ~C[1] & C[0]) | 
		(~C[2] & C[1] & ~C[0]) | (~C[2] & C[1] & C[0])); 
	assign HEX0[6] = ~((~C[2] & ~C[1] & ~C[0]) | (~C[2] & ~C[1] & C[0]));
endmodule
