LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- unsigned 8-bit multiplier-adder S = (A x B) + (C x D)
-- Uses lpm_mult and lpm_add_sub. Registers are included for all inputs and outputs.
-- inputs:	SW15-8 = A or C, SW7-0 = B or D
-- 			SW16 = 0 loads A and B, SW16 = 1 loads C and D
-- 			SW17 = write enable. Setting this to 1 allows registers A, B or
-- 			C, D to be written
-- 			KEY0 = active-low asynchronous reset
-- 			KEY1 = manual clock
-- outputs:	HEX7-6 shows input A when SW16 = 0, shows input C when SW16 = 1
-- 			HEX5-4 shows input B when SW16 = 0, shows input D when SW16 = 1
-- 			HEX3-0 shows the output sum
ENTITY part8 IS 
	PORT (	KEY							: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
				SW								: IN	STD_LOGIC_VECTOR(17 DOWNTO 0);
				LEDG							: OUT STD_LOGIC_VECTOR(8 DOWNTO 8);
				HEX7, HEX6, HEX5, HEX4	: OUT	STD_LOGIC_VECTOR(0 TO 6);
				HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part8;

ARCHITECTURE Behavior OF part8 IS
	COMPONENT regne
		GENERIC ( N	: integer:=	8);
		PORT (	R						: IN	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
					Clock, Resetn, E	: STD_LOGIC;
					Q						: OUT	STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;
	COMPONENT hex7seg
		PORT (	hex		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
					display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	COMPONENT lpm_mult16
		PORT ( 	dataa		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					datab		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					result		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
	END COMPONENT;
	COMPONENT lpm_add16
		PORT (	dataa		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
					datab		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
					cout		: OUT STD_LOGIC ;
					result	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
	END COMPONENT;
	SIGNAL Clock, Resetn, sel_AB_CD, WE : STD_LOGIC;
										-- sel_AB_CD selects regs, WE is write enable
	SIGNAL Cout : STD_LOGIC;	-- carry out for final sum
	SIGNAL A, B, C, D : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL P_AxB, P_CxD, S, S_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL A_C, B_D : STD_LOGIC_VECTOR(7 DOWNTO 0);
	-- uncomment line below for the pipelined version
	-- SIGNAL P_AxB_reg, P_CxD_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	Resetn <= KEY(0);
	Clock <= KEY(1);

	sel_AB_CD <= SW(16);
	WE <= SW(17);

	-- instantiate module regne (R, Clock, Resetn, Q);
	U_A: regne PORT MAP (SW(15 DOWNTO 8), Clock, Resetn, NOT(sel_AB_CD) AND WE, A);
	U_B: regne PORT MAP (SW(7 DOWNTO 0), Clock, Resetn, NOT(sel_AB_CD) AND WE, B);
	U_C: regne PORT MAP (SW(15 DOWNTO 8), Clock, Resetn, sel_AB_CD AND WE, C);
	U_D: regne PORT MAP (SW(7 DOWNTO 0), Clock, Resetn, sel_AB_CD AND WE, D);

	-- instantiate module lpm_mult16 (dataa, datab, result);
	U_AxB: lpm_mult16 PORT MAP (A, B, P_AxB);
	U_CxD: lpm_mult16 PORT MAP (C, D, P_CxD);
	-- uncomment the two lines below to create the pipeline registers
	-- U_P_AxB: regne GENERIC MAP (N => 16) PORT MAP (P_AxB, Clock, Resetn, '1', P_AxB_reg);
	-- U_P_CxD: regne GENERIC MAP (N => 16) PORT MAP (P_CxD, Clock, Resetn, '1', P_CxD_reg);

	-- instantiate module lpm_add16 (dataa, datab, cout, result);
	U_Sum: lpm_add16 PORT MAP (P_AxB, P_CxD, Cout, S);
	-- uncomment the line below, comment out the line above for the pipelined version
	-- U_Sum: lpm_add16 PORT MAP (P_AxB_reg, P_CxD_reg, Cout, S);
	U_S: regne GENERIC MAP (N => 16) PORT MAP (S, Clock, Resetn, '1', S_reg);
	LEDG(8) <= Cout;

	A_C <= A WHEN (sel_AB_CD = '0') ELSE C;
	B_D <= B WHEN (sel_AB_CD = '0') ELSE D;

	-- drive the display through a 7-seg decoder
	digit_7: hex7seg PORT MAP (A_C(7 DOWNTO 4), HEX7);
	digit_6: hex7seg PORT MAP (A_C(3 DOWNTO 0), HEX6);

	digit_5: hex7seg PORT MAP (B_D(7 DOWNTO 4), HEX5);
	digit_4: hex7seg PORT MAP (B_D(3 DOWNTO 0), HEX4);

	digit_3: hex7seg PORT MAP (S_reg(15 DOWNTO 12), HEX3);
	digit_2: hex7seg PORT MAP (S_reg(11 DOWNTO 8), HEX2);
	digit_1: hex7seg PORT MAP (S_reg(7 DOWNTO 4), HEX1);
	digit_0: hex7seg PORT MAP (S_reg(3 DOWNTO 0), HEX0);
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY regne IS
	GENERIC ( N	: integer:=	8);
	PORT (	R						: IN	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
				Clock, Resetn, E	: IN STD_LOGIC;
				Q						: OUT	STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END regne;

ARCHITECTURE Behavior OF regne IS
BEGIN
	PROCESS (Clock, Resetn)
	BEGIN
		IF (Resetn = '0') THEN
			Q <= (OTHERS => '0');
		ELSIF  (Clock'EVENT AND Clock = '1') THEN
			IF (E = '1') THEN
				Q <= R;
			END IF;
		END IF;
	END PROCESS;
END Behavior;

		
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hex7seg IS
	PORT (	hex		: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				display	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END hex7seg;

ARCHITECTURE Behavior OF hex7seg IS
BEGIN
	--
	--       0  
	--      ---  
	--     |   |
	--    5|   |1
	--     | 6 |
	--      ---  
	--     |   |
	--    4|   |2
	--     |   |
	--      ---  
	--       3  
	--
	PROCESS (hex)
	BEGIN
		CASE hex IS
			WHEN "0000" => display <= "0000001";
			WHEN "0001" => display <= "1001111";
			WHEN "0010" => display <= "0010010";
			WHEN "0011" => display <= "0000110";
			WHEN "0100" => display <= "1001100";
			WHEN "0101" => display <= "0100100";
			WHEN "0110" => display <= "1100000";
			WHEN "0111" => display <= "0001111";
			WHEN "1000" => display <= "0000000";
			WHEN "1001" => display <= "0001100";
			WHEN "1010" => display <= "0001000";
			WHEN "1011" => display <= "1100000";
			WHEN "1100" => display <= "0110001";
			WHEN "1101" => display <= "1000010";
			WHEN "1110" => display <= "0110000";
			WHEN OTHERS => display <= "0111000";
		END CASE;
	END PROCESS;
END Behavior;

