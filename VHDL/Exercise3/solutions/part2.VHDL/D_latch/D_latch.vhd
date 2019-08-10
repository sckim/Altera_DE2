LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- A gated D latch described the hard way
ENTITY D_latch IS
	PORT (	Clk, D	: IN	STD_LOGIC;
				Q			: OUT	STD_LOGIC);
END D_latch;

ARCHITECTURE Structural OF D_latch IS
	SIGNAL R, R_g, S_g, Qa, Qb : STD_LOGIC ;
	ATTRIBUTE keep: boolean;
	ATTRIBUTE keep of R, R_g, S_g, Qa, Qb : signal is true;
BEGIN	
	R <= NOT D;
	S_g <= NOT (D AND Clk);
	R_g <= NOT (R AND Clk);
	Qa <= NOT (S_g AND Qb);
	Qb <= NOT (R_g AND Qa);

	Q <= Qa;
END Structural;
