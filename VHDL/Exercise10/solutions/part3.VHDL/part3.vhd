-- Reset with KEY[0]. SW[17] is Run.
-- The DOUT, ADDR, W, and Done outputs are just for simulation; they
-- aren't connected to any DE2 resources. The HEX0-HEX7 and LEDG are driven
-- to constant values because letting them float causes some of the LEDs
-- to flash on and off for this circuit.
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part3 IS 
PORT (	KEY 								: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
			SW 								: IN	STD_LOGIC_VECTOR(17 DOWNTO 17);
			CLOCK_50							: IN  STD_LOGIC;
			LEDR								: OUT	STD_LOGIC_VECTOR(15 DOWNTO 0);
			DOUT, ADDR						: BUFFER	STD_LOGIC_VECTOR(15 DOWNTO 0);
			W, Done							: BUFFER STD_LOGIC;
			HEX7, HEX6, HEX5, HEX4, 
				HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6);
			LEDG								: OUT	STD_LOGIC_VECTOR(8 DOWNTO 0));
END part3;

ARCHITECTURE Behavior OF part3 IS
	COMPONENT proc
		PORT (	DIN 						: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
					Resetn, Clock, Run	: IN	STD_LOGIC;
					DOUT 						: OUT	STD_LOGIC_VECTOR(15 DOWNTO 0);
					ADDR 						: OUT	STD_LOGIC_VECTOR(15 DOWNTO 0);
					W							: OUT	STD_LOGIC;
					Done						: BUFFER	STD_LOGIC);
	END COMPONENT;
	COMPONENT inst_mem 
		PORT (	address	: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
					clock		: IN STD_LOGIC ;
					data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
					wren		: IN STD_LOGIC  := '1';
					q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
	END COMPONENT;
	COMPONENT regn
		GENERIC (n : INTEGER := 16);
		PORT (	R				: IN	STD_LOGIC_VECTOR(n-1 DOWNTO 0);
					Rin, Clock	: IN	STD_LOGIC;
					Q				: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0));
	END COMPONENT;
	COMPONENT flipflop 
		PORT (	D, Resetn, Clock	: IN	STD_LOGIC;
					Q						: OUT	STD_LOGIC);
	END COMPONENT;
	SIGNAL Sync, Run, inst_mem_cs, LED_reg_cs : STD_LOGIC;
	SIGNAL DIN, LED_reg : STD_LOGIC_VECTOR(15 DOWNTO 0); 
BEGIN
	HEX7 <= "0000000";
	HEX6 <= "0000000";
	HEX5 <= "0000000";
	HEX4 <= "0000000";
	HEX3 <= "0000000";
	HEX2 <= "0000000";
	HEX1 <= "0000000";
	HEX0 <= "0000000";
	LEDG <= "000000000";

	-- synchronize the Run input
	U1: flipflop PORT MAP (SW(17), KEY(0), CLOCK_50, Sync);
	U2: flipflop PORT MAP (Sync, KEY(0), CLOCK_50, Run);
	
	-- proc(DIN, Resetn, Clock, Run, DOUT, ADDR, W, Done);
	U3: proc PORT MAP (DIN, KEY(0), CLOCK_50, Run, DOUT, ADDR, W, Done);

	inst_mem_cs <= '1' WHEN (ADDR(15 DOWNTO 12) = "0000") ELSE '0';
	-- inst_mem ( address, clock, data, wren, q);
	U4: inst_mem PORT MAP (ADDR(6 DOWNTO 0), CLOCK_50, DOUT, inst_mem_cs AND W, DIN);

	LED_reg_cs <= '1' WHEN (ADDR(15 DOWNTO 12) = "0001") ELSE '0';
	-- regn(R, Rin, Clock, Q);
	U6: regn PORT MAP (DOUT, LED_reg_cs AND W, CLOCK_50, LED_reg);
	LEDR(15 DOWNTO 0) <= LED_reg(15 DOWNTO 0);
END Behavior;
