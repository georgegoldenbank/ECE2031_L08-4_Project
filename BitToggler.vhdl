-- BitToggler.vhd
-- 2025.04.08
--
-- This SCOMP peripheral toggles LED states.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BitToggler is
    port(
        CS         : in  std_logic;
        WRITE_EN   : in  std_logic;
        RESETN     : in  std_logic;
        IO_DATA    : in  std_logic_vector(15 downto 0);
        LED       : out std_logic_vector(9 downto 0)
    );
end BitToggler;

architecture Behavioral of BitToggler is
    -- Has current LED states(all LED bit values).
    -- On reset, all LEDs turned off.
    signal LED_STATE : std_logic_vector(9 downto 0) := (others => '0');
begin
    -- Process to latch IO_DATA into LED_STATE.
    process(RESETN, CS)
    begin
        if RESETN = '0' then
            -- On reset, make all LEDs off.
            LED_STATE <= (others => '0');
        elsif rising_edge(CS) then
            if WRITE_EN = '1' then
                -- Toggle bits by using XOR to invert any bit where written value is '1'.
                LED_STATE <= LED_STATE xor IO_DATA(9 downto 0);
            end if;
        end if;
    end process;

    -- Drive output LED ports with LED_STATE.
    LED <= LED_STATE;

end Behavioral;