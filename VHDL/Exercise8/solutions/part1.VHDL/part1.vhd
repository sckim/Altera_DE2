LIBRARY ieee;
USE ieee.std_logic_1164.all;
-- LPM RAM module
-- inputs: 
-- 	Clock
--		Address
--		Write: asserted to perform a write
--		DataIn: data to be written
--
-- outputs:
--		DataOut: data read
ENTITY part1 IS 
	PORT (	Clock, Write		: IN	STD_LOGIC;
				DataIn				: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
				Address				: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
				DataOut				: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0));
END part1;

ARCHITECTURE Behavior OF part1 IS
	COMPONENT ramlpm 
		PORT ( 	address	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
					clock		: IN STD_LOGIC ;
					data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					wren		: IN STD_LOGIC  := '1';
					q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
	END COMPONENT;
BEGIN
	-- instantiate LPM module
	-- module ramlpm (address, clock, data, wren, q)
	m32x8: ramlpm PORT MAP (Address, Clock, DataIn, Write, DataOut);
END Behavior;
