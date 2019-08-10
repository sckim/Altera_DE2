LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Signed 8-bit ripple-carry adder S = A + B, with overflow detection
-- Registers are included for all inputs and outputs.
-- inputs:	SW15-8 = A, SW7-0 = B
-- 			KEY0 = active-low asynchronous reset
-- 			KEY1 = manual clock
-- outputs:	LEDR7-0 shows S in binary form
-- 			HEX7-6 shows input A, HEX5-4 shows input B
-- 			HEX3-0 shows the output sum
-- 			LEDG8 shows overflow
ENTITY part1 IS 
	PORT (	KEY						: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
			SW 						: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
			LEDR					: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			LEDG					: OUT	STD_LOGIC_VECTOR(8 DOWNTO 8);
			HEX7, HEX6, HEX5, HEX4	: OUT	STD_LOGIC_VECTOR(0 TO 6);
			HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part1;

ARCHITECTURE Structure OF part1 IS
	COMPONENT fa
		PORT (	a, b, ci	: IN 	STD_LOGIC;
				s, co 		: OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT regn
		GENERIC ( N	: integer:=	8);
		PORT (	R					: IN	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
				Clock, Resetn		: STD_LOGIC;
				Q					: OUT	STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT flipflop
		PORT (	D, Clock, Resetn	: IN 	STD_LOGIC;
				Q					: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT hex7seg
		PORT (	hex		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
					display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL A, B, S, S_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL C : STD_LOGIC_VECTOR(8 DOWNTO 1);		-- carries
	SIGNAL Clock, Resetn, Overflow, Overflow_reg : STD_LOGIC;
BEGIN
	Resetn <= KEY(0);
	Clock <= KEY(1);

	-- instantiate module regn (R, Clock, Resetn, Q);
	U_A: regn PORT MAP (SW(15 DOWNTO 8), Clock, Resetn, A);
	U_B: regn PORT MAP (SW(7 DOWNTO 0), Clock, Resetn, B);

	bit0: fa PORT MAP (A(0), B(0), '0', S(0), C(1));
	bit1: fa PORT MAP (A(1), B(1), C(1), S(1), C(2));
	bit2: fa PORT MAP (A(2), B(2), C(2), S(2), C(3));
	bit3: fa PORT MAP (A(3), B(3), C(3), S(3), C(4));
	bit4: fa PORT MAP (A(4), B(4), C(4), S(4), C(5));
	bit5: fa PORT MAP (A(5), B(5), C(5), S(5), C(6));
	bit6: fa PORT MAP (A(6), B(6), C(6), S(6), C(7));
	bit7: fa PORT MAP (A(7), B(7), C(7), S(7), C(8));
	-- Display the adder outputs
	LEDR <= S;

	-- instantiate regn (R, Clock, Resetn, Q);
	U_S: regn PORT MAP (S, Clock, Resetn, S_reg);

	-- check for Overflow
	Overflow <= C(8) XOR C(7);
	U_Overflow: flipflop PORT MAP (Overflow, Clock, Resetn, Overflow_reg);
	LEDG(8) <= Overflow_reg;

	-- drive the displays through 7-seg decoders
	digit_7: hex7seg PORT MAP (A(7 DOWNTO 4), HEX7);
	digit_6: hex7seg PORT MAP (A(3 DOWNTO 0), HEX6);

	digit_5: hex7seg PORT MAP (B(7 DOWNTO 4), HEX5);
	digit_4: hex7seg PORT MAP (B(3 DOWNTO 0), HEX4);

	HEX3 <= "1111111";
	HEX2 <= "1111111";
	digit_1: hex7seg PORT MAP (S_reg(7 DOWNTO 4), HEX1);
	digit_0: hex7seg PORT MAP (S_reg(3 DOWNTO 0), HEX0);
END Structure;	
			
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

ENTITY flipflop IS
	PORT (	D, Clock, Resetn	: IN 	STD_LOGIC;
				Q						: OUT	STD_LOGIC);
END flipflop;

ARCHITECTURE Behavior OF flipflop IS
BEGIN
	PROCESS (Clock, Resetn)
	BEGIN
		IF (Resetn = '0') THEN -- asynchronous clear
				Q <= '0';
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			Q <= D;
		END IF;
	END PROCESS;
END Behavior;
		
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY fa IS
	PORT (	a, b, ci	: IN 	STD_LOGIC;
				s, co 	: OUT STD_LOGIC);
END fa;

ARCHITECTURE Structure OF fa IS
	SIGNAL a_xor_b : STD_LOGIC;
BEGIN
	a_xor_b <= a XOR b;
	s <= a_xor_b XOR ci;
	co <= (NOT(a_xor_b) AND b) OR (a_xor_b AND ci);
END Structure;

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
