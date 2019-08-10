LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

-- input six bits using SW toggle switches, and convert to decimal (2-digit bcd)
ENTITY part7 IS 
	PORT (	SW								: IN	STD_LOGIC_VECTOR(5 DOWNTO 0);
				HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));  -- 7-segs
END part7;

ARCHITECTURE Behavior OF part7 IS
	COMPONENT bcd7seg
		PORT (	bcd		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
					display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;

	SIGNAL bcd_h, bcd_l : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL bin6 : STD_LOGIC_VECTOR(5 DOWNTO 0);
BEGIN
	bin6 <= SW;

	-- Check various ranges and set bcd digits. Note that we work with
	-- bin6(3 DOWNTO 0) just to prevent compiler warnings about bit size
	-- truncation. This is not really necessary
	PROCESS (bin6)
	BEGIN
		IF (bin6 < "001010") THEN
			bcd_h <= "0000";
			bcd_l <= bin6(3 DOWNTO 0);
		ELSIF (bin6 < "010100") THEN
			bcd_h <= "0001";
			bcd_l <= bin6(3 DOWNTO 0) + "0110";	-- -10 = -(00001010) = 11110110; add 6
		ELSIF (bin6 < "011110") THEN
			bcd_h <= "0010";
			bcd_l <= bin6(3 DOWNTO 0) + "1100";	-- -20 = -(00010100) = 11101100; add 12
		ELSIF (bin6 < "101000") THEN
			bcd_h <= "0011";
			bcd_l <= bin6(3 DOWNTO 0) + "0010";	-- -30 = -(00011110) = 11100010; add 2
		ELSIF (bin6 < "110010") THEN
			bcd_h <= "0100";
			bcd_l <= bin6(3 DOWNTO 0) + "1000";	-- -40 = -(00101000) = 11011000; add 8 
		ELSIF (bin6 < "111100") THEN
			bcd_h <= "0101";
			bcd_l <= bin6(3 DOWNTO 0) + "1110";	-- -50 = -(00110010) = 11001110; add 14 
		ELSE
			bcd_h <= "0110";
			bcd_l <= bin6(3 DOWNTO 0) + "0100";	-- -60 = -(00111100) = 11000100; add 4 
		END IF;
	END PROCESS;

	-- drive the displays
	digit1: bcd7seg PORT MAP (bcd_h, HEX1);
	digit0: bcd7seg PORT MAP (bcd_l, HEX0);

	-- blank the adjacent displays
	digit3: bcd7seg PORT MAP ("1111", HEX3);
	digit2: bcd7seg PORT MAP ("1111", HEX2);
	
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
