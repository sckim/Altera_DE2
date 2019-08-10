LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
-- scrolls the word HELLO across the 7-seg displays. An FSM inserts the
-- display values into a pipeline that drives the 8 displays; each display
-- is driven for about 1 second before changing to the next character
-- inputs: 50 MHz clock, KEY0 is reset input
-- outputs: 7-seg displays HEX7 ... HEX0
ENTITY part6 IS 
PORT (	KEY 								: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
			CLOCK_50							: IN	STD_LOGIC;
			HEX7, HEX6, HEX5, HEX4, 
				HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part6;

ARCHITECTURE Behavior OF part6 IS
	COMPONENT regne
		GENERIC ( N	: integer:=	7);
		PORT (	R						: IN	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
					Clock, Resetn, E	: STD_LOGIC;
					Q						: OUT	STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;
	SIGNAL Clock, Resetn, Tick : STD_LOGIC;
	TYPE State_type IS (S0, S1, S2, S3, S4, S5, S6, S7, S8);
	SIGNAL y_Q, Y_D : State_type;
	SIGNAL FSM_char : STD_LOGIC_VECTOR(0 TO 6); 
		-- input to pipeline regs comes from 
		-- FSM_char for the first 8 clock cycles,
		-- and then comes from the pipeline's 
		-- last stage (HELLO travels in a loop)
	SIGNAL pipe_select : STD_LOGIC;
	SIGNAL pipe_input : STD_LOGIC_VECTOR(0 TO 6); 
	SIGNAL pipe0, pipe1, pipe2, pipe3, pipe4, pipe5, 
		pipe6, pipe7 : STD_LOGIC_VECTOR(6 DOWNTO 0); 
	SIGNAL slow_count : STD_LOGIC_VECTOR(23 DOWNTO 0); 

	CONSTANT H : STD_LOGIC_VECTOR(0 TO 6) := "1001000";
	CONSTANT E : STD_LOGIC_VECTOR(0 TO 6) := "0110000";
	CONSTANT L : STD_LOGIC_VECTOR(0 TO 6) := "1110001";
	CONSTANT O : STD_LOGIC_VECTOR(0 TO 6) := "0000001";
	CONSTANT Blank : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111111";
BEGIN
	Clock <= CLOCK_50;
	Resetn <= KEY(0);

	-- A large counter to produce a 1 second (approx) enable, called Tick
	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
			slow_count <= slow_count + '1';
		END IF;
	END PROCESS;
	Tick <= '1' WHEN (slow_count = 0) ELSE '0';

	PROCESS (y_Q, Tick) -- state table
	BEGIN
		CASE y_Q IS
			WHEN S0 =>	IF (Tick = '1') THEN Y_D <= S1;
							ELSE Y_D <= S0;
							END IF;
			WHEN S1 =>	IF (Tick = '1') THEN Y_D <= S2;
							ELSE Y_D <= S1;
							END IF;
			WHEN S2 =>	IF (Tick = '1') THEN Y_D <= S3;
							ELSE Y_D <= S2;
							END IF;
			WHEN S3 =>	IF (Tick = '1') THEN Y_D <= S4;
							ELSE Y_D <= S3;
							END IF;
			WHEN S4 =>	IF (Tick = '1') THEN Y_D <= S5;
							ELSE Y_D <= S4;
							END IF;
			WHEN S5 =>	IF (Tick = '1') THEN Y_D <= S6;
							ELSE Y_D <= S5;
							END IF;
			WHEN S6 =>	IF (Tick = '1') THEN Y_D <= S7;
							ELSE Y_D <= S6;
							END IF;
			WHEN S7 =>	IF (Tick = '1') THEN Y_D <= S8;
							ELSE Y_D <= S7;
							END IF;
			WHEN S8 =>	Y_D <= S8;
		END CASE;
	END PROCESS; -- state_table

	PROCESS (Clock)
	BEGIN
		IF  (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN	-- synchronous clear
				y_Q <= S0;
			ELSE
				y_Q <= Y_D;
			END IF;
		END IF;
	END PROCESS;

	PROCESS (y_Q) -- state outputs
	BEGIN
		pipe_select <= '0'; FSM_char <= "-------";
		CASE y_Q IS
			WHEN S0 =>	FSM_char <= H;
			WHEN S1 =>	FSM_char <= E;
			WHEN S2 =>	FSM_char <= L;
			WHEN S3 =>	FSM_char <= L;
			WHEN S4 =>	FSM_char <= O;
			WHEN S5 =>	FSM_char <= Blank;
			WHEN S6 =>	FSM_char <= Blank;
			WHEN S7 =>	FSM_char <= Blank;
			WHEN S8 =>	pipe_select <= '1';
		END CASE;
	END PROCESS; -- state output

	pipe_input <= FSM_char WHEN (pipe_select = '0') ELSE pipe7;
	-- regne (R, Clock, Resetn, E, Q);
	U0: regne PORT MAP (pipe_input, Clock, Resetn, Tick, pipe0);
	U1: regne PORT MAP (pipe0, Clock, Resetn, Tick, pipe1);
	U2: regne PORT MAP (pipe1, Clock, Resetn, Tick, pipe2);
	U3: regne PORT MAP (pipe2, Clock, Resetn, Tick, pipe3);
	U4: regne PORT MAP (pipe3, Clock, Resetn, Tick, pipe4);
	U5: regne PORT MAP (pipe4, Clock, Resetn, Tick, pipe5);
	U6: regne PORT MAP (pipe5, Clock, Resetn, Tick, pipe6);
	U7: regne PORT MAP (pipe6, Clock, Resetn, Tick, pipe7);

	HEX0 <= pipe0;
	HEX1 <= pipe1;
	HEX2 <= pipe2;
	HEX3 <= pipe3;
	HEX4 <= pipe4;
	HEX5 <= pipe5;
	HEX6 <= pipe6;
	HEX7 <= pipe7;
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
				Q <= (OTHERS => '1');
			ELSIF (E = '1') THEN
				Q <= R;
			END IF;
		END IF;
	END PROCESS;
END Behavior;
