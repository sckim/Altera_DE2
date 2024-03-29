-- one-digit BCD adder S1 S0 = A + B + Cin
-- inputs: SW7-4 = A
--         SW3-0 = B
-- outputs: A is displayed on HEX6
-- 			B is displayed on HEX4
-- 			S1 S0 is displayed on HEX1 HEX

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part4 IS 
	PORT (	SW								: IN	STD_LOGIC_VECTOR(8 DOWNTO 0);
			LEDR							: OUT	STD_LOGIC_VECTOR(8 DOWNTO 0);  -- red LEDs
			LEDG							: OUT	STD_LOGIC_VECTOR(8 DOWNTO 0);  -- red LEDs
			HEX7, HEX6, HEX5, HEX4	: OUT	STD_LOGIC_VECTOR(0 TO 6);  -- 7-segs
			HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));  -- 7-segs
END part4;

ARCHITECTURE Structure OF part4 IS
	COMPONENT fa
		PORT (	a, b, ci	: IN 	STD_LOGIC;
				s, co 	: OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT bcd_decimal 
		PORT (	V		: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				z		: BUFFER	STD_LOGIC; 
				M		: OUT	STD_LOGIC_VECTOR(3 DOWNTO 0));  -- 7-segs
	END COMPONENT;
	COMPONENT bcd7seg
		PORT (	B	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
				H	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	
	SIGNAL A, B, S : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Cin : STD_LOGIC;
	SIGNAL C : STD_LOGIC_VECTOR(4 DOWNTO 1);
	SIGNAL S0 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL S0_M : STD_LOGIC_VECTOR(3 DOWNTO 0); -- modified S0 for sums > 15
	SIGNAL S1 : STD_LOGIC;
	
BEGIN
	A <= SW(7 DOWNTO 4);
	B <= SW(3 DOWNTO 0);
	Cin <= SW(8);

	bit0: fa PORT MAP (A(0), B(0), Cin, S(0), C(1));
	bit1: fa PORT MAP (A(1), B(1), C(1), S(1), C(2));
	bit2: fa PORT MAP (A(2), B(2), C(2), S(2), C(3));
	bit3: fa PORT MAP (A(3), B(3), C(3), S(3), C(4));
	
	-- Display the inputs
	LEDR <= SW;
	LEDG(4 DOWNTO 0) <= (C(4) & S);
	
	-- Display the inputs
	H_6: bcd7seg PORT MAP (A, HEX6);
	HEX7 <= ("1111111");	-- display blank

	H_4: bcd7seg PORT MAP (B, HEX4);
	HEX5 <= "1111111";	-- display blank
	
	-- Detect illegal inputs, display on LEDG(8)
	LEDG(8) <= (A(3) AND A(2)) OR (A(3) AND A(1)) OR 
		(B(3) AND B(2)) OR (B(3) AND B(1));
	LEDG(7 DOWNTO 5) <= "000";

	-- Display the sum
	-- bcd_decimal (V, z, M);
	BCD_S: bcd_decimal PORT MAP (S, S1, S0); 
	-- S is really a 5-bit # with the carry-out, but bcd_decimal handles only 
	-- the lower four bit (sums 00-15).  To account for sums 16, 17, 18, 19 S0 
	-- has to be modified in the cases that carry-out = 1. Use multiplexers:
	S0_M(3) <= (NOT(C(4)) AND S0(3)) OR (C(4) AND S0(1)); 
	S0_M(2) <= (NOT(C(4)) AND S0(2)) OR (C(4) AND NOT(S0(1))); 
	S0_M(1) <= (NOT(C(4)) AND S0(1)) OR (C(4) AND NOT(S0(1))); 
	S0_M(0) <= S0(0);
	H_0: bcd7seg PORT MAP (S0_M, HEX0);
	-- S is really a 5-bit #, but bcd_decimal works for only the lower four bits
	-- (sums 00-15). To account for sums 16, 17, 18, 19 S1 should be a 1 when 
	-- the carry-out is a 1
	HEX1 <= ('1' & NOT(S1 OR C(4)) & NOT(S1 OR C(4)) & "1111");	-- display blank or 1
	HEX2 <= "1111111";	-- display blank 
	HEX3 <= "1111111";	-- display blank
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

ENTITY bcd_decimal IS 
	PORT (	V		: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				z		: BUFFER	STD_LOGIC; 
				M		: OUT	STD_LOGIC_VECTOR(3 DOWNTO 0));  -- 7-segs
END bcd_decimal;

ARCHITECTURE Structure OF bcd_decimal IS
	SIGNAL B : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
	-- circuit A
	z <= (V(3) AND V(2)) OR (V(3) AND V(1));

	-- Circuit B
	B(2) <= V(2) AND V(1);
	B(1) <= V(2) AND NOT(V(1));
	B(0) <= (V(1) AND V(0)) OR (V(2) AND V(0));

	-- multiplexers
	M(3) <= NOT(z) AND V(3);
	M(2) <= (NOT(z) AND V(2)) OR (z AND B(2));
	M(1) <= (NOT(z) AND V(1)) OR (z AND B(1));
	M(0) <= (NOT(z) AND V(0)) OR (z AND B(0));
END Structure;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY bcd7seg IS
	PORT (	B	: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				H	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END bcd7seg;

ARCHITECTURE Structure OF bcd7seg IS
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
	-- B  H
	-- ----------
	-- 0  0000001;
	-- 1  1001111;
	-- 2  0010010;
	-- 3  0000110;
	-- 4  1001100;
	-- 5  0100100;
	-- 6  1100000;
	-- 7  0001111;
	-- 8  0000000;
	-- 9  0001100;
	H(0) <= (B(2) AND NOT(B(0))) OR 
		(NOT(B(3)) AND NOT(B(2)) AND NOT(B(1)) AND B(0));
	H(1) <= (B(2) AND NOT(B(1)) AND B(0)) OR
		(B(2) AND B(1) AND NOT(B(0)));
	H(2) <= (NOT(B(2)) AND B(1) AND NOT(B(0)));
	H(3) <= (NOT(B(2)) AND NOT(B(1)) AND B(0)) OR 
		(B(2) AND NOT(B(1)) AND NOT(B(0))) OR (B(2) AND B(1) AND B(0));
	H(4) <= (NOT(B(1)) AND B(0)) OR (NOT(B(3)) AND B(0)) OR 
		(NOT(B(3)) AND B(2) AND NOT(B(1)));
	H(5) <= (B(1) AND B(0)) OR (NOT(B(2)) AND B(1)) OR 
		(NOT(B(3)) AND NOT(B(2)) AND B(0));
	H(6) <= (B(2) AND B(1) AND B(0)) OR (NOT(B(3)) AND NOT(B(2)) AND NOT(B(1)));
END Structure;
