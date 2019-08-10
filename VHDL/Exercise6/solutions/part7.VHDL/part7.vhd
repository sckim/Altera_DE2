LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Input two 8-bit numbers using the SW switches and display the numbers
-- on the 2-digit 7-seg displays.  Multiply and display the product on the
-- 4-digit 7-seg display
ENTITY part7 IS 
	PORT (	KEY							: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
				SW								: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
				HEX7, HEX6, HEX5, HEX4	: OUT	STD_LOGIC_VECTOR(0 TO 6);
				HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part7;

ARCHITECTURE Behavior OF part7 IS
	COMPONENT regn
		GENERIC ( N	: integer:=	8);
		PORT (	R						: IN	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
					Clock, Resetn		: STD_LOGIC;
					Q						: OUT	STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;
	COMPONENT hex7seg
		PORT (	hex		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
					display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	COMPONENT lpm_mult16
		PORT ( 	dataa		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					datab		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					result		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
	END COMPONENT;
	SIGNAL Clock, Resetn : STD_LOGIC;
	SIGNAL A, B : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL P, P_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	Resetn <= KEY(0);
	Clock <= KEY(1);

	-- instantiate module regn (R, Clock, Resetn, Q);
	U_A: regn PORT MAP (SW(15 DOWNTO 8), Clock, Resetn, A);
	U_B: regn PORT MAP (SW(7 DOWNTO 0), Clock, Resetn, B);

	-- lpm_mult16 (dataa, datab, result)
	u1: lpm_mult16 PORT MAP (A, B, P);

	-- instantiate module regn (R, Clock, Resetn, Q);
	U_P: regn GENERIC MAP (N => 16) PORT MAP (P, Clock, Resetn, P_reg);

	-- drive the display through a 7-seg decoder
	digit_7: hex7seg PORT MAP (A(7 DOWNTO 4), HEX7);
	digit_6: hex7seg PORT MAP (A(3 DOWNTO 0), HEX6);

	digit_5: hex7seg PORT MAP (B(7 DOWNTO 4), HEX5);
	digit_4: hex7seg PORT MAP (B(3 DOWNTO 0), HEX4);

	digit_3: hex7seg PORT MAP (P_reg(15 DOWNTO 12), HEX3);
	digit_2: hex7seg PORT MAP (P_reg(11 DOWNTO 8), HEX2);
	digit_1: hex7seg PORT MAP (P_reg(7 DOWNTO 4), HEX1);
	digit_0: hex7seg PORT MAP (P_reg(3 DOWNTO 0), HEX0);
END Behavior;
		
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY regn IS
	GENERIC ( N	: integer:=	8);
	PORT (	R						: IN	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
				Clock, Resetn		: IN STD_LOGIC;
				Q						: OUT	STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END regn;

ARCHITECTURE Behavior OF regn IS
BEGIN
	PROCESS (Clock, Resetn)
	BEGIN
		IF (Resetn = '0') THEN
			Q <= (OTHERS => '0');
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			Q <= R;
		END IF;
	END PROCESS;
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

