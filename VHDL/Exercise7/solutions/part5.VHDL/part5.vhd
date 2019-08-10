LIBRARY ieee;
USE ieee.std_logic_1164.all;
-- scrolls the word HELLO across the 7-seg displays. An FSM inserts the
-- display values into a pipeline that drives the 8 displays.
-- inputs: KEY0 is the manual clock, and SW0 is the reset input
-- outputs: 7-seg displays HEX7 ... HEX0
ENTITY part5 IS 
PORT (	SW 								: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
			KEY								: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
			HEX7, HEX6, HEX5, HEX4, 
				HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END part5;

ARCHITECTURE Behavior OF part5 IS
	COMPONENT regne
		PORT (	R					: IN	STD_LOGIC_VECTOR(6 DOWNTO 0);
					Clock, Resetn	: STD_LOGIC;
					Q					: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0));
	END COMPONENT;
	SIGNAL Clock, Resetn : STD_LOGIC;
	TYPE State_type IS (S0, S1, S2, S3, S4, S5, S6, S7, S8);
	SIGNAL y_Q, Y_D : State_type;
	SIGNAL FSM_char : STD_LOGIC_VECTOR(0 TO 6); 
		-- input to pipeline regs comes from 
		-- FSM_char for the first 8 clock cycles,
		-- and then comes from the pipeline's 
		-- last stage (HELLO travels in a loop)
	SIGNAL pipe_select : STD_LOGIC;
	SIGNAL pipe_input : STD_LOGIC_VECTOR(6 DOWNTO 0); 
	SIGNAL pipe0, pipe1, pipe2, pipe3, pipe4, pipe5, 
		pipe6, pipe7 : STD_LOGIC_VECTOR(6 DOWNTO 0); 

	CONSTANT H : STD_LOGIC_VECTOR(0 TO 6) := "1001000";
	CONSTANT E : STD_LOGIC_VECTOR(0 TO 6) := "0110000";
	CONSTANT L : STD_LOGIC_VECTOR(0 TO 6) := "1110001";
	CONSTANT O : STD_LOGIC_VECTOR(0 TO 6) := "0000001";
	CONSTANT Blank : STD_LOGIC_VECTOR(0 TO 6) := "1111111";
BEGIN

	Clock <= KEY(0);
	Resetn <= SW(0);

	PROCESS (y_Q) -- state table
	BEGIN
		CASE y_Q IS
			WHEN S0 =>	Y_D <= S1;
			WHEN S1 =>	Y_D <= S2;
			WHEN S2 =>	Y_D <= S3;
			WHEN S3 =>	Y_D <= S4;
			WHEN S4 =>	Y_D <= S5;
			WHEN S5 =>	Y_D <= S6;
			WHEN S6 =>	Y_D <= S7;
			WHEN S7 =>	Y_D <= S8;
			WHEN S8 => 	Y_D <= S8;
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
	U0: regne PORT MAP (pipe_input, Clock, Resetn, pipe0);
	U1: regne PORT MAP (pipe0, Clock, Resetn, pipe1);
	U2: regne PORT MAP (pipe1, Clock, Resetn, pipe2);
	U3: regne PORT MAP (pipe2, Clock, Resetn, pipe3);
	U4: regne PORT MAP (pipe3, Clock, Resetn, pipe4);
	U5: regne PORT MAP (pipe4, Clock, Resetn, pipe5);
	U6: regne PORT MAP (pipe5, Clock, Resetn, pipe6);
	U7: regne PORT MAP (pipe6, Clock, Resetn, pipe7);

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
	PORT (	R					: IN	STD_LOGIC_VECTOR(6 DOWNTO 0);
				Clock, Resetn	: IN STD_LOGIC;
				Q					: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0));
END regne;

ARCHITECTURE Behavior OF regne IS
BEGIN
	PROCESS (Clock)
	BEGIN
		IF  (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN	-- synchronous clear
				Q <= (OTHERS => '1');
			ELSE
				Q <= R;
			END IF;
		END IF;
	END PROCESS;
END Behavior;
