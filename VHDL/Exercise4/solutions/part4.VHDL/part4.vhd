-- uses a 1-digit bcd counter enabled at 1Hz
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY part4 IS 
	PORT (	CLOCK_50		: IN	STD_LOGIC;
			HEX0			: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part4;

ARCHITECTURE Behavior OF part4 IS
	COMPONENT bcd7seg
		PORT (	bcd		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
				display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL bcd : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL slow_count : STD_LOGIC_VECTOR(24 DOWNTO 0);
	SIGNAL digit_flipper : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN

	-- Create a 1Hz 4-bit counter
	-- First, a large counter to produce a 1 second (approx) enable 
	-- from the 50 MHz Clock
	PROCESS (CLOCK_50)
	BEGIN
		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			slow_count <= slow_count + '1';
		END IF;
	END PROCESS;

	-- four-bit counter that uses a slow enable for selecting digit
	PROCESS (CLOCK_50)
	BEGIN
		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			IF (slow_count = 0) THEN
				IF (digit_flipper = "1001") THEN
					digit_flipper <= "0000";
	 			ELSE
					digit_flipper <= digit_flipper + '1';
				END IF;
			END IF;
		END IF;
	END PROCESS;
				
	bcd <= digit_flipper;
	-- drive the display through a 7-seg decoder
	digit_0: bcd7seg PORT MAP (bcd, HEX0);
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY bcd7seg IS
	PORT (	bcd		: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				display	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END bcd7seg;

ARCHITECTURE Behavior OF bcd7seg IS
BEGIN
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
	PROCESS (bcd)
	BEGIN
		CASE bcd IS
			WHEN "0000" => display <= "0000001";
			WHEN "0001" => display <= "1001111";
			WHEN "0010" => display <= "0010010";
			WHEN "0011" => display <= "0000110";
			WHEN "0100" => display <= "1001100";
			WHEN "0101" => display <= "0100100";
			WHEN "0110" => display <= "1100000";
			WHEN "0111" => display <= "0001111";
			WHEN "1000" => display <= "0000000";
			WHEN "1001" => display <= "0001100";
			WHEN OTHERS => display <= "1111111";
		END CASE;
	END PROCESS;
END Behavior;
