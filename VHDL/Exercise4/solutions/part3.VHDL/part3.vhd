LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
--
-- inputs:
-- KEY0: manual clock
-- SW0: active low reset
-- SW1: enable signal for the counter
--
-- outputs:
--	HEX0 - HEX3: hex segment displays
ENTITY part3 IS 
	PORT (	SW 								: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
				KEY								: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
				HEX3, HEX2, HEX1, HEX0		: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part3;

ARCHITECTURE Behavior OF part3 IS
	COMPONENT lpm_count
		PORT (	clock		: IN STD_LOGIC ;
				cnt_en	: IN STD_LOGIC ;
				sclr		: IN STD_LOGIC ;
				q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
	END COMPONENT;
	COMPONENT hex7seg
		PORT (	hex		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
				display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL Clock, Resetn, Enable : STD_LOGIC;
	SIGNAL Count : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	-- 16-bit counter based on T-flip flops
	Clock <= KEY(0);
	Resetn <= SW(0);
	Enable <= SW(1);
	
	-- 16-bit counter 
	-- lpm_count (clock, cnt_en, sclr, q)
	U1: lpm_count PORT MAP (Clock, Enable, NOT Resetn, Count);

	-- drive the displays
	digit3: hex7seg PORT MAP (Count(15 DOWNTO 12), HEX3);
	digit2: hex7seg PORT MAP (Count(11 DOWNTO 8), HEX2);
	digit1: hex7seg PORT MAP (Count(7 DOWNTO 4), HEX1);
	digit0: hex7seg PORT MAP (Count(3 DOWNTO 0), HEX0);
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hex7seg IS
	PORT (	hex		: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				display	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END hex7seg;

ARCHITECTURE Behavior OF hex7seg IS
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
	PROCESS (hex)
	BEGIN
		CASE hex IS
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
			WHEN "1010" => display <= "0001000";
			WHEN "1011" => display <= "1100000";
			WHEN "1100" => display <= "0110001";
			WHEN "1101" => display <= "1000010";
			WHEN "1110" => display <= "0110000";
			WHEN OTHERS => display <= "0111000";
		END CASE;
	END PROCESS;
END Behavior;

