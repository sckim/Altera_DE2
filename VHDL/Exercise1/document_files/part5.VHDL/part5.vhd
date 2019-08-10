LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part5 IS 
	PORT (	SW 	: IN	STD_LOGIC_VECTOR(17 DOWNTO 0);
				HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part5;

ARCHITECTURE Behavior OF part5 IS
	COMPONENT mux_3bit_5to1
		PORT (	S, U, V, W, X, Y	: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
					M						: OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
	END COMPONENT;
	COMPONENT char_7seg
		PORT (	C			: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
					Display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL M : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
	-- mux_3bit_5to1 (S, U, V, W, X, Y, M);
	M0: mux_3bit_5to1 PORT MAP (SW(17 DOWNTO 15), SW(14 DOWNTO 12), SW(11 DOWNTO 9),
		SW(8 DOWNTO 6), SW(5 DOWNTO 3), SW(2 DOWNTO 0), M);

	-- char_7seg (C, Display);
	H0: char_7seg PORT MAP (M, HEX0);
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- implements a 3-bit wide 5-to-1 multiplexer
ENTITY mux_3bit_5to1 IS
	PORT (	S, U, V, W, X, Y	: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
				M						: OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END mux_3bit_5to1;

ARCHITECTURE Behavior OF mux_3bit_5to1 IS
	SIGNAL m_0, m_1, m_2 : STD_LOGIC_VECTOR(1 TO 3); -- intermediate multiplexers
BEGIN
	-- 5-to-1 multiplexer for bit 0
	m_0(1) <= (NOT(S(0)) AND U(0)) OR (S(0) AND V(0));
	m_0(2) <= (NOT(S(0)) AND W(0)) OR (S(0) AND X(0));
	m_0(3) <= (NOT(S(1)) AND m_0(1)) OR (S(1) AND m_0(2));
	M(0) <= (NOT(S(2)) AND m_0(3)) OR (S(2) AND Y(0)); -- 5-to-1 multiplexer output

	-- 5-to-1 multiplexer for bit 1
	m_1(1) <= (NOT(S(0)) AND U(1)) OR (S(0) AND V(1));
	m_1(2) <= (NOT(S(0)) AND W(1)) OR (S(0) AND X(1));
	m_1(3) <= (NOT(S(1)) AND m_1(1)) OR (S(1) AND m_1(2));
	M(1) <= (NOT(S(2)) AND m_1(3)) OR (S(2) AND Y(1)); -- 5-to-1 multiplexer output
	
	-- 5-to-1 multiplexer for bit 2
	m_2(1) <= (NOT(S(0)) AND U(2)) OR (S(0) AND V(2));
	m_2(2) <= (NOT(S(0)) AND W(2)) OR (S(0) AND X(2));
	m_2(3) <= (NOT(S(1)) AND m_2(1)) OR (S(1) AND m_2(2));
	M(2) <= (NOT(S(2)) AND m_2(3)) OR (S(2) AND Y(2)); -- 5-to-1 multiplexer output
END Behavior;	

LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Converts 3-bit input code on C2-0 into 7-bit code that produces
-- a character on a 7-segment display. The conversion is defined by:
-- 	 C 2 1 0		Char
-- 	----------------
-- 	   0 0 0  	'H'
-- 		0 0 1		'E'
-- 		0 1 0 	'L'
-- 		0 1 1		'O'
-- 		1 0 0    ' ' Blank
-- 		1 0 1    ' ' Blank
-- 		1 1 0    ' ' Blank
-- 		1 1 1		' ' Blank
--
--    Codes 100, 101, 110 are not used
--
ENTITY char_7seg IS
	PORT (	C			: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
				Display	: OUT STD_LOGIC_VECTOR(0 TO 6));
END char_7seg;
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
ARCHITECTURE Behavior OF char_7seg IS
BEGIN
	-- the following equations describe display functions in (inverted) cannonical SOP form
	Display(0) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND C(0)) OR (NOT(C(2)) AND C(1) AND C(0)) ); 
	Display(1) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR (NOT(C(2)) AND C(1) AND C(0)) ); 
	Display(2) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR (NOT(C(2)) AND C(1) AND C(0)) ); 
	Display(3) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND C(0)) OR 
		(NOT(C(2)) AND C(1) AND NOT(C(0))) OR
		(NOT(C(2)) AND C(1) AND C(0)) ); 
	Display(4) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR 
		(NOT(C(2)) AND NOT(C(1)) AND C(0)) OR 
		(NOT(C(2)) AND C(1) AND NOT(C(0))) OR (NOT(C(2)) AND C(1) AND C(0)) );
	Display(5) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR 
		(NOT(C(2)) AND NOT(C(1)) AND C(0)) OR
		(NOT(C(2)) AND C(1) AND NOT(C(0))) OR (NOT(C(2)) AND C(1) AND C(0)) ); 
	Display(6) <= NOT( (NOT(C(2)) AND NOT(C(1)) AND NOT(C(0))) OR
		(NOT(C(2)) AND NOT(C(1)) AND C(0)) );
END Behavior;
