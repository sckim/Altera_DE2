LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

-- scans the word HELLO across the 7-seg displays. KEY(3) causes a reset. 
-- KEY(0) loads the proper counter values
ENTITY part5 IS 
	PORT (	CLOCK_50							: IN	STD_LOGIC;
				KEY								: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				HEX7, HEX6, HEX5, HEX4, 
					HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part5;

ARCHITECTURE Behavior OF part5 IS
	COMPONENT upcount
		PORT (	R								: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);
					Resetn, Clock, L, E		: IN	STD_LOGIC;
					Q								: OUT	STD_LOGIC_VECTOR(2 DOWNTO 0));
	END COMPONENT;
	COMPONENT hello7seg
		PORT (	char		: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
					display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL seg7_7, seg7_6, seg7_5, seg7_4, seg7_3, seg7_2, seg7_1, seg7_0 : 
		STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL slow_count : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL Enable : STD_LOGIC;
BEGIN
	-- a large counter to produce a slow enable
	PROCESS (CLOCK_50)
	BEGIN
		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			slow_count <= slow_count + '1';
		END IF;
	END PROCESS;

	Enable <= '1' WHEN (slow_count = 0) ELSE '0';
	-- upcount (R, Resetn, Clock, L, E, Q)
	up7: upcount PORT MAP ("000", KEY(3), CLOCK_50, NOT KEY(0), Enable, seg7_7);
	up6: upcount PORT MAP ("001", KEY(3), CLOCK_50, NOT KEY(0), Enable, seg7_6);
	up5: upcount PORT MAP ("010", KEY(3), CLOCK_50, NOT KEY(0), Enable, seg7_5);
	up4: upcount PORT MAP ("011", KEY(3), CLOCK_50, NOT KEY(0), Enable, seg7_4);
	up3: upcount PORT MAP ("100", KEY(3), CLOCK_50, NOT KEY(0), Enable, seg7_3);
	up2: upcount PORT MAP ("101", KEY(3), CLOCK_50, NOT KEY(0), Enable, seg7_2);
	up1: upcount PORT MAP ("110", KEY(3), CLOCK_50, NOT KEY(0), Enable, seg7_1);
	up0: upcount PORT MAP ("111", KEY(3), CLOCK_50, NOT KEY(0), Enable, seg7_0);
	
	-- drive the display through a 7-seg decoder designed specifically for letters
	-- 'h' 'e' 'l' 'o' and ' '
	digit_7: hello7seg PORT MAP (seg7_7, HEX7);
	digit_6: hello7seg PORT MAP (seg7_6, HEX6);
	digit_5: hello7seg PORT MAP (seg7_5, HEX5);
	digit_4: hello7seg PORT MAP (seg7_4, HEX4);
	digit_3: hello7seg PORT MAP (seg7_3, HEX3);
	digit_2: hello7seg PORT MAP (seg7_2, HEX2);
	digit_1: hello7seg PORT MAP (seg7_1, HEX1);
	digit_0: hello7seg PORT MAP (seg7_0, HEX0);
END Behavior;

-- three-bit counter with parallel load and enable
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

-- scans the word HELLO across the 7-seg displays. KEY(3) causes a reset.
ENTITY upcount IS 
	PORT (	R								: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);
				Resetn, Clock, L, E		: IN	STD_LOGIC;
				Q								: OUT	STD_LOGIC_VECTOR(2 DOWNTO 0));
END upcount;

ARCHITECTURE Behavior OF upcount IS
	SIGNAL Count : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN
				Count <= "000";
			ELSIF (L = '1') THEN
				Count <= R;
			ELSIF (E = '1') THEN
				Count <= Count + '1';
			END IF;
		END IF;
	END PROCESS;
	Q <= Count;
END Behavior;
				
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hello7seg IS
	PORT (	char		: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);
				display	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END hello7seg;

ARCHITECTURE Behavior OF hello7seg IS
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
	PROCESS (char)
	BEGIN
		CASE char IS
			WHEN "000" => display <= "1001000";		-- 'H'
			WHEN "001" => display <= "0110000";		-- 'E'
			WHEN "010" => display <= "1110001";		-- 'L'
			WHEN "011" => display <= "1110001";		-- 'L'
			WHEN "100" => display <= "0000001";		-- 'O'
			WHEN "101" => display <= "1111111";		-- ' '
			WHEN "110" => display <= "1111111";		-- ' '
			WHEN OTHERS => display <= "1111111";	-- ' '
		END CASE;
	END PROCESS;
END Behavior;
