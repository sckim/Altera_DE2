LIBRARY ieee;
USE ieee.std_logic_1164.all;
-- A sequence detector FSM using one-hot encoding. 
-- SW0 is the active low synchronous reset, SW1 is the w input, and KEY0 is the clock.
-- The z output appears on LEDG0, and the state FFs appear on LEDR8..0
ENTITY part1 IS 
	PORT (	SW 								: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
				KEY								: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
				LEDG								: OUT	STD_LOGIC_VECTOR(0 DOWNTO 0);
				LEDR								: OUT	STD_LOGIC_VECTOR(8 DOWNTO 0));
END part1;

ARCHITECTURE Behavior OF part1 IS
	COMPONENT flipflop
		PORT (	D, Clock, Resetn 	: IN 	STD_LOGIC;
					Q						: OUT	STD_LOGIC);
	END COMPONENT;
	SIGNAL Clock, Resetn, w, z : STD_LOGIC;
	SIGNAL y_Q, Y_D : STD_LOGIC_VECTOR(8 DOWNTO 0);
BEGIN
	Clock <= KEY(0);
	Resetn <= SW(0);
	w <= SW(1);

	-- Three changes are needed from the version that uses the traditional one-hot code:
	-- 1. Change equation for Y0 to Y0 = 1.
	-- 2. Change logic equations for Y1 and Y5 to use NOT Y0
	-- 3. Change flipflops to not have reset input
	Y_D(0) <= '1';
	U0: flipflop PORT MAP (Y_D(0), Clock, Resetn, y_Q(0));
	Y_D(1) <= (NOT (y_Q(0)) OR y_Q(5) OR y_Q(6) OR y_Q(7) OR y_Q(8)) AND NOT (w);
	U1: flipflop PORT MAP (Y_D(1), Clock, Resetn, y_Q(1));
	Y_D(2) <= y_Q(1) AND NOT (w);
	U2: flipflop PORT MAP (Y_D(2), Clock, Resetn, y_Q(2));
	Y_D(3) <= y_Q(2) AND NOT (w);
	U3: flipflop PORT MAP (Y_D(3), Clock, Resetn, y_Q(3));
	Y_D(4) <= (y_Q(3) OR y_Q(4)) AND NOT (w);
	U4: flipflop PORT MAP (Y_D(4), Clock, Resetn, y_Q(4));

	Y_D(5) <= (NOT (y_Q(0)) OR y_Q(1) OR y_Q(2) OR y_Q(3) OR y_Q(4)) AND (w);
	U5: flipflop PORT MAP (Y_D(5), Clock, Resetn, y_Q(5));
	Y_D(6) <= y_Q(5) AND (w);
	U6: flipflop PORT MAP (Y_D(6), Clock, Resetn, y_Q(6));
	Y_D(7) <= y_Q(6) AND (w);
	U7: flipflop PORT MAP (Y_D(7), Clock, Resetn, y_Q(7));
	Y_D(8) <= (y_Q(7) OR y_Q(8)) AND (w);
	U8: flipflop PORT MAP (Y_D(8), Clock, Resetn, y_Q(8));

	z <= y_Q(4) OR y_Q(8);
	LEDR(8 DOWNTO 0) <= y_Q(8 DOWNTO 0);
	LEDG(0) <= z;
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY flipflop IS
	PORT (	D, Clock, Resetn	: IN 	STD_LOGIC;
				Q						: OUT	STD_LOGIC);
END flipflop;

ARCHITECTURE Behavior OF flipflop IS
BEGIN
	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN -- synchronous clear
				Q <= '0';
			ELSE
				Q <= D;
			END IF;
		END IF;
	END PROCESS;
END Behavior;
