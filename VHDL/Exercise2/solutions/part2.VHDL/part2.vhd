-- bcd-to-decimal converter

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part2 IS 
	PORT (	SW				: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));  -- 7-segs
END part2;

ARCHITECTURE Structure OF part2 IS
	COMPONENT bcd7seg
		PORT (	B	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
					H	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL V, M : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL B : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL z : STD_LOGIC;
BEGIN
	V <= SW;

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
	
	-- Circuit D
	Circuit_D: bcd7seg PORT MAP (M, HEX0);

	-- Circuit C
	HEX1 <= ('1' & NOT(z) & NOT(z) & "1111");	-- display a blank or the digit 1
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
