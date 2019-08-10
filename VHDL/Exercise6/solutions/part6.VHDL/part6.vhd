LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Input two 4-bit numbers using the SW switches and display the numbers
-- on one digit of the two 2-digit 7-seg displays.  Multiply and display 
-- the product on the two digits of the 4-digit 7-seg display
ENTITY part6 IS 
	PORT (	KEY						: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
			SW						: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
			HEX7, HEX6, HEX5, HEX4	: OUT	STD_LOGIC_VECTOR(0 TO 6);
			HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part6;

ARCHITECTURE Structure OF part6 IS
	COMPONENT regn
		GENERIC ( N	: integer:=	8);
		PORT (	R					: IN	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
				Clock, Resetn		: STD_LOGIC;
				Q					: OUT	STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;
	COMPONENT fa
		PORT (	a, b, ci	: IN 	STD_LOGIC;
					s, co 	: OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT hex7seg
		PORT (	hex		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
				display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;

	SIGNAL Clock, Resetn : STD_LOGIC;
	SIGNAL A, B : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL P, P_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL C_b1 : STD_LOGIC_VECTOR(7 DOWNTO 1); -- carries for row that ANDs with B1
	SIGNAL C_b2 : STD_LOGIC_VECTOR(7 DOWNTO 1); -- carries for row that ANDs with B2
	SIGNAL C_b3 : STD_LOGIC_VECTOR(7 DOWNTO 1); -- carries for row that ANDs with B3
	SIGNAL C_b4 : STD_LOGIC_VECTOR(7 DOWNTO 1); -- carries for row that ANDs with B4
	SIGNAL C_b5 : STD_LOGIC_VECTOR(7 DOWNTO 1); -- carries for row that ANDs with B5
	SIGNAL C_b6 : STD_LOGIC_VECTOR(7 DOWNTO 1); -- carries for row that ANDs with B6
	SIGNAL C_b7 : STD_LOGIC_VECTOR(7 DOWNTO 1); -- carries for row that ANDs with B7
	-- partial products from row that ANDs with B1:
	SIGNAL PP1 : STD_LOGIC_VECTOR(9 DOWNTO 2); 
	-- partial products from row that ANDs with B2:
	SIGNAL PP2 : STD_LOGIC_VECTOR(10 DOWNTO 3); 
	-- partial products from row that ANDs with B3:
	SIGNAL PP3 : STD_LOGIC_VECTOR(11 DOWNTO 4); 
	-- partial products from row that ANDs with B4:
	SIGNAL PP4 : STD_LOGIC_VECTOR(12 DOWNTO 5); 
	-- partial products from row that ANDs with B5:
	SIGNAL PP5 : STD_LOGIC_VECTOR(13 DOWNTO 6); 
	-- partial products from row that ANDs with B6:
	SIGNAL PP6 : STD_LOGIC_VECTOR(14 DOWNTO 7); 
BEGIN
	Resetn <= KEY(0);
	Clock <= KEY(1);

	-- instantiate module regn (R, Clock, Resetn, Q);
	U_A: regn PORT MAP (SW(15 DOWNTO 8), Clock, Resetn, A);
	U_B: regn PORT MAP (SW(7 DOWNTO 0), Clock, Resetn, B);

	P(0) <= A(0) AND B(0);

	--  fa (a, b, ci, s, co); 
	b1_a0: fa PORT MAP (A(1) AND B(0), A(0) AND B(1), '0',     P(1),   C_b1(1));
	b1_a1: fa PORT MAP (A(2) AND B(0), A(1) AND B(1), C_b1(1), PP1(2), C_b1(2));
	b1_a2: fa PORT MAP (A(3) AND B(0), A(2) AND B(1), C_b1(2), PP1(3), C_b1(3));
	b1_a3: fa PORT MAP (A(4) AND B(0), A(3) AND B(1), C_b1(3), PP1(4), C_b1(4));
	b1_a4: fa PORT MAP (A(5) AND B(0), A(4) AND B(1), C_b1(4), PP1(5), C_b1(5));
	b1_a5: fa PORT MAP (A(6) AND B(0), A(5) AND B(1), C_b1(5), PP1(6), C_b1(6));
	b1_a6: fa PORT MAP (A(7) AND B(0), A(6) AND B(1), C_b1(6), PP1(7), C_b1(7));
	b1_a7: fa PORT MAP ('0',        A(7) AND B(1), C_b1(7), PP1(8), PP1(9));

	--  fa (a, b, ci, s, co);
	b2_a0: fa PORT MAP (PP1(2), A(0) AND B(2), '0',     P(2),   C_b2(1));
	b2_a1: fa PORT MAP (PP1(3), A(1) AND B(2), C_b2(1), PP2(3), C_b2(2));
	b2_a2: fa PORT MAP (PP1(4), A(2) AND B(2), C_b2(2), PP2(4), C_b2(3));
	b2_a3: fa PORT MAP (PP1(5), A(3) AND B(2), C_b2(3), PP2(5), C_b2(4));
	b2_a4: fa PORT MAP (PP1(6), A(4) AND B(2), C_b2(4), PP2(6), C_b2(5));
	b2_a5: fa PORT MAP (PP1(7), A(5) AND B(2), C_b2(5), PP2(7), C_b2(6));
	b2_a6: fa PORT MAP (PP1(8), A(6) AND B(2), C_b2(6), PP2(8), C_b2(7));
	b2_a7: fa PORT MAP (PP1(9), A(7) AND B(2), C_b2(7), PP2(9), PP2(10));

	--  fa (a, b, ci, s, co);
	b3_a0: fa PORT MAP (PP2(3),  A(0) AND B(3), '0',     P(3),    C_b3(1));
	b3_a1: fa PORT MAP (PP2(4),  A(1) AND B(3), C_b3(1), PP3(4),  C_b3(2));
	b3_a2: fa PORT MAP (PP2(5),  A(2) AND B(3), C_b3(2), PP3(5),  C_b3(3));
	b3_a3: fa PORT MAP (PP2(6),  A(3) AND B(3), C_b3(3), PP3(6),  C_b3(4));
	b3_a4: fa PORT MAP (PP2(7),  A(4) AND B(3), C_b3(4), PP3(7),  C_b3(5));
	b3_a5: fa PORT MAP (PP2(8),  A(5) AND B(3), C_b3(5), PP3(8),  C_b3(6));
	b3_a6: fa PORT MAP (PP2(9),  A(6) AND B(3), C_b3(6), PP3(9),  C_b3(7));
	b3_a7: fa PORT MAP (PP2(10), A(7) AND B(3), C_b3(7), PP3(10), PP3(11));

	--  fa (a, b, ci, s, co);
	b4_a0: fa PORT MAP (PP3(4),  A(0) AND B(4), '0',     P(4),    C_b4(1));
	b4_a1: fa PORT MAP (PP3(5),  A(1) AND B(4), C_b4(1), PP4(5),  C_b4(2));
	b4_a2: fa PORT MAP (PP3(6),  A(2) AND B(4), C_b4(2), PP4(6),  C_b4(3));
	b4_a3: fa PORT MAP (PP3(7),  A(3) AND B(4), C_b4(3), PP4(7),  C_b4(4));
	b4_a4: fa PORT MAP (PP3(8),  A(4) AND B(4), C_b4(4), PP4(8),  C_b4(5));
	b4_a5: fa PORT MAP (PP3(9),  A(5) AND B(4), C_b4(5), PP4(9),  C_b4(6));
	b4_a6: fa PORT MAP (PP3(10), A(6) AND B(4), C_b4(6), PP4(10), C_b4(7));
	b4_a7: fa PORT MAP (PP3(11), A(7) AND B(4), C_b4(7), PP4(11), PP4(12));

	--  fa (a, b, ci, s, co);
	b5_a0: fa PORT MAP (PP4(5),  A(0) AND B(5), '0',     P(5),    C_b5(1));
	b5_a1: fa PORT MAP (PP4(6),  A(1) AND B(5), C_b5(1), PP5(6),  C_b5(2));
	b5_a2: fa PORT MAP (PP4(7),  A(2) AND B(5), C_b5(2), PP5(7),  C_b5(3));
	b5_a3: fa PORT MAP (PP4(8),  A(3) AND B(5), C_b5(3), PP5(8),  C_b5(4));
	b5_a4: fa PORT MAP (PP4(9),  A(4) AND B(5), C_b5(4), PP5(9),  C_b5(5));
	b5_a5: fa PORT MAP (PP4(10), A(5) AND B(5), C_b5(5), PP5(10), C_b5(6));
	b5_a6: fa PORT MAP (PP4(11), A(6) AND B(5), C_b5(6), PP5(11), C_b5(7));
	b5_a7: fa PORT MAP (PP4(12), A(7) AND B(5), C_b5(7), PP5(12), PP5(13));

	--  fa (a, b, ci, s, co);
	b6_a0: fa PORT MAP (PP5(6),  A(0) AND B(6), '0',     P(6),    C_b6(1));
	b6_a1: fa PORT MAP (PP5(7),  A(1) AND B(6), C_b6(1), PP6(7),  C_b6(2));
	b6_a2: fa PORT MAP (PP5(8),  A(2) AND B(6), C_b6(2), PP6(8),  C_b6(3));
	b6_a3: fa PORT MAP (PP5(9),  A(3) AND B(6), C_b6(3), PP6(9),  C_b6(4));
	b6_a4: fa PORT MAP (PP5(10), A(4) AND B(6), C_b6(4), PP6(10), C_b6(5));
	b6_a5: fa PORT MAP (PP5(11), A(5) AND B(6), C_b6(5), PP6(11), C_b6(6));
	b6_a6: fa PORT MAP (PP5(12), A(6) AND B(6), C_b6(6), PP6(12), C_b6(7));
	b6_a7: fa PORT MAP (PP5(13), A(7) AND B(6), C_b6(7), PP6(13), PP6(14));

	--  fa (a, b, ci, s, co);
	b7_a0: fa PORT MAP (PP6(7),  A(0) AND B(7), '0',     P(7),  C_b7(1));
	b7_a1: fa PORT MAP (PP6(8),  A(1) AND B(7), C_b7(1), P(8),  C_b7(2));
	b7_a2: fa PORT MAP (PP6(9),  A(2) AND B(7), C_b7(2), P(9),  C_b7(3));
	b7_a3: fa PORT MAP (PP6(10), A(3) AND B(7), C_b7(3), P(10), C_b7(4));
	b7_a4: fa PORT MAP (PP6(11), A(4) AND B(7), C_b7(4), P(11), C_b7(5));
	b7_a5: fa PORT MAP (PP6(12), A(5) AND B(7), C_b7(5), P(12), C_b7(6));
	b7_a6: fa PORT MAP (PP6(13), A(6) AND B(7), C_b7(6), P(13), C_b7(7));
	b7_a7: fa PORT MAP (PP6(14), A(7) AND B(7), C_b7(7), P(14), P(15));

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
