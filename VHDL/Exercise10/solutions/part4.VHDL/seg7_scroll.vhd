LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Data written to registers R0 to R7 are sent to the HEX digits
ENTITY seg7_scroll IS
	PORT (	Data 								: IN	STD_LOGIC_VECTOR(0 TO 6);
				Addr 								: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);
			   Sel, Resetn, Clock			: IN	STD_LOGIC;
				HEX7, HEX6, HEX5, HEX4, 
					HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END seg7_scroll;
	
ARCHITECTURE Behavior OF seg7_scroll IS
	COMPONENT regne
		GENERIC (n : INTEGER := 7);
		PORT (	R						: IN	STD_LOGIC_VECTOR(n-1 DOWNTO 0);
					Clock, Resetn, E	: IN	STD_LOGIC;
					Q						: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0));
	END COMPONENT;
	SIGNAL R0, R1, R2, R3, R4, R5, R6, R7 : STD_LOGIC_VECTOR(0 TO 6); 
	SIGNAL R0_addr, R1_addr, R2_addr, R3_addr, R4_addr, R5_addr, R6_addr, R7_addr :
		STD_LOGIC;
BEGIN
	R0_addr <= '1' WHEN Addr = "000" ELSE '0';
	R1_addr <= '1' WHEN Addr = "001" ELSE '0';
	R2_addr <= '1' WHEN Addr = "010" ELSE '0';
	R3_addr <= '1' WHEN Addr = "011" ELSE '0';
	R4_addr <= '1' WHEN Addr = "100" ELSE '0';
	R5_addr <= '1' WHEN Addr = "101" ELSE '0';
	R6_addr <= '1' WHEN Addr = "110" ELSE '0';
	R7_addr <= '1' WHEN Addr = "111" ELSE '0';

	reg_R0: regne PORT MAP (Data, Clock, Resetn, Sel AND R0_Addr, R0);
	reg_R1: regne PORT MAP (Data, Clock, Resetn, Sel AND R1_Addr, R1);
	reg_R2: regne PORT MAP (Data, Clock, Resetn, Sel AND R2_Addr, R2);
	reg_R3: regne PORT MAP (Data, Clock, Resetn, Sel AND R3_Addr, R3);
	reg_R4: regne PORT MAP (Data, Clock, Resetn, Sel AND R4_Addr, R4);
	reg_R5: regne PORT MAP (Data, Clock, Resetn, Sel AND R5_Addr, R5);
	reg_R6: regne PORT MAP (Data, Clock, Resetn, Sel AND R6_Addr, R6);
	reg_R7: regne PORT MAP (Data, Clock, Resetn, Sel AND R7_Addr, R7);

	HEX7 <= R0; 
	HEX6 <= R1; 
	HEX5 <= R2; 
	HEX4 <= R3; 
	HEX3 <= R4; 
	HEX2 <= R5; 
	HEX1 <= R6; 
	HEX0 <= R7;
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY regne IS
	GENERIC (n : INTEGER := 7);
	PORT (	R						: IN	STD_LOGIC_VECTOR(n-1 DOWNTO 0);
				Clock, Resetn, E	: IN	STD_LOGIC;
				Q						: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0));
END regne;

ARCHITECTURE Behavior OF regne IS
BEGIN
	PROCESS (Clock)
	BEGIN
	 	IF Clock'EVENT AND Clock = '1' THEN
			IF Resetn = '0' THEN
				Q <= (OTHERS => '0');
			ELSIF E = '1' THEN
				Q <= R;
			END IF;
		END IF;
	END PROCESS;
END Behavior;
