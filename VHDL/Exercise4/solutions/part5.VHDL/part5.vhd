LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

-- scans the word HELLO across the 7-seg displays. KEY3 causes a reset.
ENTITY part5 IS 
	PORT (	CLOCK_50					: IN	STD_LOGIC;
			KEY							: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
			HEX7, HEX6, HEX5, HEX4, 
				HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part5;

-- KEY[3] is resetn
ARCHITECTURE Behavior OF part5 IS
	COMPONENT hello7seg
		PORT (	char		: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
				display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL seg7_7, seg7_6, seg7_5, seg7_4, seg7_3, seg7_2, seg7_1, seg7_0 : 
				STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL slow_count : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL digit_flipper : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
	-- a large counter to produce a slow enable
	PROCESS (CLOCK_50)
	BEGIN
		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			slow_count <= slow_count + '1';
		END IF;
	END PROCESS;
	-- 3-bit counter that uses a slow enable for selecting digit
	PROCESS (CLOCK_50)
	BEGIN
		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			IF (KEY(3) = '0') THEN
				digit_flipper <= "000";
			ELSIF (slow_count = 0) THEN
				digit_flipper <= digit_flipper + '1';
			END IF;
		END IF;
	END PROCESS;
				
	seg7_7 <= digit_flipper;
	seg7_6 <= digit_flipper + "001";
	seg7_5 <= digit_flipper + "010";
	seg7_4 <= digit_flipper + "011";
	seg7_3 <= digit_flipper + "100";
	seg7_2 <= digit_flipper + "101";
	seg7_1 <= digit_flipper + "110";
	seg7_0 <= digit_flipper + "111";
	
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

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hello7seg IS
	PORT (	char	: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);
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
