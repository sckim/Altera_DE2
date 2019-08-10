-- KEY(0) is the reset input, and KEY(1) is the clock. SW15-0 are the instructions,
-- and SW(17) is the Run input. The processor bus appears on LEDR15-0 and
-- Done appears on LEDR17
-- This code instantiates a 32 x 8 memory n the Cyclone II FPGA on the DE2 board.
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part1 IS 
PORT (	KEY 				: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
			SW 				: IN	STD_LOGIC_VECTOR(17 DOWNTO 0);
			LEDR				: OUT	STD_LOGIC_VECTOR(17 DOWNTO 0));
END part1;

ARCHITECTURE Behavior OF part1 IS
	COMPONENT proc
		PORT (	DIN 						: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
					Resetn, Clock, Run	: IN	STD_LOGIC;
					Done						: BUFFER	STD_LOGIC;
					BusWires					: BUFFER	STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;
	SIGNAL Manual_Clock, Resetn, Run, Done : STD_LOGIC;
	SIGNAL DIN, BusWires : STD_LOGIC_VECTOR(15 DOWNTO 0); 
BEGIN
	Resetn <= KEY(0);
	Manual_Clock <= KEY(1);	
		-- Note: can't use name Clock because this is defined as
		-- the 50 MHz Clock coming into the FPGA from the board
	DIN <= SW(15 DOWNTO 0);
	Run <= SW(17);

	-- proc(DIN, Resetn, Clock, Run, Done, BusWires);
	U1: proc PORT MAP (DIN, Resetn, Manual_Clock, Run, Done, BusWires);

	LEDR(15 DOWNTO 0) <= BusWires;
	LEDR(16) <= '0';
	LEDR(17) <= Done;
END Behavior;
