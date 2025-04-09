-- LEDController.VHD
-- 2025.03.09
--
-- This SCOMP peripheral drives ten outputs high or low based on
-- a value from SCOMP.

library altera_mf;
library lpm;
library ieee;

use lpm.lpm_components.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY LEDController IS
PORT(
    CS          : IN  STD_LOGIC;
	 CLOCK		 : IN  STD_LOGIC;
    WRITE_EN    : IN  STD_LOGIC;
    RESETN      : IN  STD_LOGIC;
    LED         : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    IO_DATA     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END LEDController;

ARCHITECTURE a OF LEDController IS

SIGNAL BRIGHTNESS	: STD_LOGIC_VECTOR (1 DOWNTO 0); -- duty cycle selection
SIGNAL GAMMA_LENGTH		: STD_LOGIC_VECTOR (7 DOWNTO 0); -- how many clock cycles an LED should be on for PWM
SIGNAL COUNT		: STD_LOGIC_VECTOR (7 DOWNTO 0); -- keeps track of rising clock edges elapsed
SIGNAL ENABLE		: STD_LOGIC_VECTOR (7 DOWNTO 0); -- whether or not an LED should get PWM'ed

BEGIN

	PROCESS(CS, WRITE_EN, RESETN)
		BEGIN
			IF RESETN = '0' THEN
				ENABLE <= "00000000";
			ELSIF CS = '1' AND WRITE_EN = '1' THEN
				BRIGHTNESS <= IO_DATA(9 DOWNTO 8);
				ENABLE <= IO_DATA(7 DOWNTO 0);
			END IF;
	END PROCESS;
	
	-- Update count variable for PWM feature
	PROCESS(CLOCK, RESETN)
		BEGIN
			IF RESETN = '0' THEN
				COUNT <= x"00";
			ELSIF RISING_EDGE(CLOCK) THEN
				COUNT <= COUNT + 1;
				IF COUNT = x"C7" THEN -- full period has passed
					COUNT <= X"00";
				END IF;
			END IF;
	END PROCESS;
	
	-- Here the count signal is updated every clock cycle, which is used to know when to
	-- change the value of an enabled LED.
--	PROCESS(CLOCK, RESETN)
--		BEGIN
--			IF RESETN = '0' THEN
--				COUNT <= x"00";
--				ENABLE <= "00000000";
--			ELSIF RISING_EDGE(CLOCK) THEN
--				IF CS = '1' AND WRITE_EN = '1' THEN
--					ENABLE <= IO_DATA(7 DOWNTO 0);
--					BRIGHTNESS <= IO_DATA(9 DOWNTO 8);
--				END IF;
--				
--				COUNT <= COUNT + 1;
--				
--				IF COUNT = x"C7" then -- full period has passed
--					COUNT <= X"00";	
--				END IF;
--			END IF;
--	END PROCESS;
	 
	-- Here the constant is selected that determines how many clock cycles out of a
	-- 200 clock cycle period an enabled LED stays on for. The amount of clock cycles
	-- was obtained by taking the desired duty cycle which is a decimal value from 0 to 1
	-- raising it to the 2.2 power, which is the gamma constant for red LEDs
	-- and then multiplying the result by 200.
	WITH BRIGHTNESS SELECT
		 GAMMA_LENGTH <= x"09" WHEN "00",
							  x"6A" WHEN "01",
							  x"2C" WHEN "10",
							  x"C7" WHEN OTHERS;
	
	-- Here the actual PWM happens if the switch for that LED is enabled/up
	PROCESS(RESETN, COUNT, ENABLE, GAMMA_LENGTH)
		BEGIN
			IF RESETN = '0' THEN
				LED <= "0000000000";
			ELSE
				FOR c IN 0 to 7 LOOP
					IF ENABLE(c) = '1' AND COUNT < GAMMA_LENGTH THEN
						LED(c) <= '1';
					ELSE LED(c) <= '0';
					END IF;
				END LOOP;
				-- Leave LEDs for duty cycle selection switches off
				LED(8) <= '0';
				LED(9) <= '0';
			END IF;
	END PROCESS;
	
	
END a;