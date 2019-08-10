// Implements a circuit that can display different 5-letter words on the eight 
// 7-segment displays. The character selected for each display is chosen by
// a multiplexer, and these multiplexers are connected to the characters
// in a way that allows a word to be scrolled across the displays from
// right-to-left as the multiplexer select lines are changed through the
// sequence 000, 001, ..., 111, 000, 001, etc. Using the four characters H,
// E, L, O, -, where - means "blank". the displays can scroll any 5-letter word using 
// these letters, such as "HELLO---", as follows:
//
// SW 17 16 15		Displayed characters
//     0  0  0    ---HELLO
//     0  0  1    --HELLO-
//     0  1  0    -HELLO--
//     0  1  1    HELLO---
//     1  0  0    ELLO---H
//     1  0  1    LLO---HE
//     1  1  0    LO---HEL
//     1  1  1    O---HELL
//
// inputs: SW17-15 provide the multiplexer select lines
//         SW14-0 provide five different codes used to select characters
// outputs: LEDR shows the states of the switches
//          HEX7 - HEX0 displays the characters
module part6 (SW, LEDR, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input [17:0] SW;				// toggle switches
	output [17:0] LEDR;			// red LEDs
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;	// 7-seg displays

	assign LEDR = SW;

	wire [2:0] Ch_Sel, Ch1, Ch2, Ch3, Ch4, Ch5, Blank;
	wire [2:0] H7_Ch, H6_Ch, H5_Ch, H4_Ch, H3_Ch, H2_Ch, H1_Ch, H0_Ch;
	assign Ch_Sel = SW[17:15];
	assign Ch1 = SW[14:12];
	assign Ch2 = SW[11:9];
	assign Ch3 = SW[8:6];
	assign Ch4 = SW[5:3];
	assign Ch5 = SW[2:0];
	assign Blank = 3'b111;	// used to blank a 7-seg display (see module char_7seg)

	// instantiate module mux_3bit_8to1 (S, G1, G2, G3, G4, G5, G6, G7, G8, M) to
	// create the multiplexer for each hex display
	mux_3bit_8to1 M7 (Ch_Sel, Blank, Blank, Blank, Ch1, Ch2, Ch3, Ch4, Ch5, H7_Ch);
	mux_3bit_8to1 M6 (Ch_Sel, Blank, Blank, Ch1, Ch2, Ch3, Ch4, Ch5, Blank, H6_Ch);
	mux_3bit_8to1 M5 (Ch_Sel, Blank, Ch1, Ch2, Ch3, Ch4, Ch5, Blank, Blank, H5_Ch);
	mux_3bit_8to1 M4 (Ch_Sel, Ch1, Ch2, Ch3, Ch4, Ch5, Blank, Blank, Blank, H4_Ch);
	mux_3bit_8to1 M3 (Ch_Sel, Ch2, Ch3, Ch4, Ch5, Blank, Blank, Blank, Ch1, H3_Ch);
	mux_3bit_8to1 M2 (Ch_Sel, Ch3, Ch4, Ch5, Blank, Blank, Blank, Ch1, Ch2, H2_Ch);
	mux_3bit_8to1 M1 (Ch_Sel, Ch4, Ch5, Blank, Blank, Blank, Ch1, Ch2, Ch3, H1_Ch);
	mux_3bit_8to1 M0 (Ch_Sel, Ch5, Blank, Blank, Blank, Ch1, Ch2, Ch3, Ch4, H0_Ch);

	// iinstantiate module char_7seg (C, Display) to drive the hex displays
	char_7seg H7 (H7_Ch, HEX7);
	char_7seg H6 (H6_Ch, HEX6);
	char_7seg H5 (H5_Ch, HEX5);
	char_7seg H4 (H4_Ch, HEX4);
	char_7seg H3 (H3_Ch, HEX3);
	char_7seg H2 (H2_Ch, HEX2);
	char_7seg H1 (H1_Ch, HEX1);
	char_7seg H0 (H0_Ch, HEX0);
endmodule

// implements a 3-bit wide 8-to-1 multiplexer
module mux_3bit_8to1 (S, G1, G2, G3, G4, G5, G6, G7, G8, M);
	input [2:0] S, G1, G2, G3, G4, G5, G6, G7, G8;
	output [2:0] M;
	wire [1:6] m_0, m_1, m_2;	// intermediate multiplexers

	// 8-to-1 multiplexer for bit 0
	assign m_0[1] = (~S[0] & G1[0]) | (S[0] & G2[0]);
	assign m_0[2] = (~S[0] & G3[0]) | (S[0] & G4[0]);
	assign m_0[3] = (~S[0] & G5[0]) | (S[0] & G6[0]);
	assign m_0[4] = (~S[0] & G7[0]) | (S[0] & G8[0]);
	assign m_0[5] = (~S[1] & m_0[1]) | (S[1] & m_0[2]);
	assign m_0[6] = (~S[1] & m_0[3]) | (S[1] & m_0[4]);
	assign M[0] = (~S[2] & m_0[5]) | (S[2] & m_0[6]);

	// 8-to-1 multiplexer for bit 1
	assign m_1[1] = (~S[0] & G1[1]) | (S[0] & G2[1]);
	assign m_1[2] = (~S[0] & G3[1]) | (S[0] & G4[1]);
	assign m_1[3] = (~S[0] & G5[1]) | (S[0] & G6[1]);
	assign m_1[4] = (~S[0] & G7[1]) | (S[0] & G8[1]);
	assign m_1[5] = (~S[1] & m_1[1]) | (S[1] & m_1[2]);
	assign m_1[6] = (~S[1] & m_1[3]) | (S[1] & m_1[4]);
	assign M[1] = (~S[2] & m_1[5]) | (S[2] & m_1[6]);
	
	// 8-to-1 multiplexer for bit 2
	assign m_2[1] = (~S[0] & G1[2]) | (S[0] & G2[2]);
	assign m_2[2] = (~S[0] & G3[2]) | (S[0] & G4[2]);
	assign m_2[3] = (~S[0] & G5[2]) | (S[0] & G6[2]);
	assign m_2[4] = (~S[0] & G7[2]) | (S[0] & G8[2]);
	assign m_2[5] = (~S[1] & m_2[1]) | (S[1] & m_2[2]);
	assign m_2[6] = (~S[1] & m_2[3]) | (S[1] & m_2[4]);
	assign M[2] = (~S[2] & m_2[5]) | (S[2] & m_2[6]);
endmodule	

// Converts 3-bit input code on C2-0 into 7-bit code that produces
// a character on a 7-segment display. The conversion is defined by:
// 	 C 2 1 0		Char
// 	----------------
// 	   0 0 0  	'H'
// 		0 0 1		'E'
// 		0 1 0 	'L'
// 		0 1 1		'O'
// 		1 0 0    ' ' Blank
// 		1 0 1    ' ' Blank
// 		1 1 0    ' ' Blank
// 		1 1 1		' ' Blank
//
//    Codes 100, 101, 110 are not used
//
module char_7seg (C, Display);
	input [2:0] C;				// input code
	output [0:6] Display;			// output 7-seg code

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
	// the following equations describe display functions in cannonical SOP form
	assign Display[0] = ~((~C[2] & ~C[1] & C[0]) | (~C[2] & C[1] & C[0])); 
	assign Display[1] = ~((~C[2] & ~C[1] & ~C[0]) | (~C[2] & C[1] & C[0])); 
	assign Display[2] = ~((~C[2] & ~C[1] & ~C[0]) | (~C[2] & C[1] & C[0])); 
	assign Display[3] = ~((~C[2] & ~C[1] & C[0]) | (~C[2] & C[1] & ~C[0]) |
		(~C[2] & C[1] & C[0])); 
	assign Display[4] = ~((~C[2] & ~C[1] & ~C[0]) | (~C[2] & ~C[1] & C[0]) | 
		(~C[2] & C[1] & ~C[0]) | (~C[2] & C[1] & C[0]));
	assign Display[5] = ~((~C[2] & ~C[1] & ~C[0]) | (~C[2] & ~C[1] & C[0]) | 
		(~C[2] & C[1] & ~C[0]) | (~C[2] & C[1] & C[0])); 
	assign Display[6] = ~((~C[2] & ~C[1] & ~C[0]) | (~C[2] & ~C[1] & C[0]));
endmodule

