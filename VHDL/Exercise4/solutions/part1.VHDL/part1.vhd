LIBRARY ieee;
USE ieee.std_logic_1164.all;
--
-- inputs:
-- KEY0: manual clock
-- SW0: active low reset
-- SW1: enable signal for the counter
--
-- outputs:
--	HEX0 - HEX3: hex segment displays
ENTITY part1 IS 
	PORT (	SW 							: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
			KEY							: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
			HEX3, HEX2, HEX1, HEX0		: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part1;

ARCHITECTURE Behavior OF part1 IS
	COMPONENT ToggleFF 
		PORT (	T, Clock, Resetn		: IN	STD_LOGIC;
				Q							: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT hex7seg
		PORT (	hex		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
					display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL Clock, Resetn : STD_LOGIC;
	SIGNAL Count, Enable : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	-- 16-bit counter based on T-flip flops
	Clock <= KEY(0);
	Resetn <= SW(0);

	Enable(0) <= SW(1);
	TFF0: ToggleFF PORT MAP (Enable(0), Clock, Resetn, Count(0));
	Enable(1) <= Count(0) AND Enable(0);
	TFF1: ToggleFF PORT MAP (Enable(1), Clock, Resetn, Count(1));
	Enable(2) <= Count(1) AND Enable(1);
	TFF2: ToggleFF PORT MAP (Enable(2), Clock, Resetn, Count(2));
	Enable(3) <= Count(2) AND Enable(2);
	TFF3: ToggleFF PORT MAP (Enable(3), Clock, Resetn, Count(3));
	Enable(4) <= Count(3) AND Enable(3);
	TFF4: ToggleFF PORT MAP (Enable(4), Clock, Resetn, Count(4));
	Enable(5) <= Count(4) AND Enable(4);
	TFF5: ToggleFF PORT MAP (Enable(5), Clock, Resetn, Count(5));
	Enable(6) <= Count(5) AND Enable(5);
	TFF6: ToggleFF PORT MAP (Enable(6), Clock, Resetn, Count(6));
	Enable(7) <= Count(6) AND Enable(6);
	TFF7: ToggleFF PORT MAP (Enable(7), Clock, Resetn, Count(7));
	Enable(8) <= Count(7) AND Enable(7);
	TFF8: ToggleFF PORT MAP (Enable(8), Clock, Resetn, Count(8));
	Enable(9) <= Count(8) AND Enable(8);
	TFF9: ToggleFF PORT MAP (Enable(9), Clock, Resetn, Count(9));
	Enable(10) <= Count(9) AND Enable(9);
	TFF10: ToggleFF PORT MAP (Enable(10), Clock, Resetn, Count(10));
	Enable(11) <= Count(10) AND Enable(10);
	TFF11: ToggleFF PORT MAP (Enable(11), Clock, Resetn, Count(11));
	Enable(12) <= Count(11) AND Enable(11);
	TFF12: ToggleFF PORT MAP (Enable(12), Clock, Resetn, Count(12));
	Enable(13) <= Count(12) AND Enable(12);
	TFF13: ToggleFF PORT MAP (Enable(13), Clock, Resetn, Count(13));
	Enable(14) <= Count(13) AND Enable(13);
	TFF14: ToggleFF PORT MAP (Enable(14), Clock, Resetn, Count(14));
	Enable(15) <= Count(14) AND Enable(14);
	TFF15: ToggleFF PORT MAP (Enable(15), Clock, Resetn, Count(15));
	
	-- drive the displays
	digit3: hex7seg PORT MAP (Count(15 DOWNTO 12), HEX3);
	digit2: hex7seg PORT MAP (Count(11 DOWNTO 8), HEX2);
	digit1: hex7seg PORT MAP (Count(7 DOWNTO 4), HEX1);
	digit0: hex7seg PORT MAP (Count(3 DOWNTO 0), HEX0);
END Behavior;
			
LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- T Flip-flop
ENTITY ToggleFF IS
	PORT (	T, Clock, Resetn	: IN	STD_LOGIC;
			Q						: OUT	STD_LOGIC);
END ToggleFF;

ARCHITECTURE Behavior OF ToggleFF IS
	SIGNAL T_out : STD_LOGIC;
BEGIN
	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN
				T_out <= '0';
			ELSIF (T = '1') THEN
				T_out <= NOT T_out;
			END IF;
		END IF;
	END PROCESS;
	Q <= T_out;
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

