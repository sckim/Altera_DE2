-- Implements a circuit that can display five characters on a 7-segment
-- display. 
-- inputs:	SW2-0 selects the letter to display. The characters are:
-- 	SW 2 1 0		Char
-- 	----------------
-- 	   0 0 0  	'H'
-- 		0 0 1		'E'
-- 		0 1 0 	'L'
-- 		0 1 1		'O'
-- 		1 0 0		' ' Blank
-- 		1 0 1		' ' Blank
-- 		1 1 0		' ' Blank
-- 		1 1 1		' ' Blank
--
-- outputs: LEDR2-0 show the states of the switches
-- 			HEX0 displays the selected character
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part4 IS 
	PORT (	SW 	: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);	-- toggle switches
				LEDR	: OUT	STD_LOGIC_VECTOR(2 DOWNTO 0);	-- red LEDs
				HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));		-- 7-seg display
END part4;

ARCHITECTURE Structure OF part4 IS
	SIGNAL C : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
	LEDR <= SW;
	C(2 DOWNTO 0) <= SW(2 DOWNTO 0);
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
	-- the following equations describe display functions in (inverted) 
	-- cannonical SOP form
	HEX0(0) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND C(0)) OR 			-- c(2)'c(1)'c(0) + c(2)'c(1)(c0)
		(NOT(C(2)) AND C(1) AND C(0)) ); 
	HEX0(1) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR		-- c(2)'c(1)'c(0)' + c(2)'c(1)c(0)
		(NOT(C(2)) AND C(1) AND C(0)) ); 
	HEX0(2) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR 
		(NOT(C(2)) AND C(1) AND C(0)) ); 
	HEX0(3) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND C(0)) OR 
		(NOT(C(2)) AND C(1) AND NOT(C(0))) OR
		(NOT(C(2)) AND C(1) AND C(0)) ); 
	HEX0(4) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR 
		(NOT(C(2)) AND NOT(C(1)) AND C(0)) OR 
		(NOT(C(2)) AND C(1) AND NOT(C(0))) OR (NOT(C(2)) AND C(1) AND C(0)) );
	HEX0(5) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR 
		(NOT(C(2)) AND NOT(C(1)) AND C(0)) OR
		(NOT(C(2)) AND C(1) AND NOT(C(0))) OR (NOT(C(2)) AND C(1) AND C(0)) ); 
	HEX0(6) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR
		(NOT(C(2)) AND NOT(C(1)) AND C(0)) );
END Structure;
