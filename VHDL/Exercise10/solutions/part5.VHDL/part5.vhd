LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Reset with KEY0. SW17 is Run
-- The processor executes the instructions in the file inst_mem.mif
ENTITY part5 IS 
PORT (	KEY 								: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
			SW 								: IN	STD_LOGIC_VECTOR(17 DOWNTO 0);
			CLOCK_50							: IN  STD_LOGIC;
			HEX7, HEX6, HEX5, HEX4, 
				HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6);
			LEDR								: OUT	STD_LOGIC_VECTOR(15 DOWNTO 0);
			LEDG								: OUT	STD_LOGIC_VECTOR(8 DOWNTO 0);
			DOUT, ADDR						: BUFFER	STD_LOGIC_VECTOR(15 DOWNTO 0);
			W, Done							: BUFFER STD_LOGIC);
END part5;
	
ARCHITECTURE Behavior OF part5 IS
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
	COMPONENT seg7_scroll 
		PORT (	Data 								: IN	STD_LOGIC_VECTOR(0 TO 6);
					Addr 								: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);
			   	Sel, Resetn, Clock			: IN	STD_LOGIC;
					HEX7, HEX6, HEX5, HEX4, 
						HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL Sync, Run, inst_mem_cs, LED_reg_cs, seg7_cs : STD_LOGIC;
	SIGNAL DIN, LED_reg, SW_reg, inst_mem_q : STD_LOGIC_VECTOR(15 DOWNTO 0); 
BEGIN
	-- synchronize the Run input
	U1: flipflop PORT MAP (SW(17), KEY(0), CLOCK_50, Sync);
	U2: flipflop PORT MAP (Sync, KEY(0), CLOCK_50, Run);
	
	-- proc(DIN, Resetn, Clock, Run, DOUT, ADDR, W, Done);
	U3: proc PORT MAP (DIN, KEY(0), CLOCK_50, Run, DOUT, ADDR, W, Done);

	inst_mem_cs <= '1' WHEN ADDR(15 DOWNTO 12) = "0000" ELSE '0';
	-- inst_mem (address, clock, data, wren, q);
	U4: inst_mem PORT MAP (ADDR(6 DOWNTO 0), CLOCK_50, DOUT, inst_mem_cs AND W, 
		inst_mem_q);

	PROCESS (inst_mem_q, SW_reg, inst_mem_cs)
	BEGIN
		IF inst_mem_cs = '1' THEN
			DIN <= inst_mem_q;
		ELSE
			DIN <= SW_reg;
		END IF;
	END PROCESS;

	LED_reg_cs <= '1' WHEN ADDR(15 DOWNTO 12) = "0001" ELSE '0';
	-- regn(R, Rin, Clock, Q);
	U6: regn PORT MAP (DOUT, LED_reg_cs AND W, CLOCK_50, LED_reg);
	LEDR(15 DOWNTO 0) <= LED_reg(15 DOWNTO 0);
	LEDG <= "000000000";

	seg7_cs <= '1' WHEN ADDR(15 DOWNTO 12) = "0010" ELSE '0';
	U5: seg7_scroll PORT MAP (DOUT(6 DOWNTO 0), ADDR(2 DOWNTO 0), seg7_cs AND W, 
		KEY(0), CLOCK_50, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

	-- regn(R, Rin, Clock, Q);
	U7: regn PORT MAP (SW(15 DOWNTO 0), '1', CLOCK_50, SW_reg);
END Behavior;

