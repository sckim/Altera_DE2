-- This code implements a simple dual-port memory using an M4K block
-- 
-- inputs: CLOCK_50 is the clock, KEY0 is Resetn, SW7-SW0 provides data to 
-- write into memory.
-- SW15-SW11 provides the memory address, SW17 is the memory Write input.
-- outputs: 7-seg displays HEX7, HEX6 display the memory addres, HEX5, HEX4
-- displays the data input to the memory, and HEX1, HEX0 show the contents read
-- from the memory. LEDG0 shows the status of Write.
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY part5 IS 
PORT (	CLOCK_50							: IN	STD_LOGIC;
			KEY 								: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
			SW 								: IN	STD_LOGIC_VECTOR(17 DOWNTO 0);
			HEX7, HEX6, HEX5, HEX4, 
				HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6);
			LEDG								: OUT	STD_LOGIC_VECTOR(0 DOWNTO 0));
END part5;

ARCHITECTURE Behavior OF part5 IS
	COMPONENT flip_flop
		PORT (	R						: IN	STD_LOGIC;
					Clock, Resetn, E	: STD_LOGIC;
					Q						: OUT	STD_LOGIC);
	END COMPONENT;
	COMPONENT regne
		GENERIC ( N	: integer:=	7);
		PORT (	R						: IN	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
					Clock, Resetn, E	: STD_LOGIC;
					Q						: OUT	STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;
	COMPONENT ramlpm 
		PORT (	clock			: IN STD_LOGIC ;
					data			: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					rdaddress	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
					wraddress	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
					wren			: IN STD_LOGIC  := '1';
					q				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
	END COMPONENT;
	COMPONENT hex7seg
		PORT (	hex		: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
					display	: OUT	STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL Clock, Resetn, Write, Write_sync : STD_LOGIC;
	SIGNAL Write_address, Write_address_sync, Read_address : 
		STD_LOGIC_VECTOR(4 DOWNTO 0); 
	-- Read_address cycles from addresses 0 to 31 at one second per address

	SIGNAL slow_count : STD_LOGIC_VECTOR(24 DOWNTO 0); 
	SIGNAL DataIn, DataIn_sync, DataOut : STD_LOGIC_VECTOR(7 DOWNTO 0); 
BEGIN
	Resetn <= KEY(0);
	Clock <= CLOCK_50;

	-- synchronize all asynchronous inputs to the clock
	R1: flip_flop PORT MAP (SW(17), Clock, Resetn, '1', Write_sync);
	R2: flip_flop PORT MAP (Write_sync, Clock, Resetn, '1', Write);

	R3: regne GENERIC MAP (N => 5) 
		PORT MAP (SW(15 DOWNTO 11), Clock, Resetn, '1', Write_address_sync);
	R4: regne  GENERIC MAP (N => 5) 
		PORT MAP (Write_address_sync, Clock, Resetn, '1', Write_address);

	R5: regne GENERIC MAP (N => 8) PORT MAP (SW(7 DOWNTO 0), Clock, Resetn, 
		'1', DataIn_sync);
	R6: regne GENERIC MAP (N => 8) PORT MAP (DataIn_sync, Clock, Resetn, 
		'1', DataIn);

	-- one second cycle counter
	-- Create a 1Hz 5-bit address counter
	-- A large counter to produce a 1 second (approx) enable
	PROCESS (Clock)
	BEGIN
		IF  (Clock'EVENT AND Clock = '1') THEN
			slow_count <= slow_count + '1';
		END IF;
	END PROCESS;

	-- the read address counter
	PROCESS (Clock)
	BEGIN
		IF  (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN	-- synchronous clear
				Read_address <= (OTHERS => '0');
			ELSIF (slow_count = 0) THEN
				Read_address <= Read_address + '1';
			END IF;
		END IF;
	END PROCESS;

	-- instantiate LPM module
	-- module ramlpm (clock, data, rdaddress, wraddress, wren, q);
	m32x8_dual: ramlpm PORT MAP (Clock, DataIn, Read_address, Write_address, 
		Write, DataOut);

	-- display the data input, data output, and address on the 7-segs
	digit0: hex7seg PORT MAP (DataOut(3 DOWNTO 0), HEX0);
	digit1: hex7seg PORT MAP (DataOut(7 DOWNTO 4), HEX1);
	digit2: hex7seg PORT MAP (Read_address(3 DOWNTO 0), HEX2);
	digit3: hex7seg PORT MAP (("000" & Read_address(4)), HEX3);
	digit4: hex7seg PORT MAP (DataIn(3 DOWNTO 0), HEX4);
	digit5: hex7seg PORT MAP (DataIn(7 DOWNTO 4), HEX5);
	digit6: hex7seg PORT MAP (Write_Address(3 DOWNTO 0), HEX6);
	digit7: hex7seg PORT MAP (("000" & Write_Address(4)), HEX7);

	LEDG(0) <= Write;
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY regne IS
	GENERIC ( N	: integer:=	7);
	PORT (	R						: IN	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
				Clock, Resetn, E	: IN STD_LOGIC;
				Q						: OUT	STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END regne;

ARCHITECTURE Behavior OF regne IS
BEGIN
	PROCESS (Clock)
	BEGIN
		IF  (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN	-- synchronous clear
				Q <= (OTHERS => '0');
			ELSIF (E = '1') THEN
				Q <= R;
			END IF;
		END IF;
	END PROCESS;
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY flip_flop IS
	PORT (	R						: IN	STD_LOGIC;
				Clock, Resetn, E	: IN STD_LOGIC;
				Q						: OUT	STD_LOGIC);
END flip_flop;

ARCHITECTURE Behavior OF flip_flop IS
BEGIN
	PROCESS (Clock)
	BEGIN
		IF  (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN	-- synchronous clear
				Q <= '0';
			ELSIF (E = '1') THEN
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
		CASE (hex) IS
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
