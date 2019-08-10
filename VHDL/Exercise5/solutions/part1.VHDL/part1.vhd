LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

-- A 3-digit BCD counter.
ENTITY part1 IS 
	PORT (	CLOCK_50							: IN	STD_LOGIC;
				KEY								: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				HEX3, HEX2, HEX1, HEX0		: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part1;

ARCHITECTURE Behavior OF part1 IS
	COMPONENT bcd7seg
		PORT (	bcd		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
					display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL slow_count : STD_LOGIC_VECTOR(24 DOWNTO 0);
	SIGNAL bcd_0, bcd_1, bcd_2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
	-- Create a 1Hz 4-bit counter
	-- First, a large counter to produce a 1 second (approx) enable
	PROCESS (CLOCK_50)
	BEGIN
		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			slow_count <= slow_count + '1';
		END IF;
	END PROCESS;

	-- 3-digit BCD counter that uses a slow enable 
	PROCESS (CLOCK_50)
	BEGIN	
		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			IF (KEY(3) = '0') THEN
				bcd_0 <= "0000";
				bcd_1 <= "0000";
				bcd_2 <= "0000";
			ELSIF (slow_count = 0) THEN
				IF (bcd_0 = "1001") THEN
					bcd_0 <= "0000";
	 				IF (bcd_1 = "1001") THEN
						bcd_1 <= "0000";
						IF (bcd_2 = "1001") THEN
							bcd_2 <= "0000";
						ELSE
							bcd_2 <= bcd_2 + '1';
			 			END IF;
					ELSE
						bcd_1 <= bcd_1 + '1';
					END IF;
				ELSE
					bcd_0 <= bcd_0 + '1';
				END IF;
	 		END IF;
	 	END IF;
	END PROCESS;
				
	-- drive the displays
	digit2: bcd7seg PORT MAP (bcd_2, HEX2);
	digit1: bcd7seg PORT MAP (bcd_1, HEX1);
	digit0: bcd7seg PORT MAP (bcd_0, HEX0);
	-- blank the adjacent display
	digit3: bcd7seg PORT MAP ("1111", HEX3);
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
