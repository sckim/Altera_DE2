-- Implements eight 2-to-1 multiplexers.
-- inputs:	SW7-0 represent the 8-bit input X, and SW15-8 represent Y
-- 			SW17 selects either X or Y to drive the output LEDs
-- outputs: LEDR17-0 show the states of the switches
-- 			LEDG7-0 shows the outputs of the multiplexers
LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Simple module that connects the SW switches to the LEDR lights
ENTITY part2 IS 
	PORT (	SW		: IN	STD_LOGIC_VECTOR(17 DOWNTO 0);
			LEDR	: OUT	STD_LOGIC_VECTOR(17 DOWNTO 0);  -- red LEDs
			LEDG	: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0));  -- green LEDs
END part2;

ARCHITECTURE Structure OF part2 IS
	SIGNAL Sel : STD_LOGIC;
	SIGNAL X, Y, M : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	LEDR <= SW;
	X <= SW(7 DOWNTO 0);
	Y <= SW(15 DOWNTO 8);
	Sel <= SW(17);

	M(0) <= (NOT(Sel) AND X(0)) OR (Sel AND Y(0));
	M(1) <= (NOT(Sel) AND X(1)) OR (Sel AND Y(1));
	M(2) <= (NOT(Sel) AND X(2)) OR (Sel AND Y(2));
	M(3) <= (NOT(Sel) AND X(3)) OR (Sel AND Y(3));
	M(4) <= (NOT(Sel) AND X(4)) OR (Sel AND Y(4));
	M(5) <= (NOT(Sel) AND X(5)) OR (Sel AND Y(5));
	M(6) <= (NOT(Sel) AND X(6)) OR (Sel AND Y(6));
	M(7) <= (NOT(Sel) AND X(7)) OR (Sel AND Y(7));
	LEDG(7 DOWNTO 0) <= M;
END Structure;
