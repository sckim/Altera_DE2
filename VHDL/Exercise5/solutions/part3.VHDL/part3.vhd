LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

-- Press KEY(0) to reset. After a delay (#seconds set by the SW(7 DOWNTO 0)
-- switches), LEDR(0) turns on and the timer starts. Stop the timer by
-- pressing KEY(3)
ENTITY part3 IS 
	PORT (	CLOCK_50							: IN	STD_LOGIC;
				SW 								: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
				KEY								: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				LEDR 								: OUT	STD_LOGIC_VECTOR(0 TO 0);
				HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, 
					HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part3;

ARCHITECTURE Behavior OF part3 IS
	COMPONENT regne 
		PORT (	R, Clock, Resetn, E		: IN	STD_LOGIC;
					Q								: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT bcd7seg
		PORT (	bcd		: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
					display	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL slow_count : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL second : STD_LOGIC_VECTOR(24 DOWNTO 0);
	SIGNAL sec_1, sec_0, min_1, min_0 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL pseudo : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL start, pseudo_0 : STD_LOGIC;
BEGIN
	-- regne (R, Clock, Resetn, E, Q)
	pseudo_0 <= '1' WHEN pseudo = 0 ELSE '0';
	reg_start: regne PORT MAP ('1', CLOCK_50, KEY(3) AND KEY(0), pseudo_0, start);
	LEDR(0) <= start;

	-- A large counter to produce a 1 sec second (approx) enable
	PROCESS (CLOCK_50)
	BEGIN
		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			second <= second + '1';
		END IF;
	END PROCESS;

	-- A large counter to produce a 1 msec second (approx) enable
	PROCESS (CLOCK_50)
	BEGIN
		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			slow_count <= slow_count + '1';
		END IF;
	END PROCESS;

	-- Pseudo random delay counter; loads SW switches and counts down
	PROCESS (CLOCK_50)
	BEGIN
		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			IF ( KEY(3) = '0' OR KEY(0) = '0') THEN
				pseudo <= SW;
			ELSIF (second = 0) THEN
				pseudo <= pseudo - '1';
			END IF;
		END IF;
	END PROCESS;

	-- 4-digit BCD counter that uses a slow enable
	PROCESS (CLOCK_50)
	BEGIN
		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			IF (KEY(0) = '0') THEN
				sec_0 <= "0000";
				sec_1 <= "0000";
				min_0 <= "0000";
				min_1 <= "0000";
			ELSIF ( (slow_count = 0) AND (start = '1') ) THEN
				IF (sec_0 = "1001") THEN	
					sec_0 <= "0000";
	 				IF (sec_1 = "1001") THEN
						sec_1 <= "0000";
						IF (min_0 = "1001") THEN
							min_0 <= "0000";
							IF (min_1 = "1001") THEN
								min_1 <= "0000";
							ELSE
								min_1 <= min_1 + '1';
							END IF;
						ELSE
							min_0 <= min_0 + '1';
						END IF;
					ELSE
						sec_1 <= sec_1 + '1';
					END IF;
				ELSE
					sec_0 <= sec_0 + '1';
				END IF;
	 		END IF;
		END IF;
	END PROCESS;
				
	-- drive the displays
	-- blank the unused displays
	digit7: bcd7seg PORT MAP ("1111", HEX7);
	digit6: bcd7seg PORT MAP ("1111", HEX6);
	digit5: bcd7seg PORT MAP ("1111", HEX5);
	digit4: bcd7seg PORT MAP ("1111", HEX4);

	digit3: bcd7seg PORT MAP (min_1, HEX3);
	digit2: bcd7seg PORT MAP (min_0, HEX2);
	digit1: bcd7seg PORT MAP (sec_1, HEX1);
	digit0: bcd7seg PORT MAP (sec_0, HEX0);
	
END Behavior;
			
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY regne IS 
	PORT (	R, Clock, Resetn, E		: IN	STD_LOGIC;
				Q								: OUT	STD_LOGIC);
END regne;

ARCHITECTURE Behavior OF regne IS
BEGIN
	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN
				Q <= '0';
			ELSIF (E = '1') THEN
				Q <= R;
			END IF;
		END IF;
	END PROCESS;
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

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
