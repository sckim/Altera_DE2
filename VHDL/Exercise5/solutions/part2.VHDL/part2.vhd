LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

-- Real time settable clock. Set SW(15 DOWNTO 8) switches to 2-digit BCD number
-- representing hours. Set SW(7 DOWNTO 0) to 2-digit number representing minutes.
-- Load initial time by pressing KEY(3).
ENTITY part2 IS 
	PORT (	CLOCK_50						: IN	STD_LOGIC;
			SW 								: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
			KEY								: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
			HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, 
			HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part2;

ARCHITECTURE Behavior OF part2 IS
	COMPONENT modulo 
	PORT (	R, M					: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
			Clock, Resetn, L, E		: IN	STD_LOGIC;
			Q						: OUT	STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;
	COMPONENT bcd7seg
		PORT (	bcd		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
				display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;

	SIGNAL slow_count : STD_LOGIC_VECTOR(24 DOWNTO 0);
	SIGNAL hr_1, hr_0, min_1, min_0, sec_1, sec_0 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL mod_hr_0 : STD_LOGIC_VECTOR(3 DOWNTO 0); -- used to change hour (LSB) from
																	-- 19 to 20 or 23 to 00
	SIGNAL E_sec_0, E_sec_1, E_min_0, E_min_1, E_hr_0, E_hr_1 : STD_LOGIC;
BEGIN
	-- Create a 1Hz 4-bit counter
	-- First, a large counter to produce a 1 second (approx) enable
	PROCESS (CLOCK_50)
	BEGIN
		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			slow_count <= slow_count + '1';
		END IF;
	END PROCESS;

	-- 6-digit clock display
	-- modulo (R, M, CLOCK_50, Resetn, L, E, Q)
	E_sec_0 <= '1' WHEN (slow_count = 0) ELSE '0';
	seconds_0: modulo PORT MAP ("0000", "1001", CLOCK_50, KEY(3), '0', E_sec_0, sec_0);

	E_sec_1 <= '1' WHEN (sec_0 = 9) AND (E_sec_0 = '1') ELSE '0';
	seconds_1: modulo PORT MAP ("0000", "0101", CLOCK_50, KEY(3), '0', E_sec_1, sec_1);

	E_min_0 <= '1' WHEN (sec_1 = 5) AND (E_sec_1 = '1') ELSE '0';
	minutes_0: modulo PORT MAP (SW(3 DOWNTO 0), "1001", CLOCK_50, KEY(3), NOT KEY(0), 
		E_min_0, min_0);
	E_min_1 <= '1' WHEN (min_0 = 9) AND (E_min_0 = '1') ELSE '0';
	minutes_1: modulo PORT MAP (SW(7 DOWNTO 4), "0101", CLOCK_50, KEY(3), NOT KEY(0), 
		E_min_1, min_1);

	E_hr_0 <= '1' WHEN (min_1 = 5) AND (E_min_1 = '1') ELSE '0';
	mod_hr_0 <= "0011" WHEN (hr_1 = 2) ELSE "1001";
	hour_0: modulo PORT MAP (SW(11 DOWNTO 8), mod_hr_0, CLOCK_50, KEY(3), NOT KEY(0), 
		E_hr_0, hr_0);
	E_hr_1 <= '1' WHEN ( ((hr_1 = 2) AND (hr_0 = 3)) OR (hr_0 = 9) ) AND (E_hr_0 = '1')
		ELSE '0'; 
	hour_1: modulo PORT MAP (SW(15 DOWNTO 12), "0010", CLOCK_50, KEY(3), NOT KEY(0), 
		E_hr_1, hr_1);
				
	-- drive the displays
	digit7: bcd7seg PORT MAP (hr_1, HEX7);
	digit6: bcd7seg PORT MAP (hr_0, HEX6);
	digit5: bcd7seg PORT MAP (min_1, HEX5);
	digit4: bcd7seg PORT MAP (min_0, HEX4);
	digit3: bcd7seg PORT MAP (sec_1, HEX3);
	digit2: bcd7seg PORT MAP (sec_0, HEX2);
	-- blank the adjacent display
	digit1: bcd7seg PORT MAP ("1111", HEX1);
	digit0: bcd7seg PORT MAP ("1111", HEX0);
	
END Behavior;
			
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY modulo IS 
	PORT (	R, M					: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
			Clock, Resetn, L, E		: IN	STD_LOGIC;
			Q						: OUT	STD_LOGIC_VECTOR(3 DOWNTO 0));
END modulo;

ARCHITECTURE Behavior OF modulo IS
	SIGNAL Count : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN
				Count <= "0000";
			ELSIF (L = '1') THEN
				Count <= R;
			ELSIF (E = '1') THEN
				IF (Count = M) THEN
					Count <= "0000";
				ELSE
					Count <= Count + '1';
				END IF;
			END IF;
		END IF;
	END PROCESS;
	Q <= Count;
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
