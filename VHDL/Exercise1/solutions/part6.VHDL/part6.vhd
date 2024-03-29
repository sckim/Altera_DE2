-- Implements a circuit that can display different 5-letter words on the eight 
-- 7-segment displays. The character selected for each display is chosen by
-- a multiplexer, and these multiplexers are connected to the characters
-- in a way that allows a word to be scrolled across the displays from
-- right-to-left as the multiplexer select lines are changed through the
-- sequence 000, 001, ..., 111, 000, 001, etc. Using the four characters H,
-- E, L, O, -, where - means "blank". the displays can scroll any 5-letter word using 
-- these letters, such as "HELLO---", as follows:
--
-- SW 17 16 15		Displayed characters
--     0  0  0    ---HELLO
--     0  0  1    --HELLO-
--     0  1  0    -HELLO--
--     0  1  1    HELLO---
--     1  0  0    ELLO---H
--     1  0  1    LLO---HE
--     1  1  0    LO---HEL
--     1  1  1    O---HELL
--
-- inputs: SW17-15 provide the multiplexer select lines
--         SW14-0 provide five different codes used to select characters
-- outputs: LEDR shows the states of the switches
--          HEX7 - HEX0 displays the characters
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part6 IS 
	PORT (	SW 							: IN	STD_LOGIC_VECTOR(17 DOWNTO 0);
				LEDR							: OUT	STD_LOGIC_VECTOR(17 DOWNTO 0);
				HEX7, HEX6, HEX5, HEX4	: OUT	STD_LOGIC_VECTOR(0 TO 6);
				HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part6;

ARCHITECTURE Structure OF part6 IS
	COMPONENT mux_3bit_8to1
		PORT (	S, G1, G2, G3, G4, G5, G6, G7, G8 	: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);
					M												: OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
	END COMPONENT;
	COMPONENT char_7seg
		PORT (	C			: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
					Display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL Ch_Sel, Ch1, Ch2, Ch3, Ch4, Ch5, Blank :	STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL H7_Ch, H6_Ch, H5_Ch, H4_Ch : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL H3_Ch, H2_Ch, H1_Ch, H0_Ch : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
	LEDR <= SW;

	Ch_Sel <= SW(17 DOWNTO 15);
	Ch1 <= SW(14 DOWNTO 12);
	Ch2 <= SW(11 DOWNTO 9);
	Ch3 <= SW(8 DOWNTO 6);
	Ch4 <= SW(5 DOWNTO 3);
	Ch5 <= SW(2 DOWNTO 0);
	Blank <= "111";	-- used to blank a 7-seg display (see module char_7seg)

	-- instantiate module mux_3bit_8to1 (S, G1, G2, G3, G4, G5, G6, G7, G8, M) to
	-- create the multiplexer for each hex display
	M7: mux_3bit_8to1 PORT MAP (Ch_Sel, Blank, Blank, Blank, Ch1, Ch2, Ch3, 
		Ch4, Ch5, H7_Ch);
	M6: mux_3bit_8to1 PORT MAP (Ch_Sel, Blank, Blank, Ch1, Ch2, Ch3, Ch4, 
		Ch5, Blank, H6_Ch);
	M5: mux_3bit_8to1 PORT MAP (Ch_Sel, Blank, Ch1, Ch2, Ch3, Ch4, Ch5, 
		Blank, Blank, H5_Ch);
	M4: mux_3bit_8to1 PORT MAP (Ch_Sel, Ch1, Ch2, Ch3, Ch4, Ch5, Blank, 
		Blank, Blank, H4_Ch);
	M3: mux_3bit_8to1 PORT MAP (Ch_Sel, Ch2, Ch3, Ch4, Ch5, Blank, Blank, 
		Blank, Ch1, H3_Ch);
	M2: mux_3bit_8to1 PORT MAP (Ch_Sel, Ch3, Ch4, Ch5, Blank, Blank, Blank, 
		Ch1, Ch2, H2_Ch);
	M1: mux_3bit_8to1 PORT MAP (Ch_Sel, Ch4, Ch5, Blank, Blank, Blank, Ch1, 
		Ch2, Ch3, H1_Ch);
	M0: mux_3bit_8to1 PORT MAP (Ch_Sel, Ch5, Blank, Blank, Blank, Ch1, Ch2, 
		Ch3, Ch4, H0_Ch);

	-- instantiate module char_7seg (C, Display) to drive the hex displays
	H7: char_7seg PORT MAP (H7_Ch, HEX7);
	H6: char_7seg PORT MAP (H6_Ch, HEX6);
	H5: char_7seg PORT MAP (H5_Ch, HEX5);
	H4: char_7seg PORT MAP (H4_Ch, HEX4);
	H3: char_7seg PORT MAP (H3_Ch, HEX3);
	H2: char_7seg PORT MAP (H2_Ch, HEX2);
	H1: char_7seg PORT MAP (H1_Ch, HEX1);
	H0: char_7seg PORT MAP (H0_Ch, HEX0);
END Structure;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- implements a 3-bit wide 8-to-1 multiplexer
ENTITY mux_3bit_8to1 IS
	PORT (	S, G1, G2, G3, G4, G5, G6, G7, G8	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
				M												: OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END mux_3bit_8to1;

ARCHITECTURE Behavior OF mux_3bit_8to1 IS
	SIGNAL m_0, m_1, m_2 : STD_LOGIC_VECTOR(1 TO 6); -- intermediate multiplexers
BEGIN
	-- 8-to-1 multiplexer for bit 0
	m_0(1) <= (NOT(S(0)) AND G1(0)) OR (S(0) AND G2(0));
	m_0(2) <= (NOT(S(0)) AND G3(0)) OR (S(0) AND G4(0));
	m_0(3) <= (NOT(S(0)) AND G5(0)) OR (S(0) AND G6(0));
	m_0(4) <= (NOT(S(0)) AND G7(0)) OR (S(0) AND G8(0));
	m_0(5) <= (NOT(S(1)) AND m_0(1)) OR (S(1) AND m_0(2));
	m_0(6) <= (NOT(S(1)) AND m_0(3)) OR (S(1) AND m_0(4));
	M(0) <= (NOT(S(2)) AND m_0(5)) OR (S(2) AND m_0(6));

	-- 8-to-1 multiplexer for bit 1
	m_1(1) <= (NOT(S(0)) AND G1(1)) OR (S(0) AND G2(1));
	m_1(2) <= (NOT(S(0)) AND G3(1)) OR (S(0) AND G4(1));
	m_1(3) <= (NOT(S(0)) AND G5(1)) OR (S(0) AND G6(1));
	m_1(4) <= (NOT(S(0)) AND G7(1)) OR (S(0) AND G8(1));
	m_1(5) <= (NOT(S(1)) AND m_1(1)) OR (S(1) AND m_1(2));
	m_1(6) <= (NOT(S(1)) AND m_1(3)) OR (S(1) AND m_1(4));
	M(1) <= (NOT(S(2)) AND m_1(5)) OR (S(2) AND m_1(6));

	-- 8-to-1 multiplexer for bit 2
	m_2(1) <= (NOT(S(0)) AND G1(2)) OR (S(0) AND G2(2));
	m_2(2) <= (NOT(S(0)) AND G3(2)) OR (S(0) AND G4(2));
	m_2(3) <= (NOT(S(0)) AND G5(2)) OR (S(0) AND G6(2));
	m_2(4) <= (NOT(S(0)) AND G7(2)) OR (S(0) AND G8(2));
	m_2(5) <= (NOT(S(1)) AND m_2(1)) OR (S(1) AND m_2(2));
	m_2(6) <= (NOT(S(1)) AND m_2(3)) OR (S(1) AND m_2(4));
	M(2) <= (NOT(S(2)) AND m_2(5)) OR (S(2) AND m_2(6));
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Converts 3-bit input code on C2-0 into 7-bit code that produces
-- a character on a 7-segment display. The conversion is defined by:
-- 	 C 2 1 0		Char
-- 	----------------
-- 	   0 0 0  	'H'
-- 		0 0 1		'E'
-- 		0 1 0 	'L'
-- 		0 1 1		'O'
-- 		1 0 0    ' ' Blank
-- 		1 0 1    ' ' Blank
-- 		1 1 0    ' ' Blank
-- 		1 1 1		' ' Blank
--
--    Codes 100, 101, 110 are not used
--
ENTITY char_7seg IS
	PORT (	C			: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
				Display	: OUT STD_LOGIC_VECTOR(0 TO 6));
END char_7seg;
	--
	--       0  
	--      ---  
	--     |   |
	--    5|   |1
	--     | 6 |
	--      ---  
	--     |   |
	--    4|   |2
	--     |   |
	--      ---  
	--       3  
	--
ARCHITECTURE Behavior OF char_7seg IS
BEGIN
	-- the following equations describe display functions in (inverted) cannonical SOP form
	Display(0) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND C(0)) OR 
		(NOT(C(2)) AND C(1) AND C(0)) ); 
	Display(1) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR 
		(NOT(C(2)) AND C(1) AND C(0)) ); 
	Display(2) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR 
		(NOT(C(2)) AND C(1) AND C(0)) ); 
	Display(3) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND C(0)) OR 
		(NOT(C(2)) AND C(1) AND NOT(C(0))) OR
		(NOT(C(2)) AND C(1) AND C(0)) ); 
	Display(4) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR 
		(NOT(C(2)) AND NOT(C(1)) AND C(0)) OR 
		(NOT(C(2)) AND C(1) AND NOT(C(0))) OR (NOT(C(2)) AND C(1) AND C(0)) );
	Display(5) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR 
		(NOT(C(2)) AND NOT(C(1)) AND C(0)) OR
		(NOT(C(2)) AND C(1) AND NOT(C(0))) OR (NOT(C(2)) AND C(1) AND C(0)) ); 
	Display(6) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR
		(NOT(C(2)) AND NOT(C(1)) AND C(0)) );
END Behavior;
