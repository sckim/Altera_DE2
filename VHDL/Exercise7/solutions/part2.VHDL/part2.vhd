LIBRARY ieee;
USE ieee.std_logic_1164.all;
-- A sequence detector FSM
-- SW0 is the active low synchronous reset, SW1 is the w input, and KEY0 is the clock.
-- The z output appears on LEDG0, and the state is indicated on LEDR8..0
ENTITY part2 IS 
	PORT (	SW 								: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
				KEY								: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
				LEDG								: OUT	STD_LOGIC_VECTOR(0 DOWNTO 0);
				LEDR								: OUT	STD_LOGIC_VECTOR(8 DOWNTO 0));
END part2;

ARCHITECTURE Behavior OF part2 IS
	SIGNAL Clock, Resetn, w, z : STD_LOGIC;
	TYPE State_type IS (A, B, C, D, E, F, G, H, I);
	SIGNAL y_Q, Y_D : State_type;
BEGIN
	Clock <= KEY(0);
	Resetn <= SW(0);
	w <= SW(1);
		
	PROCESS (w, y_Q) -- state table
	BEGIN
		CASE y_Q IS
			WHEN A =>	IF (w = '0') THEN Y_D <= B;
							ELSE Y_D <= F;
							END IF;
			WHEN B =>	IF (w = '0') THEN Y_D <= C; 
							ELSE Y_D <= F;
							END IF;
			WHEN C =>	IF (w = '0') THEN Y_D <= D; 
							ELSE Y_D <= F;
							END IF;
			WHEN D =>	IF (w = '0') THEN Y_D <= E; 
							ELSE Y_D <= F;
							END IF;
			WHEN E =>	IF (w = '0') THEN Y_D <= E; 
							ELSE Y_D <= F;
							END IF;
			WHEN F =>	IF (w = '0') THEN Y_D <= B; 
							ELSE Y_D <= G;
							END IF;
			WHEN G =>	IF (w = '0') THEN Y_D <= B; 
							ELSE Y_D <= H;
							END IF;
			WHEN H =>	IF (w = '0') THEN Y_D <= B; 
							ELSE Y_D <= I;
							END IF;
			WHEN I =>	IF (w = '0') THEN Y_D <= B; 
							ELSE Y_D <= I;
							END IF;
			WHEN OTHERS	=> Y_D <= A;
		END CASE;
	END PROCESS; -- state_table

	PROCESS (Clock)
	BEGIN
		IF  (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN	-- synchronous clear
				y_Q <= A;
			ELSE
				y_Q <= Y_D;
			END IF;
		END IF;
	END PROCESS;

	z <= '1' WHEN ((y_Q = E) OR (y_Q = I)) ELSE '0';
	LEDG(0) <= z;

	PROCESS (y_Q) -- drive the red LEDs for each state
	BEGIN
		LEDR <= "000000000";
		case y_Q IS
			WHEN A =>	LEDR <= "000000001";
			WHEN B =>	LEDR <= "000000010";
			WHEN C =>	LEDR <= "000000100";
			WHEN D =>	LEDR <= "000001000";
			WHEN E =>	LEDR <= "000010000";
			WHEN F =>	LEDR <= "000100000";
			WHEN G =>	LEDR <= "001000000";
			WHEN H =>	LEDR <= "010000000";
			WHEN I =>	LEDR <= "100000000";
		END CASE;
	END PROCESS; -- LEDs

END Behavior;
