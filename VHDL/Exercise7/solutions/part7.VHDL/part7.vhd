-- scrolls the word HELLO across the 7-seg displays. An FSM inserts the
-- display values into a pipeline that drives the 8 displays; each display
-- is driven for about 1 second before changing to the next character
-- inputs: 50 MHz clock, KEY0 is reset input, KEY1 doubles the speed of the
--   display, KEY2 halves the speed
-- outputs: 7-seg displays HEX7 ... HEX0
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
ENTITY part7 IS 
PORT (	KEY 								: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);
			CLOCK_50							: IN	STD_LOGIC;
			HEX7, HEX6, HEX5, HEX4, 
				HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6);
			LEDG								: OUT	STD_LOGIC_VECTOR(3 DOWNTO 0));
END part7;

ARCHITECTURE Behavior OF part7 IS
	COMPONENT regne
		GENERIC ( N	: integer:=	7);
		PORT (	R						: IN	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
					Clock, Resetn, E	: STD_LOGIC;
					Q						: OUT	STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;
	SIGNAL Clock, Resetn, Tick : STD_LOGIC;

	SIGNAL Fast, Slow : STD_LOGIC;	-- Variable tick interval controls
	-- Names of states for changing a counter value for implementing a variable 
	-- tick delay
	TYPE Var_Delay_State_type IS (Sync3, Speed3, Sync4, Speed4, Sync5, Speed5, Sync1, 
		Speed1, Sync2, Speed2);
	SIGNAL yV_Q, YV_D : Var_Delay_State_Type;	
		-- This is the state machine that it used to implement 
		-- a variable tick interval
	-- Names of states for the pipeline control machine
	TYPE State_type IS (S0, S1, S2, S3, S4, S5, S6, S7, S8);
	SIGNAL y_Q, Y_D : State_type;
	SIGNAL FSM_char : STD_LOGIC_VECTOR(0 TO 6); 
		-- input to pipeline regs comes from 
		-- FSM_char for the first 8 clock cycles,
		-- and then comes from the pipeline's 
		-- last stage (HELLO travels in a loop)
	SIGNAL pipe_select : STD_LOGIC;
	SIGNAL pipe_input : STD_LOGIC_VECTOR(0 TO 6); 
	SIGNAL pipe0, pipe1, pipe2, pipe3, pipe4, 
		pipe5, pipe6, pipe7 : STD_LOGIC_VECTOR(0 TO 6); 

	SIGNAL var_count, Modulus : STD_LOGIC_VECTOR(3 DOWNTO 0); 
		-- used to implement a variable delay
	SIGNAL var_count_sync : STD_LOGIC;
	SIGNAL slow_count : STD_LOGIC_VECTOR(22 DOWNTO 0); 

	CONSTANT H : STD_LOGIC_VECTOR(0 TO 6) := "1001000";
	CONSTANT E : STD_LOGIC_VECTOR(0 TO 6) := "0110000";
	CONSTANT L : STD_LOGIC_VECTOR(0 TO 6) := "1110001";
	CONSTANT O : STD_LOGIC_VECTOR(0 TO 6) := "0000001";
	CONSTANT Blank : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111111";

	SIGNAL KEY1_vector, KEY1_sync : STD_LOGIC_VECTOR(0 TO 0); -- For synchronizing KEY(1)
	SIGNAL KEY2_vector, KEY2_sync : STD_LOGIC_VECTOR(0 TO 0); -- For synchronizing KEY(2)
	SIGNAL Fast_vector, Slow_vector : STD_LOGIC_VECTOR(0 TO 0); 
		-- Needed so we can use the regne function with N = 1 for a simple 
		-- flipflop (VHDL type checking)
BEGIN
	Clock <= CLOCK_50;
	Resetn <= KEY(0);

	KEY1_vector(0) <= NOT (KEY(1));
	SYNCFAST1: regne GENERIC MAP (N => 1) PORT MAP 
		(KEY1_vector, Clock, Resetn, '1', KEY1_sync);
	SYNCFAST2: regne GENERIC MAP (N => 1) PORT MAP 
		(KEY1_sync, Clock, Resetn, '1', Fast_vector);
	Fast <= Fast_vector(0); -- silly VHDL type checking

	KEY2_vector(0) <= NOT (KEY(2));
	SYNCSLOW1: regne GENERIC MAP (N => 1) PORT MAP 
		(KEY2_vector, Clock, Resetn, '1', KEY2_sync);
	SYNCSLOW2: regne GENERIC MAP (N => 1) PORT MAP 
		(KEY2_sync, Clock, Resetn, '1', Slow_vector);
	Slow <= Slow_vector(0); -- needed for silly VHDL type checking

	-- state machine that produces a variable delay
	-- Each state will produce an output value that is used to modulo
	-- a counter value. Speed 5 gives the lowest modulo value, and hence the
	-- smallest delay, while Speed 1 gives the largest modulo value, and
	-- hence the largest delay. There is a synchronization state before each
	-- Speed state so that we can wait for the slow switch pressing to end
	PROCESS (yV_Q, Fast, Slow) -- state table speed
	BEGIN
		CASE yV_Q IS
			WHEN Sync5	=>	IF ((Slow = '1') OR (Fast = '1')) THEN
									YV_D <= Sync5;	-- wait for any depressed key to be released
								ELSE
									YV_D <= Speed5;
								END IF;
			WHEN Speed5	=>	IF (Slow = '0') THEN
									YV_D <= Speed5;	-- fastest speed
								ELSE
									YV_D <= Sync4;	-- change to slower speed
								END IF;
			WHEN Sync4	=>	IF ((Slow = '1') OR (Fast = '1')) THEN
									YV_D <= Sync4;	-- wait for a depressed key to be released
								ELSE
									YV_D <= Speed4;
								END IF;
			WHEN Speed4	=>	IF ((Slow = '0') AND (Fast = '0')) THEN
									YV_D <= Speed4;	-- keep this speed
								ELSIF (Slow = '1') THEN
									YV_D <= Sync3;			-- change to slower speed
								ELSE 
									YV_D <= Sync5;		-- change to faster speed
								END IF;
			WHEN Sync3	=>	IF ((Slow = '1') OR (Fast = '1')) THEN
									YV_D <= Sync3;	-- wait for a depressed key to be released
								ELSE 
									YV_D <= Speed3;
								END IF;
			WHEN Speed3	=>	IF ((Slow = '0') AND (Fast = '0')) THEN
									YV_D <= Speed3;	-- keep this speed
								ELSIF (Slow = '1') THEN
									YV_D <= Sync2;			-- change to slower speed
								ELSE
									YV_D <= Sync4;			-- change to faster speed
								END IF;
			WHEN Sync2	=>	IF ((Slow = '1') OR (Fast = '1')) THEN
									YV_D <= Sync2;	-- wait for a depressed key to be released
								ELSE
									YV_D <= Speed2;
								END IF;
			WHEN Speed2	=>	IF ((Slow = '0') AND (Fast = '0')) THEN
									YV_D <= Speed2;	-- keep this speed
								ELSIF (Slow = '1') THEN
									YV_D <= Sync1;			-- change to slower speed
								ELSE
									YV_D <= Sync3;			-- change to faster speed
								END IF;
			WHEN Sync1	=>	IF ((Slow = '1') OR (Fast = '1')) THEN
									YV_D <= Sync1;	-- wait for a depressed key to be released
								ELSE
									YV_D <= Speed1;
								END IF;
			WHEN Speed1	=> IF (Fast = '0') THEN
									YV_D <= Speed1;		-- keep this speed
								ELSE
									YV_D <= Sync2;			-- change to faster speed
								END IF;
		END CASE;
	END PROCESS; -- state_table

	PROCESS (Clock)
	BEGIN
		IF  (Clock'EVENT AND Clock = '1') THEN
			IF (Resetn = '0') THEN	-- synchronous clear
				yV_Q <= Speed3;
			ELSE
				yV_Q <= YV_D;
			END IF;
		END IF;
	END PROCESS;

	PROCESS (yV_Q)
	BEGIN -- state_outputs_speed
		Modulus <= "----"; var_count_sync <= '1';
		CASE yV_Q IS
			WHEN Sync5	=> var_count_sync <= '0';
			WHEN Speed5	=> Modulus <= "0000";
			WHEN Sync4	=> var_count_sync <= '0';
			WHEN Speed4	=> Modulus <= "0001";
			WHEN Sync3	=> var_count_sync <= '0';
			WHEN Speed3	=> Modulus <= "0011";
			WHEN Sync2	=> var_count_sync <= '0';
			WHEN Speed2	=> Modulus <= "0110";
			WHEN Sync1	=> var_count_sync <= '0';
			WHEN Speed1	=> Modulus <= "1100";
		END CASE;
	END PROCESS; -- state_table

	LEDG(3 DOWNTO 0) <= Modulus;

	-- A large counter to produce a .25 second (approx) enable, called Tick
	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
			slow_count <= slow_count + '1';
		END IF;
	END PROCESS;

	-- Counter that provides a variable delay
	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
			IF (var_count_sync = '0') THEN
				var_count <= (OTHERS => '0');
			ELSIF (slow_count = 0) THEN
				IF (var_count = Modulus) THEN
					var_count <= (OTHERS => '0');
				ELSE
					var_count <= var_count + '1';
				END IF;
			END IF;
		END IF;
	END PROCESS;

	-- Tick advances the scrolling letters when var_count = slow_count = 0.
	-- The var_count_sync is used to prevent scrolling when a Fast or Slow
	-- key is being held down.
	Tick <= '1' WHEN ((var_count = 0) AND (slow_count = 0) AND (var_count_sync = '1')) ELSE '0';

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
