LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

ENTITY proc IS
	PORT (	DIN 						: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
				Resetn, Clock, Run	: IN	STD_LOGIC;
				Done						: BUFFER	STD_LOGIC;
				BusWires					: BUFFER	STD_LOGIC_VECTOR(15 DOWNTO 0));
END proc;
	
ARCHITECTURE Behavior OF proc IS
	COMPONENT upcount
		PORT (	Clear, Clock	: IN 		STD_LOGIC;
					Q					: BUFFER STD_LOGIC_VECTOR(1 DOWNTO 0));
	END COMPONENT;

	COMPONENT dec3to8
		PORT (	W		: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
					En		: IN	STD_LOGIC;
					Y		: OUT	STD_LOGIC_VECTOR(0 TO 7));
	END COMPONENT;


	COMPONENT regn
		GENERIC (n : INTEGER := 16);
		PORT (	R				: IN		STD_LOGIC_VECTOR(n-1 DOWNTO 0);
					Rin, Clock	: IN		STD_LOGIC;
					Q				: BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0));
	END COMPONENT;
	SIGNAL Rin, Rout : STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL Sum : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL Clear, High, IRin, DINout, Ain, Gin, Gout, AddSub : STD_LOGIC;
	SIGNAL Tstep_Q : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL I : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Xreg, Yreg : STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL R0, R1, R2, R3, R4, R5, R6, R7, A, G : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL IR : STD_LOGIC_VECTOR(1 TO 9);
	SIGNAL Sel : STD_LOGIC_VECTOR(1 to 10); -- bus selector
BEGIN
	High <= '1';
	Clear <= NOT(Resetn) OR Done OR (NOT(Run) AND NOT(Tstep_Q(1)) AND NOT(Tstep_Q(0))); 
	Tstep: upcount PORT MAP (Clear, Clock, Tstep_Q);
	I <= IR(1 TO 3);
	decX: dec3to8 PORT MAP (IR(4 TO 6), High, Xreg);
	decY: dec3to8 PORT MAP (IR(7 TO 9), High, Yreg);
	
	-- Instruction Table
	-- 	000: mv		Rx,Ry				: Rx <- [Ry]
	-- 	001: mvi		Rx,#D				: Rx <- D
	-- 	010: add		Rx,Ry				: Rx <- [Rx] + [Ry]
	-- 	011: sub		Rx,Ry				: Rx <- [Rx] - [Ry]
	-- 	OPCODE format: III XXX YYY, where 
	-- 	III = instruction, XXX = Rx, and YYY = Ry. For mvi,
	-- 	a second word of data is loaded from DIN
	--
	controlsignals: PROCESS (Tstep_Q, I, Xreg, Yreg)
	BEGIN
		Done <= '0'; Ain <= '0'; Gin <= '0'; Gout <= '0'; AddSub <= '0';
		IRin <= '0'; DINout <= '0'; Rin <= "00000000"; Rout <= "00000000";
		CASE Tstep_Q IS
			WHEN "00" => -- store DIN in IR as long as Tstep_Q = 0
				IRin <= '1';
			WHEN "01" => -- define signals in time step T1
				CASE I IS
					WHEN "000" => -- mv Rx,Ry
						Rout <= Yreg;
						Rin <= Xreg;
						Done <= '1';
					WHEN "001" => -- mvi Rx,#D
						-- data is required to be on DIN
						DINout <= '1';
						Rin <= Xreg; 
						Done <= '1';
					WHEN "010" => -- add
						Rout <= Xreg;
						Ain <= '1';
					-- WHEN "011" => -- sub
					WHEN OTHERS => -- sub
						Rout <= Xreg;
						Ain <= '1';
					-- WHEN OTHERS => ; 
				END CASE;
			WHEN "10" => -- define signals in time step T2
				CASE I IS
					WHEN "010" => -- add
						Rout <= Yreg;
						Gin <= '1';
					-- WHEN "011" => -- sub
					WHEN OTHERS => -- sub
						Rout <= Yreg;
						AddSub <= '1';
						Gin <= '1';
					-- WHEN OTHERS => ; 
				END CASE;
			WHEN "11" => -- define signals in time step T3
				CASE I IS
					WHEN "010" => -- add
						Gout <= '1';
						Rin <= Xreg;
						Done <= '1';
					-- WHEN "011" => -- sub
					WHEN OTHERS => -- sub
						Gout <= '1';
						Rin <= Xreg;
						Done <= '1';
					-- WHEN OTHERS => ;
				END CASE;
		END CASE;
	END PROCESS;	
	
	reg_0: regn PORT MAP (BusWires, Rin(0), Clock, R0);
	reg_1: regn PORT MAP (BusWires, Rin(1), Clock, R1);
	reg_2: regn PORT MAP (BusWires, Rin(2), Clock, R2);
	reg_3: regn PORT MAP (BusWires, Rin(3), Clock, R3);
	reg_4: regn PORT MAP (BusWires, Rin(4), Clock, R4);
	reg_5: regn PORT MAP (BusWires, Rin(5), Clock, R5);
	reg_6: regn PORT MAP (BusWires, Rin(6), Clock, R6);
	reg_7: regn PORT MAP (BusWires, Rin(7), Clock, R7);
	reg_A: regn PORT MAP (BusWires, Ain, Clock, A);
	reg_IR: regn GENERIC MAP (n => 9) PORT MAP (DIN(15 DOWNTO 7), IRin, Clock, IR);

	--	alu
	alu: PROCESS (AddSub, A, BusWires)
	BEGIN
		IF AddSub = '0' THEN
			Sum <= A + BusWires;
	   ELSE
			Sum <= A - BusWires;
		END IF;
	END PROCESS;

	reg_G: regn PORT MAP (Sum, Gin, Clock, G);

	-- define the internal processor bus
	Sel <= Rout & Gout & DINout;

	busmux: PROCESS (Sel, R0, R1, R2, R3, R4, R5, R6, R7, G, DIN)
	BEGIN
		IF Sel = "1000000000" THEN
			BusWires <= R0;
   	ELSIF Sel = "0100000000" THEN
			BusWires <= R1;
		ELSIF Sel = "0010000000" THEN
			BusWires <= R2;
		ELSIF Sel = "0001000000" THEN
			BusWires <= R3;
		ELSIF Sel = "0000100000" THEN
			BusWires <= R4;
		ELSIF Sel = "0000010000" THEN
			BusWires <= R5;
		ELSIF Sel = "0000001000" THEN
			BusWires <= R6;
		ELSIF Sel = "0000000100" THEN
			BusWires <= R7;
		ELSIF Sel = "0000000010" THEN
			BusWires <= G;
   	ELSE 
			BusWires <= DIN;
		END IF;
	END PROCESS;	
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

