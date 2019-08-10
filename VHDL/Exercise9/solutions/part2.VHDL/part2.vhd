-- Reset with KEY(0). Clock counter and memory with KEY(2). Clock
-- each instuction into the processor with KEY(1). SW(17) is the Run input.
-- Use KEY(2) to advance the memory as needed before each processor KEY(1)
-- clock cycle.
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part2 IS 
PORT (	KEY 				: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);
			SW 				: IN	STD_LOGIC_VECTOR(17 DOWNTO 17);
			LEDR				: OUT	STD_LOGIC_VECTOR(17 DOWNTO 0));
END part2;

ARCHITECTURE Behavior OF part2 IS
	COMPONENT proc
		PORT (	DIN 						: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
					Resetn, Clock, Run	: IN	STD_LOGIC;
					Done						: BUFFER	STD_LOGIC;
					BusWires					: BUFFER	STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;
	COMPONENT inst_mem 
		PORT (	address	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
					clock		: IN STD_LOGIC ;
					q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
	END COMPONENT;
	COMPONENT count5
		PORT (	Resetn, Clock	: IN	STD_LOGIC;
					Q					: OUT	STD_LOGIC_VECTOR(4 DOWNTO 0));
	END COMPONENT;

	SIGNAL Resetn, PClock, MClock, Run, Done : STD_LOGIC;
	SIGNAL DIN, BusWires : STD_LOGIC_VECTOR(15 DOWNTO 0); 
	SIGNAL pc : STD_LOGIC_VECTOR(4 DOWNTO 0); 
BEGIN
	Resetn <= KEY(0);
	PClock <= KEY(1);
	MClock <= KEY(2);
	Run <= SW(17);
	-- proc(DIN, Resetn, Clock, Run, Done, BusWires);
	U1: proc PORT MAP (DIN, Resetn, PClock, Run, Done, BusWires);
	LEDR(15 DOWNTO 0) <= BusWires;
	LEDR(17) <= Done;

	U2: inst_mem PORT MAP (pc, MClock, DIN);
	U3: count5 PORT MAP (Resetn, MClock, pc);
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY count5 IS 
PORT (	Resetn, Clock	: IN	STD_LOGIC;
			Q					: OUT	STD_LOGIC_VECTOR(4 DOWNTO 0));
END count5;

ARCHITECTURE Behavior OF count5 IS
	SIGNAL Count : STD_LOGIC_VECTOR(4 DOWNTO 0); 
BEGIN
	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN
				Count <= "00000";
			ELSE
				Count <= Count + '1';
			END IF;
		END IF;
	END PROCESS;
	Q <= Count;
END Behavior;
