LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part2 IS 
	PORT (	V		: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				M		: OUT	STD_LOGIC_VECTOR(3 DOWNTO 0);  -- 7-segs
				z		: BUFFER	STD_LOGIC); 
END part2;

ARCHITECTURE Structure OF part2 IS
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
