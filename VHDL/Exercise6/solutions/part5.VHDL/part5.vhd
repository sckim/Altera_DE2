LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Input two 4-bit numbers using the SW switches and display the numbers
-- on one digit of the two 2-digit 7-seg displays.  Multiply and display the 
-- product on the two digits of the 4-digit 7-seg display
ENTITY part5 IS 
	PORT (	SW								: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
				HEX7, HEX6, HEX5, HEX4	: OUT	STD_LOGIC_VECTOR(0 TO 6);
				HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part5;

ARCHITECTURE Structure OF part5 IS
	COMPONENT fa
		PORT (	a, b, ci	: IN 	STD_LOGIC;
					s, co 	: OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT hex7seg
		PORT (	hex		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
					display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;

	SIGNAL A, B : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL P : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL C_b1 : STD_LOGIC_VECTOR(3 DOWNTO 1); -- carries for row that ANDs with B1
	SIGNAL C_b2 : STD_LOGIC_VECTOR(3 DOWNTO 1); -- carries for row that ANDs with B2
	SIGNAL C_b3 : STD_LOGIC_VECTOR(3 DOWNTO 1); -- carries for row that ANDs with B3
	-- partial products from row that ANDs with B1:
	SIGNAL PP1 : STD_LOGIC_VECTOR(5 DOWNTO 2); 
	-- partial products from row that ANDs with B2:
	SIGNAL PP2 : STD_LOGIC_VECTOR(6 DOWNTO 3);
BEGIN
	A <= SW(11 DOWNTO 8);
	B <= SW(3 DOWNTO 0);
	P(0) <= A(0) AND B(0);

	-- fa (a, b, ci, s, co);
	b1_a0: fa PORT MAP (A(1) AND B(0), A(0) AND B(1), '0',     P(1),   C_b1(1));
	b1_a1: fa PORT MAP (A(2) AND B(0), A(1) AND B(1), C_b1(1), PP1(2), C_b1(2));
	b1_a2: fa PORT MAP (A(3) AND B(0), A(2) AND B(1), C_b1(2), PP1(3), C_b1(3));
	b1_a3: fa PORT MAP ('0',           A(3) AND B(1), C_b1(3), PP1(4), PP1(5));

	-- fa (a, b, ci, s, co);
	b2_a0: fa PORT MAP (PP1(2), A(0) AND B(2), '0',     P(2),   C_b2(1));
	b2_a1: fa PORT MAP (PP1(3), A(1) AND B(2), C_b2(1), PP2(3), C_b2(2));
	b2_a2: fa PORT MAP (PP1(4), A(2) AND B(2), C_b2(2), PP2(4), C_b2(3));
	b2_a3: fa PORT MAP (PP1(5), A(3) AND B(2), C_b2(3), PP2(5), PP2(6));

	-- fa (a, b, ci, s, co);
	b3_a0: fa PORT MAP (PP2(3), A(0) AND B(3), '0',     P(3), C_b3(1));
	b3_a1: fa PORT MAP (PP2(4), A(1) AND B(3), C_b3(1), P(4), C_b3(2));
	b3_a2: fa PORT MAP (PP2(5), A(2) AND B(3), C_b3(2), P(5), C_b3(3));
	b3_a3: fa PORT MAP (PP2(6), A(3) AND B(3), C_b3(3), P(6), P(7));

	-- drive the display through a 7-seg decoder
	digit_7: hex7seg PORT MAP ("0000", HEX7);
	digit_6: hex7seg PORT MAP (A, HEX6);

	digit_5: hex7seg PORT MAP ("0000", HEX5);
	digit_4: hex7seg PORT MAP (B, HEX4);

	digit_3: hex7seg PORT MAP ("0000", HEX3);
	digit_2: hex7seg PORT MAP ("0000", HEX2);
	digit_1: hex7seg PORT MAP (P(7 DOWNTO 4), HEX1);
	digit_0: hex7seg PORT MAP (P(3 DOWNTO 0), HEX0);
END Structure;
			
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
