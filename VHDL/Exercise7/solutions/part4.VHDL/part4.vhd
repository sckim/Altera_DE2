LIBRARY ieee;
USE ieee.std_logic_1164.all;
-- A mod-10 counter
-- inputs: SW0 is the active low synchronous reset, and KEY0 is the clock. 
-- SW2 SW1 are the w1 w0 inputs.
-- output: if w1 w0 == 00, keep count the same
-- 	if w1 w0 == 01, increment count by 1
-- 	if w1 w0 == 10, increment count by 2
-- 	if w1 w0 == 11, decrement count by 1
-- drive count to digit HEX0
ENTITY part4 IS 
	PORT (	SW 								: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);
				KEY								: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
				HEX0								: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part4;

ARCHITECTURE Behavior OF part4 IS
	COMPONENT bcd7seg
		PORT (	bcd		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
					display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL Clock, Resetn : STD_LOGIC;
	SIGNAL w : STD_LOGIC_VECTOR(1 DOWNTO 0);
	TYPE State_type IS (A, B, C, D, E, F, G, H, I, J);
	SIGNAL y_Q, Y_D : State_type;
	SIGNAL Count : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
	Clock <= KEY(0);
	Resetn <= SW(0);
	w(1 DOWNTO 0) <= SW(2 DOWNTO 1);
		
	PROCESS (w, y_Q) -- state table
	BEGIN
		CASE y_Q IS
			WHEN A =>	CASE w IS
								WHEN "00" => Y_D <= A;
								WHEN "01" => Y_D <= B;
								WHEN "10" => Y_D <= C;
								WHEN "11" => Y_D <= J;
							END CASE;
			WHEN B =>	CASE w IS
								WHEN "00" =>  Y_D <= B;
								WHEN "01" =>  Y_D <= C;
								WHEN "10" =>  Y_D <= D;
								WHEN "11" =>  Y_D <= A;
							END CASE;
			WHEN C =>	CASE w IS
								WHEN "00" =>  Y_D <= C;
								WHEN "01" =>  Y_D <= D;
								WHEN "10" =>  Y_D <= E;
								WHEN "11" =>  Y_D <= B;
							END CASE;
			WHEN D =>	CASE w IS
								WHEN "00" =>  Y_D <= D;
								WHEN "01" =>  Y_D <= E;
								WHEN "10" =>  Y_D <= F;
								WHEN "11" =>  Y_D <= C;
							END CASE;
			WHEN E =>	CASE w IS
								WHEN "00" =>  Y_D <= E;
								WHEN "01" =>  Y_D <= F;
								WHEN "10" =>  Y_D <= G;
								WHEN "11" =>  Y_D <= D;
							END CASE;
			WHEN F =>	CASE w IS
								WHEN "00" =>  Y_D <= F;
								WHEN "01" =>  Y_D <= G;
								WHEN "10" =>  Y_D <= H;
								WHEN "11" =>  Y_D <= E;
							END CASE;
			WHEN G =>	CASE w IS
								WHEN "00" =>  Y_D <= G;
								WHEN "01" =>  Y_D <= H;
								WHEN "10" =>  Y_D <= I;
								WHEN "11" =>  Y_D <= F;
							END CASE;
			WHEN H =>	CASE w IS
								WHEN "00" =>  Y_D <= H;
								WHEN "01" =>  Y_D <= I;
								WHEN "10" =>  Y_D <= J;
								WHEN "11" =>  Y_D <= G;
							END CASE;
			WHEN I =>	CASE w IS
								WHEN "00" =>  Y_D <= I;
								WHEN "01" =>  Y_D <= J;
								WHEN "10" =>  Y_D <= A;
								WHEN "11" =>  Y_D <= H;
							END CASE;
			WHEN J =>	CASE w IS
								WHEN "00" =>  Y_D <= J;
								WHEN "01" =>  Y_D <= A;
								WHEN "10" =>  Y_D <= B;
								WHEN "11" =>  Y_D <= I;
							END CASE;
		END CASE;
	END PROCESS; -- state table

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

	PROCESS (y_Q) -- state outputs
	BEGIN
		CASE y_Q IS
			WHEN A =>	Count <= "0000";
			WHEN B =>	Count <= "0001";
			WHEN C =>	Count <= "0010";
			WHEN D =>	Count <= "0011";
			WHEN E =>	Count <= "0100";
			WHEN F =>	Count <= "0101";
			WHEN G =>	Count <= "0110";
			WHEN H =>	Count <= "0111";
			WHEN I =>	Count <= "1000";
			WHEN J =>	Count <= "1001";
		END CASE;
	END PROCESS; -- state output

	digit0: bcd7seg PORT MAP (Count, HEX0);
END Behavior;
			
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

ENTITY bcd7seg IS
	PORT (	bcd		: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				display	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END bcd7seg;

ARCHITECTURE Behavior OF bcd7seg IS
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
	PROCESS (bcd)
	BEGIN
		CASE bcd IS
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
			WHEN OTHERS => display <= "1111111";
		END CASE;
	END PROCESS;
END Behavior;
