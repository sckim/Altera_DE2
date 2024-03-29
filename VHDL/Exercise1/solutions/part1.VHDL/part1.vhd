LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Simple module that connects the SW switches to the LEDR lights
ENTITY part1 IS 
	PORT (	SW		: IN	STD_LOGIC_VECTOR(17 DOWNTO 0);
				LEDR	: OUT	STD_LOGIC_VECTOR(17 DOWNTO 0));  -- red LEDs
END part1;

ARCHITECTURE Structure OF part1 IS
BEGIN
	LEDR <= SW;
END Structure;
