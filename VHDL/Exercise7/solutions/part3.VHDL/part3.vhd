LIBRARY ieee;
USE ieee.std_logic_1164.all;
-- a sequence detector FSM using a shift register
-- SW0 is the active low synchronous reset, SW1 is the w input, and KEY0 is the clock.
-- The z output appears on LEDG0, and the shift register FFs appear on LEDR3..0
-- a sequence detector shift register
-- inputs: Resetn is 
ENTITY part3 IS 
	PORT (	SW 								: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
				KEY								: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
				LEDG								: OUT	STD_LOGIC_VECTOR(0 DOWNTO 0);
				LEDR								: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0));
END part3;

ARCHITECTURE Behavior OF part3 IS
	SIGNAL Clock, Resetn, w, z : STD_LOGIC;
	SIGNAL S4_0s : STD_LOGIC_VECTOR(1 TO 4); -- shift register for recognizing 4 0s
	SIGNAL S4_1s : STD_LOGIC_VECTOR(1 TO 4); -- shift register for recognizing 4 1s
BEGIN
	Clock <= KEY(0);
	Resetn <= SW(0);
	w <= SW(1);
		
	PROCESS (Clock)
	BEGIN
		IF  (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN	-- synchronous clear
				S4_0s <= "1111";
				S4_1s <= "0000";
			ELSE
				S4_0s(1) <= w;
				S4_0s(2) <= S4_0s(1);
				S4_0s(3) <= S4_0s(2);
				S4_0s(4) <= S4_0s(3);

				S4_1s(1) <= w;
				S4_1s(2) <= S4_1s(1);
				S4_1s(3) <= S4_1s(2);
				S4_1s(4) <= S4_1s(3);
			END IF;
		END IF;
	END PROCESS;

	z <= '1' WHEN ((S4_0s = "0000") OR (S4_1s = "1111")) ELSE '0';
	LEDR(3 DOWNTO 0) <= S4_0s;
	LEDR(7 DOWNTO 4) <= S4_1s;
	LEDG(0) <= z;
END Behavior;