ENTITY upcount IS
	PORT (	Clear, Clock	: IN 		STD_LOGIC;
				Q					: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0));
END upcount;

ARCHITECTURE Behavior OF upcount IS
	SIGNAL Count : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
	 		IF Clear  = '1' THEN
				Count <= "00";
			ELSE 
				Count <= Count + 1;
			END IF;
		END IF;
	END PROCESS;
	Q <= Count;
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY dec3to8 IS
	PORT (	W		: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
				En		: IN	STD_LOGIC;
				Y		: OUT	STD_LOGIC_VECTOR(0 TO 7));
END dec3to8;

ARCHITECTURE Behavior OF dec3to8 IS
BEGIN
	PROCESS (W, En)
	BEGIN
		IF En = '1' THEN
			CASE W IS
				WHEN "000" => Y <= "10000000";
	   	   WHEN "001" => Y <= "01000000";
				WHEN "010" => Y <= "00100000";
				WHEN "011" => Y <= "00010000";
				WHEN "100" => Y <= "00001000";
				WHEN "101" => Y <= "00000100";
				WHEN "110" => Y <= "00000010";
				WHEN "111" => Y <= "00000001";
			END CASE;
		ELSE 
			Y <= "00000000";
		END IF;
	END PROCESS;
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY regn IS
	GENERIC (n : INTEGER := 16);
	PORT (	R				: IN		STD_LOGIC_VECTOR(n-1 DOWNTO 0);
				Rin, Clock	: IN		STD_LOGIC;
				Q				: BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0));
END regn;

ARCHITECTURE Behavior OF regn IS
BEGIN
	PROCESS (Clock)
	BEGIN
	 	IF Clock'EVENT AND Clock = '1' THEN
			IF Rin = '1' THEN
				Q <= R;
			END IF;
		END IF;
	END PROCESS;
END Behavior;
