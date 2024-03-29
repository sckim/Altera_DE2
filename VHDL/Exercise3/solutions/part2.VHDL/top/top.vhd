LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- SW[0] is the latch's D input, SW[1] is the level-sensitive Clk, LEDR[0] is Q
ENTITY top IS
	PORT (	SW 	: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
				LEDR	: OUT	STD_LOGIC_VECTOR(0 TO 0));
END top;

ARCHITECTURE Structural OF top IS
	COMPONENT D_latch 
		PORT (	Clk, D	: IN	STD_LOGIC;
					Q			: OUT	STD_LOGIC);
	END COMPONENT;
BEGIN	
	-- D_latch (input Clk, D, output Q)
	U1: D_latch PORT MAP (SW(1), SW(0), LEDR(0));

END Structural;

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

